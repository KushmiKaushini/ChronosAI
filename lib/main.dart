// ============================================================================
// ChronosAI — Main Entry Point
// Author: K K K Ekanayake
// Task: TASK-003 — Isar DB init + Riverpod ProviderScope
//
// ChronosAI: The Intelligent Adaptive Year Planner
// A voice-first AI coaching experience powered by Gemini Live API.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.initialize();
  runApp(const ProviderScope(child: ChronosAiApp()));
}

/// The root widget of the ChronosAI application.
///
/// Uses Material 3 with a dark-mode-first theme and GoRouter for navigation.
/// Wrapped in [ProviderScope] so that Riverpod providers are available
/// throughout the widget tree.
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
