// Author: K K K Ekanayake
// ChronosAI — Goal model (Isar collection)

import 'package:isar/isar.dart';
import 'milestone.dart';

part 'goal.g.dart';

@collection
class Goal {
  Id id = Isar.autoIncrement;

  @Index()
  String title;

  String description;
  String category;
  String priority;
  DateTime targetDate;
  DateTime createdDate;
  String status;
  double progress;

  @Backlink(to: 'goal')
  IsarLinks<Milestone> milestones = IsarLinks<Milestone>();

  Goal({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.targetDate,
    required this.createdDate,
    this.status = 'active',
    this.progress = 0.0,
  });
}
