// ============================================================================
// ChronosAI — Permissions Screen (Onboarding Step 3)
// Author: K K K Ekanayake
// Task: TASK-005 — Wire Up Onboarding Flow
//
// Requests microphone permission, marks onboarding complete in DB,
// and navigates to home. Graceful degradation if permission denied.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/app_providers.dart';
import '../../repositories/user_profile_repository.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  Future<void> _onGrantContinue(BuildContext context, WidgetRef ref) async {
    // Request microphone permission
    final status = await Permission.microphone.request();

    // Graceful degradation: proceed regardless of permission result
    // Mark onboarding complete in DB
    final userRepo = ref.read(userProfileRepositoryProvider);
    await userRepo.markOnboardingComplete();

    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Permissions'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Microphone Access',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'ChronosAI needs microphone access for voice coaching.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mic_rounded,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Microphone',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Required for voice coaching',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _onGrantContinue(context, ref),
                child: const Text('Grant & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
