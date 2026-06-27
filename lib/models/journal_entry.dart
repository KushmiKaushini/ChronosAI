// Author: K K K Ekanayake
// ChronosAI — JournalEntry model (Isar collection)

import 'package:isar/isar.dart';
import 'goal.dart';

part 'journal_entry.g.dart';

@collection
class JournalEntry {
  Id id = Isar.autoIncrement;

  String content;
  DateTime createdDate;
  String? moodTag;
  final goal = IsarLink<Goal>();

  JournalEntry({
    required this.content,
    required this.createdDate,
    this.moodTag,
  });
}
