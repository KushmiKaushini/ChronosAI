// Author: K K K Ekanayake
// ChronosAI — UserProfile repository (singleton-like access)

import 'package:isar/isar.dart';
import '../models/user_profile.dart';
import '../services/isar_service.dart';

class UserProfileRepository {
  final Isar _isar = IsarService.instance.isar;

  /// Returns the existing user profile, or creates a default one if none exists.
  Future<UserProfile> getOrCreate({
    String personaType = 'professional',
    String voicePreference = 'voice_primary',
  }) async {
    final existing = await _isar.userProfiles.where().findFirst();
    if (existing != null) return existing;

    final now = DateTime.now();
    final profile = UserProfile(
      personaType: personaType,
      onboardingComplete: false,
      createdDate: now,
      lastActiveDate: now,
      voicePreference: voicePreference,
    );
    final id = await _isar.userProfiles.put(profile);
    profile.id = id;
    return profile;
  }

  Future<UserProfile?> getById(int id) => _isar.userProfiles.get(id);
  Future<List<UserProfile>> getAll() => _isar.userProfiles.where().findAll();

  /// Updates the persona type on the first profile.
  Future<int> updatePersona(String personaType) async {
    final profile = await getOrCreate();
    final updated = UserProfile(
      personaType: personaType,
      onboardingComplete: profile.onboardingComplete,
      createdDate: profile.createdDate,
      lastActiveDate: profile.lastActiveDate,
      voicePreference: profile.voicePreference,
    );
    updated.id = profile.id;
    return _isar.userProfiles.put(updated);
  }

  /// Alias for [updatePersona] — used by onboarding screens.
  Future<int> setPersona(String personaType) => updatePersona(personaType);

  /// Marks onboarding as complete.
  Future<int> markOnboardingComplete() async {
    final profile = await getOrCreate();
    final updated = UserProfile(
      personaType: profile.personaType,
      onboardingComplete: true,
      createdDate: profile.createdDate,
      lastActiveDate: DateTime.now(),
      voicePreference: profile.voicePreference,
    );
    updated.id = profile.id;
    return _isar.userProfiles.put(updated);
  }

  /// Alias for [markOnboardingComplete] — used by onboarding screens.
  Future<int> completeOnboarding() => markOnboardingComplete();

  /// Checks if onboarding has been completed.
  Future<bool> isOnboardingComplete() async {
    final profile = await _isar.userProfiles.where().findFirst();
    return profile?.onboardingComplete ?? false;
  }

  Future<bool> delete(int id) => _isar.userProfiles.delete(id);
  Future<int> update(UserProfile profile) async =>
      await _isar.userProfiles.put(profile);
  Future<int> count() => _isar.userProfiles.count();
}
