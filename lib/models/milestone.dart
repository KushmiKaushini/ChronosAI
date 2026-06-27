// Author: K K K Ekanayake
// ChronosAI — Milestone model (Isar collection)

import 'package:isar/isar.dart';
import 'goal.dart';

part 'milestone.g.dart';

@collection
class Milestone {
  Id id = Isar.autoIncrement;

  @Index()
  String title;

  String description;
  DateTime dueDate;
  DateTime createdDate;
  String status;
  double progress;

  final goal = IsarLink<Goal>();

  Milestone({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdDate,
    this.status = 'pending',
    this.progress = 0.0,
  });
}
