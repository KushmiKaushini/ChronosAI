// ============================================================================
// ChronosAI — Main Entry Point
// Author: K K K Ekanayake
// Task: TASK-002 — Material 3 Dark Theme System + GoRouter Configuration
//
// ChronosAI: The Intelligent Adaptive Year Planner
// A voice-first AI coaching experience powered by Gemini Live API.
// ============================================================================

import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'config/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChronosAiApp());
}

/// The root widget of the ChronosAI application.
///
/// Uses Material 3 with a dark-mode-first theme and GoRouter for navigation.
class ChronosAiApp extends StatelessWidget {
  const ChronosAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChronosAI',
      debugShowCheckedModeBanner: false,

      // Material 3 dark theme as default
      theme: kChronosDarkTheme,

      // GoRouter configuration
      routerConfig: appRouter,
    );
  }
}
