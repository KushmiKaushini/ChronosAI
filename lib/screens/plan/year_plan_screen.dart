// ============================================================================
// ChronosAI — Year Plan Screen
// Author: K K K Ekanayake
// Task: TASK-002 — Material 3 Dark Theme System + GoRouter Configuration
//
// TODO: Implement in Phase 5 (Goals/Habits/Journal UI)
// This is a placeholder screen for routing verification.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class YearPlanScreen extends StatelessWidget {
  const YearPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Year Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Year Plan',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your goals, milestones, and timeline will appear here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'TODO: Implement in Phase 5',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
