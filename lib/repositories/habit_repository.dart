// Author: K K K Ekanayake
// ChronosAI — Habit repository (CRUD + queries + completion tracking)

import 'package:isar/isar.dart';
import '../models/habit.dart';
import '../services/isar_service.dart';

class HabitRepository {
  final Isar _isar = IsarService.instance.isar;

  Future<int> create(Habit habit) => _isar.habits.put(habit);
  Future<Habit?> getById(int id) => _isar.habits.get(id);
  Future<List<Habit>> getAll() => _isar.habits.where().findAll();
  Future<List<Habit>> getActive() =>
      _isar.habits.filter().statusEqualTo('active').findAll();

  Future<List<Habit>> getTodaysHabits() async {
    final habits = await getActive();
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon, 7=Sun
    return habits.where((h) {
      if (h.targetDays.isEmpty) return true;
      return h.targetDays.contains(weekday);
    }).toList();
  }

  /// Records a completion for the habit, updating streak counters.
  Future<int> recordCompletion(int habitId, DateTime completedAt) async {
    final habit = await getById(habitId);
    if (habit == null) throw StateError('Habit not found: $habitId');

    final lastCompleted = habit.lastCompletedDate;
    int newStreak = habit.streakCount;

    if (lastCompleted != null) {
      final difference = completedAt.difference(lastCompleted).inDays;
      if (difference == 1) {
        newStreak += 1;
      } else if (difference > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final updated = Habit(
      title: habit.title,
      description: habit.description,
      frequency: habit.frequency,
      targetDays: habit.targetDays,
      streakCount: newStreak,
      longestStreak:
          newStreak > habit.longestStreak ? newStreak : habit.longestStreak,
      lastCompletedDate: completedAt,
      createdDate: habit.createdDate,
      status: habit.status,
    );
    updated.id = habit.id;

    return _isar.habits.put(updated);
  }

  Future<bool> delete(int id) => _isar.habits.delete(id);
  Future<int> update(Habit habit) async => await _isar.habits.put(habit);
  Future<int> count() => _isar.habits.count();
}
