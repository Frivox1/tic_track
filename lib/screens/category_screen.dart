import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
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
              _buildAddCategorySection(appState),
              SizedBox(height: 16),
              Expanded(child: _buildCategoryList(appState)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddCategorySection(AppStateProvider appState) {
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
            onPressed: () => _addCategory(appState),
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

  Widget _buildCategoryList(AppStateProvider appState) {
    final categories = appState.categories;
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
                icon: Icon(Icons.edit, size: 22),
                onPressed: () => _editCategory(appState, category),
                color: Colors.grey,
              ),
              IconButton(
                icon: Icon(Icons.close, size: 22),
                onPressed: () => _deleteCategory(appState, category),
                color: Colors.grey,
              ),
            ],
          ),
          children: [_buildLabelList(appState, category)],
        );
      },
    );
  }

  Widget _buildLabelList(AppStateProvider appState, Category category) {
    final labels =
        appState.labels
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
  }

  void _addCategory(AppStateProvider appState) {
    if (_categoryController.text.isNotEmpty) {
      final newCategory = Category(
        name: _categoryController.text,
        labelIds: [],
      );
      appState.addCategory(newCategory);
      _categoryController.clear();
    }
  }

  void _editCategory(AppStateProvider appState, Category category) {
    _categoryController.text = category.name; // Pré-remplir avec l'ancien nom

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Category'),
          content: TextField(
            controller: _categoryController,
            maxLength: 12,
            decoration: InputDecoration(
              hintText: 'Enter new category name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _saveEditedCategory(appState, category);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveEditedCategory(AppStateProvider appState, Category category) {
    if (_categoryController.text.isNotEmpty) {
      category.name = _categoryController.text;
      appState.updateCategory(category);
      _categoryController.clear();
      setState(() {});
    }
  }

  void _deleteCategory(AppStateProvider appState, Category category) {
    final labels =
        appState.labels
            .where((label) => label.categoryId == category.key)
            .toList();

    if (labels.isNotEmpty) {
      _showCannotDeleteDialog(category.name, labels.length);
    } else {
      _showConfirmDeleteDialog(appState, category);
    }
  }

  void _showCannotDeleteDialog(String categoryName, int labelCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unable to delete'),
          content: Text(
            'The category "$categoryName" cannot be deleted because it contains $labelCount labels.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDeleteDialog(AppStateProvider appState, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text(
            'Do you want to delete the category "${category.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                appState.deleteCategory(category);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
