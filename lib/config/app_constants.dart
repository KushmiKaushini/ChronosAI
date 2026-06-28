// ============================================================================
// ChronosAI — App Constants
// Author: K K K Ekanayake
// Task: TASK-002 — Material 3 Dark Theme System + GoRouter Configuration
// ============================================================================

/// Application-wide constants for ChronosAI.
library;

/// App metadata
const String kAppName = 'ChronosAI';
const String kAppVersion = '1.0.0';

/// AI Voice States — used by the glow indicator widget and voice chat screen.
enum VoiceState {
  /// Microphone inactive, waiting for user input.
  idle,

  /// Recording user speech, microphone active.
  listening,

  /// AI is processing the user's request (Gemini API call in flight).
  thinking,

  /// AI is responding via text-to-speech.
  speaking,
}

/// Persona types — selected during onboarding to tailor coaching experience.
enum PersonaType {
  /// Professional mode — OKR-style goals, work-life balance coaching.
  professional,

  /// Student mode — exam prep, study habits, adaptive scheduling.
  student,
}

/// Goal categories — used for organizing and filtering goals.
enum GoalCategory {
  career,
  health,
  finance,
  relationships,
  personalDevelopment,
  education,
  creativity,
  travel,
}

/// Habit recurrence frequencies.
enum HabitFrequency {
  daily,
  weekly,
  biWeekly,
  monthly,
  custom,
}

/// Mood tags for journal entries.
enum MoodTag {
  grateful,
  motivated,
  calm,
  anxious,
  frustrated,
  excited,
  tired,
  focused,
  overwhelmed,
  proud,
}

/// Extension to get human-readable labels for enums.
extension PersonaTypeLabel on PersonaType {
  String get label {
    switch (this) {
      case PersonaType.professional:
        return 'Professional';
      case PersonaType.student:
        return 'Student';
    }
  }
}

extension GoalCategoryLabel on GoalCategory {
  String get label {
    switch (this) {
      case GoalCategory.career:
        return 'Career';
      case GoalCategory.health:
        return 'Health';
      case GoalCategory.finance:
        return 'Finance';
      case GoalCategory.relationships:
        return 'Relationships';
      case GoalCategory.personalDevelopment:
        return 'Personal Development';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.creativity:
        return 'Creativity';
      case GoalCategory.travel:
        return 'Travel';
    }
  }
}

extension HabitFrequencyLabel on HabitFrequency {
  String get label {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.biWeekly:
        return 'Bi-Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
      case HabitFrequency.custom:
        return 'Custom';
    }
  }
}

extension MoodTagLabel on MoodTag {
  String get label {
    switch (this) {
      case MoodTag.grateful:
        return 'Grateful';
      case MoodTag.motivated:
        return 'Motivated';
      case MoodTag.calm:
        return 'Calm';
      case MoodTag.anxious:
        return 'Anxious';
      case MoodTag.frustrated:
        return 'Frustrated';
      case MoodTag.excited:
        return 'Excited';
      case MoodTag.tired:
        return 'Tired';
      case MoodTag.focused:
        return 'Focused';
      case MoodTag.overwhelmed:
        return 'Overwhelmed';
      case MoodTag.proud:
        return 'Proud';
    }
  }
}
