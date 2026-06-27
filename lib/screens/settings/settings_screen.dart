// ============================================================================
// ChronosAI — Settings Screen
// Author: K K K Ekanayake
// Task: TASK-002 — Material 3 Dark Theme System + GoRouter Configuration
//
// TODO: Implement in Phase 2 (Core Data + Onboarding)
// This is a placeholder screen for routing verification.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'App Info',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Version'),
                subtitle: Text('$kAppName v$kAppVersion'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red.shade400,
                ),
                title: Text(
                  'Clear All Data',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                subtitle: const Text('This will delete all goals, habits, and journal entries.'),
                onTap: () {
                  // TODO: Implement confirmation dialog and data wipe in Phase 2
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data wipe not yet implemented.'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.key_rounded),
                    title: const Text('API Key'),
                    subtitle: const Text('Manage your Gemini API key'),
                    onTap: () {
                      // TODO: Implement API key management in Phase 2
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('API key management not yet implemented.'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: const Text('Coaching Persona'),
                    subtitle: const Text('Change your coaching style'),
                    onTap: () {
                      // TODO: Implement persona switching in Phase 2
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Persona switching not yet implemented.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'TODO: Implement in Phase 2',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
