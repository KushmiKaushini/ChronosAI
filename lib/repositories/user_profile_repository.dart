// Author: K K K Ekanayake
// ChronosAI — UserProfile repository for Isar DB operations

import '../models/user_profile.dart';
import '../services/isar_service.dart';

/// Repository for UserProfile CRUD operations against the Isar database.
class UserProfileRepository {
  /// Returns the first user profile, or null if none exists.
  Future<UserProfile?> getProfile() async {
    final isar = IsarService.instance.isar;
    return await isar.userProfiles.where().findFirst();
  }

  /// Checks if onboarding is complete for the current user.
  Future<bool> isOnboardingComplete() async {
    final profile = await getProfile();
    return profile?.onboardingComplete ?? false;
  }

  /// Sets the persona type for the user profile.
  /// Creates a new profile if none exists, otherwise updates the existing one.
  Future<void> setPersona(String personaType) async {
    final isar = IsarService.instance.isar;
    final existing = await getProfile();

    if (existing == null) {
      final now = DateTime.now();
      final profile = UserProfile(
        personaType: personaType,
        createdDate: now,
        lastActiveDate: now,
      );
      await isar.writeTxn(() async {
        await isar.userProfiles.put(profile);
      });
    } else {
      existing.personaType = personaType;
      existing.lastActiveDate = DateTime.now();
      await isar.writeTxn(() async {
        await isar.userProfiles.put(existing);
      });
    }
  }

  /// Marks onboarding as complete.
  Future<void> completeOnboarding() async {
    final isar = IsarService.instance.isar;
    final existing = await getProfile();

    if (existing != null) {
      existing.onboardingComplete = true;
      existing.lastActiveDate = DateTime.now();
      await isar.writeTxn(() async {
        await isar.userProfiles.put(existing);
      });
    }
  }
}
