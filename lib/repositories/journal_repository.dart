// Author: K K K Ekanayake
// ChronosAI — JournalEntry repository (CRUD + date-range queries)

import 'package:isar/isar.dart';
import '../models/journal_entry.dart';
import '../services/isar_service.dart';

class JournalRepository {
  final Isar _isar = IsarService.instance.isar;

  IsarCollection<JournalEntry> get _col => _isar.journalEntrys;

  Future<int> create(JournalEntry entry) => _col.put(entry);
  Future<JournalEntry?> getById(int id) => _col.get(id);
  Future<List<JournalEntry>> getAll() => _col.where().findAll();

  Future<List<JournalEntry>> getByDateRange(DateTime start, DateTime end) =>
      _col
          .filter()
          .createdDateBetween(start, end)
          .findAll();

  Future<List<JournalEntry>> getRecent({int limit = 10}) async {
    final all = await _col
        .where()
        .sortByCreatedDateDesc()
        .findAll();
    return all.take(limit).toList();
  }

  Future<bool> delete(int id) => _col.delete(id);
  Future<int> update(JournalEntry entry) async => await _col.put(entry);
  Future<int> count() => _col.count();
}
