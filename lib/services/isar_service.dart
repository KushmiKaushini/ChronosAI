// Author: K K K Ekanayake
// ChronosAI — Isar database service (singleton)

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/goal.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/milestone.dart';
import '../models/user_profile.dart';

/// Singleton service managing the Isar database instance.
///
/// Provides a global [Isar] instance with all ChronosAI collection schemas
/// registered. Call [IsarService.initialize] once at app startup.
class IsarService {
  IsarService._();

  static final IsarService instance = IsarService._();

  Isar? _isar;

  /// The global Isar instance.
  ///
  /// Throws [StateError] if accessed before [initialize] completes.
  Isar get isar {
    if (_isar == null) {
      throw StateError('IsarService not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  /// Whether the Isar instance has been opened.
  bool get isInitialized => _isar != null;

  /// Opens the Isar database with all collection schemas.
  ///
  /// Safe to call multiple times — subsequent calls return immediately
  /// if already initialized.
  Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        GoalSchema,
        MilestoneSchema,
        HabitSchema,
        JournalEntrySchema,
        UserProfileSchema,
      ],
      directory: dir.path,
      name: 'chronosai',
    );
  }

  /// Closes and disposes the Isar instance.
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
