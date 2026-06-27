// ============================================================================
// ChronosAI — API Key Screen (Onboarding Step 2)
// Author: K K K Ekanayake
// Task: TASK-002 — Material 3 Dark Theme System + GoRouter Configuration
//
// TODO: Implement in Phase 2 (Core Data + Onboarding)
// This is a placeholder screen for routing verification.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApiKeyScreen extends StatelessWidget {
  const ApiKeyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('API Key'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Enter Gemini API Key',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your API key is stored securely on your device. Skip for demo mode.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'AIza...',
                  labelText: 'API Key',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/onboarding/permissions'),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/onboarding/permissions'),
                child: const Text('Skip (Demo Mode)'),
              ),
              const Spacer(),
              Text(
                'TODO: Implement in Phase 2',
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
