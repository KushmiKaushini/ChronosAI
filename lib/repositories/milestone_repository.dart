// Author: K K K Ekanayake
// ChronosAI — Milestone repository (CRUD + queries)

import 'package:isar/isar.dart';
import '../models/milestone.dart';
import '../services/isar_service.dart';

class MilestoneRepository {
  final Isar _isar = IsarService.instance.isar;

  Future<int> create(Milestone milestone) => _isar.milestones.put(milestone);
  Future<Milestone?> getById(int id) => _isar.milestones.get(id);
  Future<List<Milestone>> getAll() => _isar.milestones.where().findAll();
  Future<List<Milestone>> getByGoalId(int goalId) async {
    final all = await getAll();
    return all.where((m) => m.goal.value?.id == goalId).toList();
  }

  Future<List<Milestone>> getOverdue() async {
    final now = DateTime.now();
    final allBeforeNow = await _isar.milestones
        .filter()
        .dueDateLessThan(now)
        .findAll();
    return allBeforeNow.where((m) => m.status != 'completed').toList();
  }

  Future<bool> delete(int id) => _isar.milestones.delete(id);
  Future<int> update(Milestone milestone) async =>
      await _isar.milestones.put(milestone);
  Future<int> count() => _isar.milestones.count();
}
