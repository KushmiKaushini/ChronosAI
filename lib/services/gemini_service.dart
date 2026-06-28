// ============================================================================
// ChronosAI — Gemini Live Service
// Author: K K K Ekanayake
// Task: TASK-007 — Gemini Live Service
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/app_constants.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/milestone.dart';
import '../repositories/goal_repository.dart';
import '../repositories/habit_repository.dart';
import '../repositories/journal_repository.dart';
import '../repositories/milestone_repository.dart';
import '../repositories/user_profile_repository.dart';
import 'secure_storage_service.dart';

// ---------------------------------------------------------------------------
// GeminiServiceState — sealed class hierarchy for reactive state tracking
// ---------------------------------------------------------------------------

/// Represents the current operational state of the Gemini service.
sealed class GeminiServiceState {
  const GeminiServiceState();
}

class GeminiInitial extends GeminiServiceState {
  const GeminiInitial();
}

class GeminiConnecting extends GeminiServiceState {
  const GeminiConnecting();
}

class GeminiConnected extends GeminiServiceState {
  const GeminiConnected();
}

class GeminiStreaming extends GeminiServiceState {
  const GeminiStreaming();
}

class GeminiError extends GeminiServiceState {
  final String message;
  const GeminiError(this.message);
}

class GeminiLocalMode extends GeminiServiceState {
  const GeminiLocalMode();
}

// ---------------------------------------------------------------------------
// CoachingContext — data snapshot gathered from local DB for prompt building
// ---------------------------------------------------------------------------

/// Immutable snapshot of user data used to build coaching prompts.
class CoachingContext {
  final double goalProgressPercent;
  final int activeHabitCount;
  final List<Habit> activeHabits;
  final List<Milestone> overdueMilestones;
  final List<JournalEntry> recentEntries;
  final PersonaType personaType;

  const CoachingContext({
    this.goalProgressPercent = 0.0,
    this.activeHabitCount = 0,
    this.activeHabits = const [],
    this.overdueMilestones = const [],
    this.recentEntries = const [],
    this.personaType = PersonaType.professional,
  });
}

// ---------------------------------------------------------------------------
// GeminiService — main service class (ChangeNotifier)
// ---------------------------------------------------------------------------

/// Service that manages communication with the Gemini Live API.
///
/// When an API key is available, messages are streamed through the Gemini
/// model. When offline or on error, the [LocalCoachEngine] provides
/// deterministic rule-based coaching responses.
class GeminiService extends ChangeNotifier {
  // --- Dependencies ---
  final SecureStorageService _secureStorage;

  // --- State ---
  String? _apiKey;
  bool _isConnected = false;
  bool _isLiveMode = false;
  String? _lastError;
  GeminiServiceState _state = const GeminiInitial();

  // --- Gemini SDK objects ---
  GenerativeModel? _model;
  ChatSession? _chatSession;

  // --- Repositories (lazy, only used for prompt building) ---
  GoalRepository? _goalRepo;
  HabitRepository? _habitRepo;
  MilestoneRepository? _milestoneRepo;
  JournalRepository? _journalRepo;
  UserProfileRepository? _userProfileRepo;

  // --- Retry config ---
  static const int _maxRetries = 3;
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const List<Duration> _backoffDelays = [
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
  ];

  GeminiService({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  // --- Public getters ---

  String? get apiKey => _apiKey;
  bool get isConnected => _isConnected;
  bool get isLiveMode => _isLiveMode;
  String? get lastError => _lastError;
  GeminiServiceState get state => _state;

  // --- Initialization ---

  /// Initializes the service by reading the stored API key.
  ///
  /// If a valid key is found, configures the Gemini model for live mode.
  /// Otherwise, falls back to local coaching mode.
  Future<void> initialize() async {
    _setState(const GeminiConnecting());

    try {
      _apiKey = await _secureStorage.getApiKey();

      if (_apiKey != null && _apiKey!.isNotEmpty) {
        _configureGemini(_apiKey!);
        _isLiveMode = true;
        _isConnected = true;
        _setState(const GeminiConnected());
      } else {
        _isLiveMode = false;
        _isConnected = false;
        _setState(const GeminiLocalMode());
      }

      _lastError = null;
    } on Exception catch (e) {
      _lastError = 'Initialization failed: $e';
      _isLiveMode = false;
      _isConnected = false;
      _setState(GeminiError(_lastError!));
    }
  }

  /// Injects repository instances (called after Isar is initialized).
  void injectRepositories({
    required GoalRepository goalRepo,
    required HabitRepository habitRepo,
    required MilestoneRepository milestoneRepo,
    required JournalRepository journalRepo,
    required UserProfileRepository userProfileRepo,
  }) {
    _goalRepo = goalRepo;
    _habitRepo = habitRepo;
    _milestoneRepo = milestoneRepo;
    _journalRepo = journalRepo;
    _userProfileRepo = userProfileRepo;
  }

  // --- API key management ---

  /// Saves a new API key and reconfigures the service for live mode.
  Future<void> setApiKey(String key) async {
    await _secureStorage.saveApiKey(key);
    _apiKey = key;
    _configureGemini(key);
    _isLiveMode = true;
    _isConnected = true;
    _lastError = null;

    // Reset chat session so new key starts fresh
    _chatSession = null;
    _setState(const GeminiConnected());
  }

  /// Removes the stored API key and switches to local mode.
  Future<void> clearApiKey() async {
    await _secureStorage.deleteApiKey();
    _apiKey = null;
    _model = null;
    _chatSession = null;
    _isLiveMode = false;
    _isConnected = false;
    _setState(const GeminiLocalMode());
  }

  // --- Send message ---

  /// Sends a user message and returns a stream of response chunks.
  ///
  /// In live mode, the message is sent to the Gemini API with streaming.
  /// In local mode, the [LocalCoachEngine] generates a deterministic
  /// rule-based coaching response.
  Stream<String> sendMessage(String userMessage) async* {
    if (userMessage.trim().isEmpty) {
      yield "Please share what's on your mind — I'm here to help.";
      return;
    }

    if (_isLiveMode && _model != null) {
      yield* _sendLiveMessage(userMessage);
    } else {
      yield* _sendLocalMessage(userMessage);
    }
  }

  /// Streams a response from the Gemini Live API with retry/backoff logic.
  Stream<String> _sendLiveMessage(String userMessage) async* {
    _setState(const GeminiStreaming());

    int attempt = 0;

    while (attempt <= _maxRetries) {
      try {
        final systemPrompt = await _buildSystemPrompt();

        // Re-create chat session if needed (handles model reset)
        _chatSession ??= _model!.startChat(
          history: [],
        );

        // Build the full message with system instruction context
        final fullMessage = _chatSession!.history.isEmpty
            ? '$systemPrompt\n\nUser: $userMessage'
            : userMessage;

        final responseStream = _chatSession!.sendMessageStream(
          Content.text(fullMessage),
        );

        await for (final response
            in responseStream.timeout(_requestTimeout)) {
          final text = response.text;
          if (text != null) {
            yield text;
          }
        }

        _setState(const GeminiConnected());
        _lastError = null;
        return; // Success — exit retry loop
      } on SocketException catch (e) {
        // Network error — retry once then local fallback
        _lastError = 'Network error: $e';
        if (attempt < 1) {
          attempt++;
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }
        _switchToLocalMode();
        yield* _sendLocalMessage(userMessage);
        return;
      } on GenerativeAIException catch (e) {
        final errorString = e.toString();

        if (errorString.contains('429') ||
            errorString.contains('RESOURCE_EXHAUSTED')) {
          // Rate limit — exponential backoff then local fallback
          if (attempt < _maxRetries) {
            final delay = attempt < _backoffDelays.length
                ? _backoffDelays[attempt]
                : _backoffDelays.last;
            _lastError = 'Rate limited. Retrying in ${delay.inSeconds}s…';
            await Future<void>.delayed(delay);
            attempt++;
            continue;
          }
          _switchToLocalMode();
          yield* _sendLocalMessage(userMessage);
          return;
        }

        if (errorString.contains('403') ||
            errorString.contains('PERMISSION_DENIED')) {
          // Invalid key — mark as invalid and switch to local mode
          _lastError = 'API key invalid or permission denied.';
          _isConnected = false;
          _switchToLocalMode();
          yield* _sendLocalMessage(userMessage);
          return;
        }

        // Other API errors — retry then fallback
        _lastError = 'API error: $e';
        if (attempt < 1) {
          attempt++;
          await Future<void>.delayed(const Duration(seconds: 1));
          continue;
        }
        _switchToLocalMode();
        yield* _sendLocalMessage(userMessage);
        return;
      } on TimeoutException {
        _lastError = 'Request timed out after ${_requestTimeout.inSeconds}s.';
        if (attempt < 1) {
          attempt++;
          continue;
        }
        _switchToLocalMode();
        yield* _sendLocalMessage(userMessage);
        return;
      } on FormatException catch (e) {
        _lastError = 'Response format error: $e';
        _switchToLocalMode();
        yield* _sendLocalMessage(userMessage);
        return;
      } on Exception catch (e) {
        _lastError = 'Unexpected error: $e';
        if (attempt < 1) {
          attempt++;
          await Future<void>.delayed(const Duration(seconds: 1));
          continue;
        }
        _switchToLocalMode();
        yield* _sendLocalMessage(userMessage);
        return;
      }
    }
  }

  /// Delegates to the local coaching engine.
  Stream<String> _sendLocalMessage(String userMessage) async* {
    final context = await _gatherCoachingContext();
    final response = LocalCoachEngine.generateResponse(userMessage, context);
    yield response;
  }

  // --- System prompt building ---

  /// Builds a rich system prompt using data from all repositories.
  ///
  /// This prompt provides the Gemini model with full context about the
  /// user's goals, habits, milestones, journal, and persona.
  Future<String> _buildSystemPrompt() async {
    final context = await _gatherCoachingContext();

    final buffer = StringBuffer();
    buffer.writeln('You are ChronosAI, an intelligent adaptive life coach.');

    // Persona-specific instructions
    if (context.personaType == PersonaType.professional) {
      buffer.writeln(_professionalPersonaPrompt());
    } else {
      buffer.writeln(_studentPersonaPrompt());
    }

    // Goal context
    buffer.writeln();
    buffer.writeln('## User Context');
    buffer.writeln(
      '- Goal completion: ${context.goalProgressPercent.toStringAsFixed(1)}%',
    );

    // Habit context
    buffer.writeln('- Active habits: ${context.activeHabitCount}');
    if (context.activeHabits.isNotEmpty) {
      final topHabits = context.activeHabits.take(5);
      for (final habit in topHabits) {
        buffer.writeln(
          '  - "${habit.title}" — ${habit.frequency}, streak: ${habit.streakCount} days',
        );
      }
    }

    // Overdue milestone context
    if (context.overdueMilestones.isNotEmpty) {
      buffer.writeln(
        '- Overdue milestones: ${context.overdueMilestones.length}',
      );
      for (final m in context.overdueMilestones.take(3)) {
        final daysOverdue = DateTime.now().difference(m.dueDate).inDays;
        buffer.writeln(
          '  - "${m.title}" — ${daysOverdue} days overdue',
        );
      }
    }

    // Recent mood/journal context
    if (context.recentEntries.isNotEmpty) {
      buffer.writeln('- Recent journal moods:');
      for (final entry in context.recentEntries) {
        if (entry.moodTag != null) {
          buffer.writeln('  - ${entry.moodTag}');
        }
      }
    }

    buffer.writeln();
    buffer.writeln(
      "Be concise, actionable, and empathetic. Provide specific suggestions "
      "based on the user's data above. Keep responses under 200 words unless "
      "the user asks for detail.",
    );

    return buffer.toString();
  }

  /// Gathers a [CoachingContext] snapshot from local repositories.
  Future<CoachingContext> _gatherCoachingContext() async {
    try {
      final goalProgress = _goalRepo != null
          ? await _goalRepo!.averageProgress()
          : 0.0;

      List<Habit> activeHabits = [];
      if (_habitRepo != null) {
        activeHabits = await _habitRepo!.getActive();
      }

      List<Milestone> overdueMilestones = [];
      if (_milestoneRepo != null) {
        overdueMilestones = await _milestoneRepo!.getOverdue();
      }

      List<JournalEntry> recentEntries = [];
      if (_journalRepo != null) {
        recentEntries = await _journalRepo!.getRecent(limit: 5);
      }

      PersonaType personaType = PersonaType.professional;
      if (_userProfileRepo != null) {
        final profile = await _userProfileRepo!.getOrCreate();
        personaType = profile.personaType == 'student'
            ? PersonaType.student
            : PersonaType.professional;
      }

      return CoachingContext(
        goalProgressPercent: goalProgress,
        activeHabitCount: activeHabits.length,
        activeHabits: activeHabits,
        overdueMilestones: overdueMilestones,
        recentEntries: recentEntries,
        personaType: personaType,
      );
    } on Exception catch (e) {
      // If DB queries fail, return default context — never block the user
      debugPrint('GeminiService: Failed to gather context: $e');
      return const CoachingContext();
    }
  }

  /// Professional persona system prompt fragment.
  String _professionalPersonaPrompt() {
    return '''
## Coaching Persona: Professional
You coach working professionals. Focus on:
- OKRs (Objectives and Key Results) and measurable outcomes
- Career growth and strategic skill development
- Work-life balance and burnout prevention
- Quarterly planning and milestone-driven progress
- Networking, leadership, and professional relationships
- Time-blocking and deep work strategies''';
  }

  /// Student persona system prompt fragment.
  String _studentPersonaPrompt() {
    return '''
## Coaching Persona: Student
You coach students. Focus on:
- Exam preparation and study planning
- Building effective study habits and routines
- Deadline management and prioritization
- Motivation, consistency, and avoiding procrastination
- Active recall and spaced repetition techniques
- Balancing academics with well-being and social life''';
  }

  // --- Private helpers ---

  /// Configures the [GenerativeModel] with the given API key.
  void _configureGemini(String key) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: key,
    );
    _chatSession = null; // Reset session on reconfigure
  }

  /// Switches to local mode after an unrecoverable error.
  void _switchToLocalMode() {
    _isLiveMode = false;
    _isConnected = false;
    _setState(const GeminiLocalMode());
  }

  /// Updates state and notifies listeners.
  void _setState(GeminiServiceState newState) {
    _state = newState;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// LocalCoachEngine — deterministic rule-based coaching (offline fallback)
// ---------------------------------------------------------------------------

/// A purely deterministic coaching engine that uses local DB statistics
/// to craft contextual responses without any external API call.
///
/// This engine is the offline fallback when:
/// - No API key is configured
/// - The API is rate-limited (429)
/// - The API key is invalid (403)
/// - Network errors or timeouts occur
class LocalCoachEngine {
  LocalCoachEngine._(); // Static-only class

  /// Generates a coaching response based on the user message and local context.
  ///
  /// The engine applies rules in priority order:
  /// 1. Overdue milestones → action-oriented nudge
  /// 2. Strong habit streaks → positive reinforcement
  /// 3. Low goal completion → encouragement for small steps
  /// 4. Persona-based general encouragement
  static String generateResponse(
      String userMessage, CoachingContext context) {
    final parts = <String>[];

    // Rule 1: Overdue milestones (highest priority — action needed)
    if (context.overdueMilestones.isNotEmpty) {
      final milestone = context.overdueMilestones.first;
      final daysOverdue =
          DateTime.now().difference(milestone.dueDate).inDays;
      parts.add(
        'You have ${context.overdueMilestones.length} overdue milestone(s). '
        "Let's focus on '${milestone.title}' — it was due $daysOverdue days ago.",
      );
    }

    // Rule 2: Celebrate habit streaks > 3 days
    final strongStreaks = context.activeHabits
        .where((h) => h.streakCount > 3)
        .toList();
    if (strongStreaks.isNotEmpty) {
      final best = strongStreaks.reduce(
        (a, b) => a.streakCount > b.streakCount ? a : b,
      );
      parts.add(
        "Great job maintaining your '${best.title}' habit for "
        '${best.streakCount} days!',
      );
    }

    // Rule 3: Low goal completion — encourage small steps
    if (context.goalProgressPercent < 30) {
      parts.add(
        'Your goals are just getting started. Small consistent steps matter.',
      );
    }

    // Rule 4: Persona-based encouragement
    if (context.personaType == PersonaType.professional) {
      parts.add(
        _professionalEncouragement(userMessage, context),
      );
    } else {
      parts.add(
        _studentEncouragement(userMessage, context),
      );
    }

    return parts.join('\n\n');
  }

  /// Professional-mode encouragement based on message content.
  static String _professionalEncouragement(
    String userMessage,
    CoachingContext context,
  ) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('okr') || lower.contains('objective')) {
      return 'Consider breaking your OKR into weekly key results. '
          'What measurable outcome can you target this week?';
    }

    if (lower.contains('burnout') ||
        lower.contains('overwhelm') ||
        lower.contains('stress')) {
      return 'Burnout is a signal, not a failure. Try time-blocking '
          '2 hours of deep work followed by a proper break. '
          'Protect your recovery time.';
    }

    if (lower.contains('career') ||
        lower.contains('promotion') ||
        lower.contains('growth')) {
      return 'Career growth compounds. Focus on one high-impact skill '
          'this quarter and track your progress weekly.';
    }

    return 'As a professional, focus on high-leverage activities. '
        'Review your quarterly goals — which milestone can you unblock today?';
  }

  /// Student-mode encouragement based on message content.
  static String _studentEncouragement(
    String userMessage,
    CoachingContext context,
  ) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('exam') ||
        lower.contains('test') ||
        lower.contains('midterm') ||
        lower.contains('final')) {
      return 'For exam prep, use active recall: close your notes and '
          'write everything you remember. Then check what you missed. '
          'Space your review sessions across days.';
    }

    if (lower.contains('procrastinat') ||
        lower.contains('lazy') ||
        lower.contains('motivation')) {
      return 'Motivation follows action, not the other way around. '
          "Start with just 5 minutes — you'll likely keep going. "
          'Set a timer and begin.';
    }

    if (lower.contains('deadline') || lower.contains('due')) {
      return 'Map all deadlines visually. Tackle the closest one first, '
          'but spend 10 minutes daily on the bigger projects. '
          'Consistency beats cramming.';
    }

    return 'As a student, building consistent study habits matters more '
        'than any single session. Which subject will you tackle today?';
  }
}
