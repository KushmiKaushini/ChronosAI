// ============================================================================
// ChronosAI — Material 3 Dark Theme System
// Author: K K K Ekanayake
// Task: TASK-002 — Material 3 Dark Theme System + GoRouter Configuration
//
// Design Spec (from approved plan):
// - Background: Deep charcoal (#121212)
// - Surface: Elevated dark surfaces (#1E1E1E)
// - Primary Accent: Electric blue (#4A90D9)
// - AI Voice Glow: Animated cyan/teal gradient
// - Typography: Inter / Roboto, large readable body
// - Animations: 300ms ease-out transitions
// ============================================================================

import 'package:flutter/material.dart';

// ── Design Tokens ──────────────────────────────────────────────────────────

/// Deep charcoal background color.
const Color kBackgroundDeep = Color(0xFF121212);

/// Standard elevated surface color.
const Color kSurface = Color(0xFF1E1E1E);

/// Elevated surface variant (higher elevation = lighter).
const Color kSurfaceVariant = Color(0xFF2A2A2A);

/// Electric blue primary accent.
const Color kPrimaryAccent = Color(0xFF4A90D9);

/// Subtle outline color for dark mode dividers and borders.
const Color kOutline = Color(0xFF3A3A3A);

/// Primary text color on dark backgrounds.
const Color kOnSurface = Color(0xFFE0E0E0);

/// Secondary/muted text color.
const Color kOnSurfaceMuted = Color(0xFF9E9E9E);

// ── Voice State Colors ─────────────────────────────────────────────────────

/// Idle state — dim grey.
const Color kVoiceIdle = Color(0xFF4A4A4A);

/// Listening state — cyan pulse.
const Color kVoiceListening = Color(0xFF00BCD4);

/// Thinking state — amber pulse.
const Color kVoiceThinking = Color(0xFFFFB300);

/// Speaking state — green solid.
const Color kVoiceSpeaking = Color(0xFF4CAF50);

/// AI glow gradient colors (cyan/teal).
const Color kGlowCyan = Color(0xFF00BCD4);
const Color kGlowTeal = Color(0xFF009688);

// ── Animation Constants ───────────────────────────────────────────────────

/// Standard transition duration per design spec.
const Duration kThemeAnimationDuration = Duration(milliseconds: 300);

/// Standard easing curve per design spec.
const Curve kThemeAnimationCurve = Curves.easeOut;

// ── ColorScheme ───────────────────────────────────────────────────────────

/// Material 3 dark color scheme for ChronosAI.
ColorScheme get kDarkColorScheme => ColorScheme(
  brightness: Brightness.dark,
  primary: kPrimaryAccent,
  onPrimary: Colors.white,
  primaryContainer: kPrimaryAccent.withValues(alpha: 0.2),
  onPrimaryContainer: kPrimaryAccent,
  secondary: kVoiceListening,
  onSecondary: Colors.black,
  secondaryContainer: kVoiceListening.withValues(alpha: 0.15),
  onSecondaryContainer: kVoiceListening,
  tertiary: kVoiceThinking,
  onTertiary: Colors.black,
  error: Colors.red.shade400,
  onError: Colors.white,
  errorContainer: Colors.red.shade900,
  onErrorContainer: Colors.red.shade100,
  surface: kSurface,
  onSurface: kOnSurface,
  surfaceContainerHighest: kSurfaceVariant,
  outline: kOutline,
  outlineVariant: kOutline.withValues(alpha: 0.5),
  shadow: Colors.black.withValues(alpha: 0.3),
  inverseSurface: kOnSurface,
  onInverseSurface: kSurface,
  inversePrimary: kPrimaryAccent,
);

// ── AI Voice Glow Color Extension ─────────────────────────────────────────

/// Custom theme extension for AI voice glow colors.
@immutable
class AiVoiceGlowColors extends ThemeExtension<AiVoiceGlowColors> {
  final Color idle;
  final Color listening;
  final Color thinking;
  final Color speaking;
  final Color glowCyan;
  final Color glowTeal;

  const AiVoiceGlowColors({
    required this.idle,
    required this.listening,
    required this.thinking,
    required this.speaking,
    required this.glowCyan,
    required this.glowTeal,
  });

  @override
  AiVoiceGlowColors copyWith({
    Color? idle,
    Color? listening,
    Color? thinking,
    Color? speaking,
    Color? glowCyan,
    Color? glowTeal,
  }) {
    return AiVoiceGlowColors(
      idle: idle ?? this.idle,
      listening: listening ?? this.listening,
      thinking: thinking ?? this.thinking,
      speaking: speaking ?? this.speaking,
      glowCyan: glowCyan ?? this.glowCyan,
      glowTeal: glowTeal ?? this.glowTeal,
    );
  }

  @override
  AiVoiceGlowColors lerp(ThemeExtension<AiVoiceGlowColors>? other, double t) {
    if (other is! AiVoiceGlowColors) return this;
    return AiVoiceGlowColors(
      idle: Color.lerp(idle, other.idle, t)!,
      listening: Color.lerp(listening, other.listening, t)!,
      thinking: Color.lerp(thinking, other.thinking, t)!,
      speaking: Color.lerp(speaking, other.speaking, t)!,
      glowCyan: Color.lerp(glowCyan, other.glowCyan, t)!,
      glowTeal: Color.lerp(glowTeal, other.glowTeal, t)!,
    );
  }
}

/// Default AI voice glow colors instance.
const AiVoiceGlowColors kDefaultAiGlowColors = AiVoiceGlowColors(
  idle: kVoiceIdle,
  listening: kVoiceListening,
  thinking: kVoiceThinking,
  speaking: kVoiceSpeaking,
  glowCyan: kGlowCyan,
  glowTeal: kGlowTeal,
);

// ── Text Theme ────────────────────────────────────────────────────────────

/// Builds a readable text theme with Inter/Roboto for dark mode.
TextTheme get kDarkTextTheme => const TextTheme(
  displayLarge: TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  displayMedium: TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  displaySmall: TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  headlineLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  headlineMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  headlineSmall: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  titleLarge: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  titleMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  titleSmall: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: kOnSurfaceMuted,
    fontFamily: 'Inter',
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: kOnSurfaceMuted,
    fontFamily: 'Inter',
  ),
  labelLarge: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: kOnSurface,
    fontFamily: 'Inter',
  ),
  labelMedium: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: kOnSurfaceMuted,
    fontFamily: 'Inter',
  ),
  labelSmall: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: kOnSurfaceMuted,
    fontFamily: 'Inter',
  ),
);

// ── Component Themes ──────────────────────────────────────────────────────

/// Card theme for dark mode surfaces.
CardThemeData get kDarkCardTheme => CardThemeData(
  color: kSurface,
  shadowColor: Colors.black.withValues(alpha: 0.3),
  surfaceTintColor: kPrimaryAccent.withValues(alpha: 0.05),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
);

/// Input decoration theme for dark mode.
InputDecorationTheme get kDarkInputTheme => InputDecorationTheme(
  filled: true,
  fillColor: kSurfaceVariant,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: kOutline),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: kOutline),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: kPrimaryAccent, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.red.shade400),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.red.shade400, width: 2),
  ),
  hintStyle: const TextStyle(color: kOnSurfaceMuted, fontSize: 14),
  labelStyle: const TextStyle(color: kOnSurfaceMuted, fontSize: 14),
);

/// Elevated button theme for dark mode.
ButtonStyle get kDarkElevatedButtonStyle => ElevatedButton.styleFrom(
  backgroundColor: kPrimaryAccent,
  foregroundColor: Colors.white,
  elevation: 2,
  shadowColor: Colors.black.withValues(alpha: 0.3),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  textStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    fontFamily: 'Inter',
  ),
);

/// Text button theme for dark mode.
ButtonStyle get kDarkTextButtonTextStyle => TextButton.styleFrom(
  foregroundColor: kPrimaryAccent,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  textStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
  ),
);

/// Filled button theme data.
FilledButtonThemeData get kDarkFilledButtonTheme => FilledButtonThemeData(
  style: kDarkElevatedButtonStyle,
);

/// Outlined button theme data.
OutlinedButtonThemeData get kDarkOutlinedButtonTheme => OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: kOnSurface,
    side: const BorderSide(color: kOutline),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontFamily: 'Inter',
    ),
  ),
);

// ── Elevation System ──────────────────────────────────────────────────────

/// Dark surface elevation levels.
/// Higher elevation = lighter surface color (Material 3 convention).
Color darkSurfaceAtElevation(int elevation) {
  switch (elevation) {
    case 0:
      return kBackgroundDeep;
    case 1:
      return kSurface;
    case 2:
      return Color.lerp(kSurface, kSurfaceVariant, 0.3)!;
    case 3:
      return Color.lerp(kSurface, kSurfaceVariant, 0.6)!;
    case 4:
      return kSurfaceVariant;
    default:
      return kSurfaceVariant;
  }
}

// ── App Theme Data ────────────────────────────────────────────────────────

/// Builds the complete Material 3 dark theme for ChronosAI.
ThemeData get kChronosDarkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: kDarkColorScheme,
  scaffoldBackgroundColor: kBackgroundDeep,
  textTheme: kDarkTextTheme,
  cardTheme: kDarkCardTheme,
  inputDecorationTheme: kDarkInputTheme,
  filledButtonTheme: kDarkFilledButtonTheme,
  outlinedButtonTheme: kDarkOutlinedButtonTheme,
  appBarTheme: const AppBarTheme(
    backgroundColor: kBackgroundDeep,
    foregroundColor: kOnSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: kOnSurface,
      fontFamily: 'Inter',
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: kSurface,
    indicatorColor: kPrimaryAccent.withValues(alpha: 0.2),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: kPrimaryAccent);
      }
      return const IconThemeData(color: kOnSurfaceMuted);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(color: kPrimaryAccent, fontSize: 12, fontWeight: FontWeight.w500);
      }
      return const TextStyle(color: kOnSurfaceMuted, fontSize: 12);
    }),
  ),
  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1,
  ),
  extensions: const [kDefaultAiGlowColors],
);
