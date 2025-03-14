import 'package:hive_ce/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 3)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  Note({required this.title, required this.content});
}
