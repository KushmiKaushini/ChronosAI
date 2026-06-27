// ============================================================================
// ChronosAI — Home Screen
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('ChronosAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Welcome to ChronosAI',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your intelligent year-planning coach.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              const AiGlowIndicator(voiceState: VoiceState.idle),
              const SizedBox(height: 48),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _QuickActionCard(
                title: 'Voice Chat',
                subtitle: 'Talk to your AI coach',
                icon: Icons.mic_rounded,
                onTap: () => context.go('/voice-chat'),
              ),
              const SizedBox(height: 8),
              _QuickActionCard(
                title: 'Year Plan',
                subtitle: 'View your goals & milestones',
                icon: Icons.calendar_today_rounded,
                onTap: () => context.go('/year-plan'),
              ),
              const SizedBox(height: 8),
              _QuickActionCard(
                title: 'Habits',
                subtitle: 'Track your daily habits',
                icon: Icons.repeat_rounded,
                onTap: () => context.go('/habits'),
              ),
              const SizedBox(height: 8),
              _QuickActionCard(
                title: 'Journal',
                subtitle: 'Write a journal entry',
                icon: Icons.edit_note_rounded,
                onTap: () => context.go('/journal'),
              ),
              const Spacer(),
              Text(
                'TODO: Implement in Phase 4',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        onTap: onTap,
      ),
    );
  }
}
