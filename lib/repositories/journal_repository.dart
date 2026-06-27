// Author: K K K Ekanayake
// ChronosAI — JournalEntry repository (CRUD + date-range queries)

import 'package:isar/isar.dart';
import '../models/journal_entry.dart';
import '../services/isar_service.dart';

class JournalRepository {
  final Isar _isar = IsarService.instance.isar;

  Future<int> create(JournalEntry entry) => _isar.journalEntry.put(entry);
  Future<JournalEntry?> getById(int id) => _isar.journalEntry.get(id);
  Future<List<JournalEntry>> getAll() => _isar.journalEntry.where().findAll();

  Future<List<JournalEntry>> getByDateRange(DateTime start, DateTime end) =>
      _isar.journalEntry
          .filter()
          .createdDateBetween(start, end)
          .findAll();

  Future<List<JournalEntry>> getRecent({int limit = 10}) async {
    final all = await _isar.journalEntry
        .where()
        .sortByCreatedDateDesc()
        .findAll();
    return all.take(limit).toList();
  }

  Future<bool> delete(int id) => _isar.journalEntry.delete(id);
  Future<int> update(JournalEntry entry) async =>
      await _isar.journalEntry.put(entry);
  Future<int> count() => _isar.journalEntry.count();
}
