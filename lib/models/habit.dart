// Author: K K K Ekanayake
// ChronosAI — Habit model (Isar collection)

import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  @Index()
  String title;

  String description;
  String frequency;
  List<int> targetDays;
  int streakCount;
  int longestStreak;
  DateTime? lastCompletedDate;
  DateTime createdDate;
  String status;

  Habit({
    required this.title,
    required this.description,
    required this.frequency,
    required this.targetDays,
    this.streakCount = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    required this.createdDate,
    this.status = 'active',
  });
}
