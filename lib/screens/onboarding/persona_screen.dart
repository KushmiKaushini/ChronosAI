// ============================================================================
// ChronosAI — Persona Selection Screen (Onboarding Step 1)
// Author: K K K Ekanayake
// Task: TASK-005 — Wire Up Onboarding Flow
//
// Saves selected persona to Riverpod state and Isar DB, then navigates
// to the API key screen.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../providers/app_providers.dart';

class PersonaScreen extends ConsumerWidget {
  const PersonaScreen({super.key});

  Future<void> _onPersonaSelected(
    BuildContext context,
    WidgetRef ref,
    PersonaType selectedPersona,
  ) async {
    // Update Riverpod state
    ref.read(personaProvider.notifier).state = selectedPersona;

    // Persist to DB
    final userRepo = ref.read(userProfileRepositoryProvider);
    await userRepo.updatePersona(selectedPersona.name);

    // Navigate to API key screen
    if (context.mounted) {
      context.go('/onboarding/api-key');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Get Started'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Who are you?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your persona to personalize your coaching experience.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _PersonaCard(
                persona: PersonaType.professional,
                title: 'Professional',
                description: 'I want to balance career goals with personal growth.',
                icon: Icons.work_outline_rounded,
                onTap: () => _onPersonaSelected(context, ref, PersonaType.professional),
              ),
              const SizedBox(height: 16),
              _PersonaCard(
                persona: PersonaType.student,
                title: 'Student',
                description: 'I want to stay on top of studies and build good habits.',
                icon: Icons.school_outlined,
                onTap: () => _onPersonaSelected(context, ref, PersonaType.student),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final PersonaType persona;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.persona,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
