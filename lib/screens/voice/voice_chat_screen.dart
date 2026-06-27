// ============================================================================
// ChronosAI — Voice Chat Screen
// Author: K K K Ekanayake
// Task: TASK-002 — Material 3 Dark Theme System + GoRouter Configuration
//
// TODO: Implement in Phase 4 (Voice UI + Coaching)
// This is a placeholder screen for routing verification.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../widgets/ai_glow_indicator.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  VoiceState _currentState = VoiceState.idle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Voice Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AiGlowIndicator(voiceState: _currentState, size: 120),
                  const SizedBox(height: 32),
                  Text(
                    'AI Coach',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Have a conversation about your goals',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Demo controls to test glow states
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StateButton(
                        label: 'Idle',
                        isActive: _currentState == VoiceState.idle,
                        onTap: () => setState(() => _currentState = VoiceState.idle),
                      ),
                      _StateButton(
                        label: 'Listen',
                        isActive: _currentState == VoiceState.listening,
                        onTap: () => setState(() => _currentState = VoiceState.listening),
                      ),
                      _StateButton(
                        label: 'Think',
                        isActive: _currentState == VoiceState.thinking,
                        onTap: () => setState(() => _currentState = VoiceState.thinking),
                      ),
                      _StateButton(
                        label: 'Speak',
                        isActive: _currentState == VoiceState.speaking,
                        onTap: () => setState(() => _currentState = VoiceState.speaking),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap a state above to preview the glow indicator',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TODO: Implement in Phase 4',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _StateButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
