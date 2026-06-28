// Author: K K K Ekanayake
// ChronosAI — Goal repository (CRUD + queries)

import 'package:isar/isar.dart';
import '../models/goal.dart';
import '../services/isar_service.dart';

class GoalRepository {
  final Isar _isar = IsarService.instance.isar;

  Future<int> create(Goal goal) => _isar.goals.put(goal);
  Future<Goal?> getById(int id) => _isar.goals.get(id);
  Future<List<Goal>> getAll() => _isar.goals.where().findAll();
  Future<List<Goal>> getByStatus(String status) =>
      _isar.goals.filter().statusEqualTo(status).findAll();
  Future<List<Goal>> getWithOverdueMilestones() async {
    final goals = await getAll();
    final now = DateTime.now();
    return goals.where((g) {
      return g.milestones.any(
          (m) => m.dueDate.isBefore(now) && m.status != 'completed');
    }).toList();
  }

  Future<bool> delete(int id) => _isar.goals.delete(id);
  Future<int> update(Goal goal) async => await _isar.goals.put(goal);
  Future<int> count() => _isar.goals.count();

  Future<double> averageProgress() async {
    final goals = await getAll();
    if (goals.isEmpty) return 0.0;
    return goals.map((g) => g.progress).reduce((a, b) => a + b) /
        goals.length;
  }
}
