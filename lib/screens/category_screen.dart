import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/category.dart';
import '../models/label.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
        ),
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          _buildAddCategorySection(),
          SizedBox(height: 16),
          Expanded(child: _buildCategoryList()),
        ],
      ),
    );
  }

  Widget _buildAddCategorySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _categoryController,
            maxLength: 12,
            decoration: InputDecoration(
              hintText: 'New category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.05),
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _addCategory,
            icon: Icon(Icons.add, color: Colors.black),
            label: Text(
              'Create the category',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return ValueListenableBuilder<Box<Category>>(
      valueListenable: HiveService.getCategoryBox().listenable(),
      builder: (context, box, _) {
        final categories = box.values.toList();
        return ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (context, index) => Divider(height: 0.8),
          itemBuilder: (context, index) {
            final category = categories[index];
            return ExpansionTile(
              title: Text(
                category.name,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, size: 22),
                    onPressed: () => _deleteCategory(category),
                    color: Colors.grey,
                  ),
                ],
              ),
              children: [_buildLabelList(category)],
            );
          },
        );
      },
    );
  }

  Widget _buildLabelList(Category category) {
    return ValueListenableBuilder<Box<Label>>(
      valueListenable: HiveService.getLabelBox().listenable(),
      builder: (context, box, _) {
        final labels =
            box.values
                .where((label) => label.categoryId == category.key)
                .toList();
        return Column(
          children:
              labels
                  .map(
                    (label) => ListTile(
                      title: Text(label.name),
                      leading: CircleAvatar(
                        backgroundColor: Color(label.color),
                        radius: 10,
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  void _addCategory() {
    if (_categoryController.text.isNotEmpty) {
      final newCategory = Category(
        name: _categoryController.text,
        labelIds: [],
      );
      HiveService.addCategory(newCategory);
      _categoryController.clear();
    }
  }

  void _deleteCategory(Category category) {
    HiveService.deleteCategory(category);
  }
}
