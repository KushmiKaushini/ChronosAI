// Author: K K K Ekanayake
// ChronosAI — UserProfile model (Isar collection)

import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  String personaType;
  bool onboardingComplete;
  DateTime createdDate;
  DateTime lastActiveDate;
  String voicePreference;

  UserProfile({
    required this.personaType,
    this.onboardingComplete = false,
    required this.createdDate,
    required this.lastActiveDate,
    this.voicePreference = 'voice_primary',
  });
}
