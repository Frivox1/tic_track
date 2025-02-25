import 'package:hive_ce/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late String label;

  @HiveField(3)
  late DateTime dueDate;

  @HiveField(4)
  late String status;

  Task({
    required this.title,
    required this.description,
    required this.label,
    required this.dueDate,
    this.status = 'To Do',
  });
}
