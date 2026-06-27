// Author: K K K Ekanayake
// ChronosAI — Riverpod providers for app-wide state

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_constants.dart';
import '../repositories/user_profile_repository.dart';

/// Provider for the UserProfileRepository.
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

/// Provider for the currently selected persona during onboarding.
/// Persists to DB when set via the persona screen.
final personaProvider = StateProvider<PersonaType?>((ref) => null);
