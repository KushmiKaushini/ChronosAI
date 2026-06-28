// ============================================================================
// ChronosAI — Voice Chat Screen
// Author: K K K Ekanayake
// Task: TASK-009 — Wire Voice Chat Screen
//
// Real voice chat interface connected to Gemini and Audio services.
// Supports text input (silent mode) with streaming AI responses.
// Microphone button triggers recording with "Speech coming soon" notice.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../providers/providers.dart';
import '../../services/audio_service.dart';
import '../../services/gemini_service.dart';
import '../../widgets/ai_glow_indicator.dart';

/// Represents a single message in the conversation.
class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isStreaming;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isStreaming = false,
  });

  _ChatMessage copyWith({String? text, bool? isStreaming}) {
    return _ChatMessage(
      text: text ?? this.text,
      isUser: isUser,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class VoiceChatScreen extends ConsumerStatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  ConsumerState<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends ConsumerState<VoiceChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  /// Currently streaming AI message (null when not streaming).
  _ChatMessage? _streamingMessage;
  int? _streamingIndex;

  /// Subscription to the current Gemini stream.
  StreamSubscription<String>? _streamSubscription;

  /// Last user message for retry functionality.
  String? _lastUserMessage;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Sends a text message to Gemini and streams the response.
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message to conversation
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _lastUserMessage = text.trim();
      _streamingMessage = const _ChatMessage(
        text: '',
        isUser: false,
        isStreaming: true,
      );
      _streamingIndex = _messages.length;
      _messages.add(_streamingMessage!);
    });

    _textController.clear();
    _scrollToBottom();

    final geminiService = ref.read(geminiServiceProvider);

    try {
      final stream = geminiService.sendMessage(text.trim());
      _streamSubscription = stream.listen(
        (chunk) {
          if (mounted) {
            setState(() {
              _streamingMessage = _streamingMessage!.copyWith(
                text: _streamingMessage!.text + chunk,
              );
              if (_streamingIndex != null &&
                  _streamingIndex! < _messages.length) {
                _messages[_streamingIndex!] = _streamingMessage!;
              }
            });
            _scrollToBottom();
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _streamingMessage = _streamingMessage?.copyWith(isStreaming: false);
              if (_streamingIndex != null &&
                  _streamingIndex! < _messages.length) {
                _messages[_streamingIndex!] = _streamingMessage!;
              }
              _streamingMessage = null;
              _streamingIndex = null;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _streamingMessage = _streamingMessage?.copyWith(
                text: 'Error: $error',
                isStreaming: false,
              );
              if (_streamingIndex != null &&
                  _streamingIndex! < _messages.length) {
                _messages[_streamingIndex!] = _streamingMessage!;
              }
              _streamingMessage = null;
              _streamingIndex = null;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _streamingMessage = _streamingMessage?.copyWith(
            text: 'Failed to send: $e',
            isStreaming: false,
          );
          if (_streamingIndex != null && _streamingIndex! < _messages.length) {
            _messages[_streamingIndex!] = _streamingMessage!;
          }
          _streamingMessage = null;
          _streamingIndex = null;
        });
      }
    }
  }

  /// Handles microphone button tap — shows "Speech coming soon" notice.
  Future<void> _onMicTap() async {
    final audioService = ref.read(audioServiceProvider);

    if (audioService.isRecording) {
      // Stop recording
      try {
        await audioService.stopRecording();
        // Show text input dialog for transcript since STT isn't ready
        if (mounted) {
          _showTextInputDialog();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recording error: $e')),
          );
        }
      }
    } else {
      // Start recording
      try {
        final started = await audioService.startRecording();
        if (!started && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not start recording. Check microphone permission.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recording error: $e')),
          );
        }
      }
    }
  }

  /// Shows a text input dialog as a fallback for speech-to-text.
  void _showTextInputDialog() {
    final dialogController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send your message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Speech-to-text is coming soon. Type your message for now:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dialogController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = dialogController.text.trim();
              Navigator.of(ctx).pop();
              if (text.isNotEmpty) {
                _sendMessage(text);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  /// Scrolls the conversation list to the bottom.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Retries the last message after an error.
  void _retryLastMessage() {
    if (_lastUserMessage != null) {
      // Remove the last error message if present
      if (_messages.isNotEmpty && !_messages.last.isUser) {
        setState(() {
          _messages.removeLast();
        });
      }
      _sendMessage(_lastUserMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final geminiService = ref.watch(geminiServiceProvider);
    final audioService = ref.watch(audioServiceProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isLocalMode = geminiService.state is GeminiLocalMode;
    final isError = geminiService.state is GeminiError;
    final isDemoMode = !geminiService.isLiveMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Voice Coach'),
            if (isLocalMode) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Offline',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Demo mode banner
            if (isDemoMode && !isError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo mode — add API key in Settings for AI coaching',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Error banner with retry
            if (isError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colorScheme.errorContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        geminiService.lastError ?? 'An error occurred',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _retryLastMessage,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            // Conversation area
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(context)
                  : _buildConversationList(colorScheme, theme),
            ),

            // Amplitude visualization bar
            if (audioService.isRecording)
              _buildAmplitudeBar(audioService, colorScheme),

            // Bottom interaction area
            _buildBottomArea(context, colorScheme, theme, audioService),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state with suggestion chips.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AiGlowIndicator(
              voiceState: VoiceState.idle,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              'Start a conversation',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask your AI coach about goals, habits, or anything on your mind.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: 'How am I doing this week?',
                  onTap: () => _sendMessage('How am I doing this week?'),
                ),
                _SuggestionChip(
                  label: 'Help me plan my goals',
                  onTap: () => _sendMessage('Help me plan my goals'),
                ),
                _SuggestionChip(
                  label: 'I want to talk about my habits',
                  onTap: () => _sendMessage('I want to talk about my habits'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the conversation list with message bubbles.
  Widget _buildConversationList(ColorScheme colorScheme, ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _MessageBubble(
          message: message,
          colorScheme: colorScheme,
          theme: theme,
        );
      },
    );
  }

  /// Builds the amplitude visualization bar.
  Widget _buildAmplitudeBar(AudioService audioService, ColorScheme colorScheme) {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: audioService.amplitude,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// Builds the bottom interaction area with mic button and text input.
  Widget _buildBottomArea(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
    AudioService audioService,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Microphone button row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mic button with glow ring
              GestureDetector(
                onTap: _onMicTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: audioService.isRecording
                        ? colorScheme.error
                        : colorScheme.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: audioService.isRecording
                            ? colorScheme.error.withValues(alpha: 0.4)
                            : colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: audioService.isRecording ? 20 : 10,
                        spreadRadius: audioService.isRecording ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    audioService.isRecording
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    size: 32,
                    color: audioService.isRecording
                        ? colorScheme.onError
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            audioService.isRecording
                ? 'Recording... tap to stop'
                : 'Tap mic to record (text input below)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          // Text input fallback
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (text) => _sendMessage(text),
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _sendMessage(_textController.text),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single message bubble in the conversation.
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _MessageBubble({
    required this.message,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // AI glow dot indicator
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: AiGlowDot(
                voiceState: message.isStreaming
                    ? VoiceState.speaking
                    : VoiceState.idle,
                size: 10,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.text.isEmpty ? '…' : message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: message.isUser
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontStyle: message.text.isEmpty && message.isStreaming
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            // User avatar placeholder
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A suggestion chip shown in the empty state.
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }
}
