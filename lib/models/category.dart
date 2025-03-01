import 'package:hive_ce/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late List<String> labelIds;

  Category({required this.name, required this.labelIds});
}
