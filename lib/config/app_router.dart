// ============================================================================
// ChronosAI — GoRouter Configuration
// Author: K K K Ekanayake
// Task: TASK-005 — Wire Up Onboarding Flow
//
// Routes:
//   /onboarding/persona
//   /onboarding/api-key
//   /onboarding/permissions
//   /home
//   /voice-chat
//   /year-plan
//   /habits
//   /journal
//   /settings
//
// Redirect: if onboarding not complete → /onboarding/persona
//           (checks Isar DB for onboarding state)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../repositories/user_profile_repository.dart';
import '../screens/onboarding/persona_screen.dart';
import '../screens/onboarding/api_key_screen.dart';
import '../screens/onboarding/permissions_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/voice/voice_chat_screen.dart';
import '../screens/plan/year_plan_screen.dart';
import '../screens/habits/habits_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../services/isar_service.dart';

/// Global navigator key for GoRouter.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration for ChronosAI.
/// All routes are defined here. Redirect logic ensures users who haven't
/// completed onboarding are sent to the persona selection screen.
final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/onboarding/persona',
  redirect: (context, state) async {
    // Check onboarding status from DB
    final isar = IsarService.instance;
    if (!isar.isInitialized) return null;

    final profileRepo = UserProfileRepository();
    final isComplete = await profileRepo.isOnboardingComplete();
    final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');

    if (!isComplete && !isOnboardingRoute) return '/onboarding/persona';
    if (isComplete && isOnboardingRoute) return '/home';
    return null;
  },
  routes: [
    // ── Onboarding Flow ───────────────────────────────────────────────────
    GoRoute(
      path: '/onboarding/persona',
      name: 'persona',
      builder: (context, state) => const PersonaScreen(),
    ),
    GoRoute(
      path: '/onboarding/api-key',
      name: 'apiKey',
      builder: (context, state) => const ApiKeyScreen(),
    ),
    GoRoute(
      path: '/onboarding/permissions',
      name: 'permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),

    // ── Main App Routes ───────────────────────────────────────────────────
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/voice-chat',
      name: 'voiceChat',
      builder: (context, state) => const VoiceChatScreen(),
    ),
    GoRoute(
      path: '/year-plan',
      name: 'yearPlan',
      builder: (context, state) => const YearPlanScreen(),
    ),
    GoRoute(
      path: '/habits',
      name: 'habits',
      builder: (context, state) => const HabitsScreen(),
    ),
    GoRoute(
      path: '/journal',
      name: 'journal',
      builder: (context, state) => const JournalScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],

  /// Error page for unknown routes.
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF121212),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF4A90D9)),
          const SizedBox(height: 16),
          const Text(
            'Page Not Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE0E0E0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.error?.toString() ?? 'Unknown route',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => GoRouter.of(context).go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
