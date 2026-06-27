// ============================================================================
// ChronosAI — AI Glow Indicator Widget
// Author: K K K Ekanayake
// Task: TASK-002 — Material 3 Dark Theme System + GoRouter Configuration
//
// Animated glow indicator that reflects the current AI voice state:
// - Idle: Dim grey, subtle glow
// - Listening: Cyan pulse animation
// - Thinking: Amber pulse animation
// - Speaking: Green solid glow
// ============================================================================

import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../config/app_theme.dart';

/// A glowing circular indicator that animates based on the AI's voice state.
///
/// Used in the voice chat screen and anywhere the AI's current state
/// needs visual feedback.
class AiGlowIndicator extends StatefulWidget {
  /// The current voice state of the AI.
  final VoiceState voiceState;

  /// Diameter of the glow circle. Defaults to 80.
  final double size;

  /// Whether to show a label below the indicator.
  final bool showLabel;

  const AiGlowIndicator({
    super.key,
    required this.voiceState,
    this.size = 80,
    this.showLabel = true,
  });

  @override
  State<AiGlowIndicator> createState() => _AiGlowIndicatorState();
}

class _AiGlowIndicatorState extends State<AiGlowIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _updateAnimationForState();
  }

  @override
  void didUpdateWidget(AiGlowIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voiceState != widget.voiceState) {
      _updateAnimationForState();
    }
  }

  void _updateAnimationForState() {
    switch (widget.voiceState) {
      case VoiceState.idle:
        _pulseController.stop();
        break;
      case VoiceState.listening:
      case VoiceState.thinking:
        _pulseController.repeat(reverse: true);
        break;
      case VoiceState.speaking:
        _pulseController.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Returns the color for the current voice state.
  Color get _currentColor {
    final glowColors = Theme.of(context).extension<AiVoiceGlowColors>();
    switch (widget.voiceState) {
      case VoiceState.idle:
        return glowColors?.idle ?? kVoiceIdle;
      case VoiceState.listening:
        return glowColors?.listening ?? kVoiceListening;
      case VoiceState.thinking:
        return glowColors?.thinking ?? kVoiceThinking;
      case VoiceState.speaking:
        return glowColors?.speaking ?? kVoiceSpeaking;
    }
  }

  /// Returns the label text for the current voice state.
  String get _label {
    switch (widget.voiceState) {
      case VoiceState.idle:
        return 'Tap to speak';
      case VoiceState.listening:
        return 'Listening...';
      case VoiceState.thinking:
        return 'Thinking...';
      case VoiceState.speaking:
        return 'Speaking...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final double pulseValue = widget.voiceState == VoiceState.idle
                ? 1.0
                : _pulseAnimation.value;

            final double glowOpacity = widget.voiceState == VoiceState.idle
                ? 0.2
                : 0.3 + (pulseValue * 0.4);

            final double glowBlur = widget.voiceState == VoiceState.idle
                ? 8
                : 12 + (pulseValue * 16);

            final double scale = widget.voiceState == VoiceState.idle
                ? 1.0
                : 0.95 + (pulseValue * 0.1);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentColor.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: _currentColor.withValues(alpha: glowOpacity),
                      blurRadius: glowBlur,
                      spreadRadius: widget.voiceState == VoiceState.speaking
                          ? pulseValue * 4
                          : pulseValue * 2,
                    ),
                    BoxShadow(
                      color: _currentColor.withValues(alpha: glowOpacity * 0.5),
                      blurRadius: glowBlur * 2,
                      spreadRadius: pulseValue * 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _icon,
                    size: widget.size * 0.4,
                    color: _currentColor,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _label,
              key: ValueKey(widget.voiceState),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _currentColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Returns the appropriate icon for the current voice state.
  IconData get _icon {
    switch (widget.voiceState) {
      case VoiceState.idle:
        return Icons.mic_none_rounded;
      case VoiceState.listening:
        return Icons.mic_rounded;
      case VoiceState.thinking:
        return Icons.psychology_rounded;
      case VoiceState.speaking:
        return Icons.volume_up_rounded;
    }
  }
}

/// A simplified version of the glow indicator for use in app bars or compact spaces.
class AiGlowDot extends StatelessWidget {
  final VoiceState voiceState;
  final double size;

  const AiGlowDot({
    super.key,
    required this.voiceState,
    this.size = 12,
  });

  Color get _color {
    switch (voiceState) {
      case VoiceState.idle:
        return kVoiceIdle;
      case VoiceState.listening:
        return kVoiceListening;
      case VoiceState.thinking:
        return kVoiceThinking;
      case VoiceState.speaking:
        return kVoiceSpeaking;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color,
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
