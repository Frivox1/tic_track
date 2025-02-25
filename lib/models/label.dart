import 'package:hive_ce/hive.dart';

part 'label.g.dart';

@HiveType(typeId: 1)
class Label extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late int color;

  Label({required this.name, required this.color});
}
