import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/label.dart';
import '../models/category.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class LabelScreen extends StatefulWidget {
  const LabelScreen({Key? key}) : super(key: key);

  @override
  _LabelScreenState createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final TextEditingController _labelController = TextEditingController();
  Color _selectedColor = Colors.blue;
  Category? _selectedCategory;

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
                  'Labels',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ),
            ),
            forceMaterialTransparency: true,
          ),
          body: Column(
            children: [
              SizedBox(height: 16),
              _buildAddLabelSection(appState),
              SizedBox(height: 16),
              Expanded(child: _buildLabelList(appState)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddLabelSection(AppStateProvider appState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _labelController,
            maxLength: 12,
            decoration: InputDecoration(
              hintText: 'New label',
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
          SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Choose a color',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 16),
              GestureDetector(
                onTap: _openColorPicker,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          DropdownButton<Category>(
            value:
                appState.categories.contains(_selectedCategory)
                    ? _selectedCategory
                    : null, // Remet à null si la catégorie n'existe plus
            hint: Text('Choose a category for this label'),
            onChanged: (Category? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            items:
                appState.categories.map<DropdownMenuItem<Category>>((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
          ),
          SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _addLabel(appState),
            icon: Icon(Icons.add, color: Colors.black),
            label: Text(
              'Create the label',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelList(AppStateProvider appState) {
    final labels = appState.labels;
    return ListView.separated(
      itemCount: labels.length,
      separatorBuilder: (context, index) => Divider(height: 0.8),
      itemBuilder: (context, index) {
        final label = labels[index];
        return ListTile(
          title: Text(
            label.name,
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(label.color),
              shape: BoxShape.circle,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 18),
                onPressed: () => _editLabel(appState, label),
                color: Colors.grey,
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18),
                onPressed: () => _deleteLabel(appState, label),
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  void _editLabel(AppStateProvider appState, Label label) {
    _labelController.text = label.name;
    _selectedColor = Color(label.color);
    _selectedCategory = appState.categories.firstWhere(
      (category) => category.key == label.categoryId,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Label'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _labelController,
                  maxLength: 12,
                  decoration: InputDecoration(
                    hintText: 'Label Name',
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
                SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Choose a color',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: _openColorPicker,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                DropdownButton<Category>(
                  value: _selectedCategory,
                  hint: Text('Choose a category for this label'),
                  onChanged: (Category? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items:
                      appState.categories.map<DropdownMenuItem<Category>>((
                        category,
                      ) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _saveEditedLabel(appState, label);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveEditedLabel(AppStateProvider appState, Label label) {
    if (_labelController.text.isNotEmpty && _selectedCategory != null) {
      label.name = _labelController.text;
      label.color = _selectedColor.value;
      label.categoryId = _selectedCategory!.key as int;
      appState.updateLabel(label);
      _labelController.clear();
      setState(() {
        _selectedColor = Colors.blue;
        _selectedCategory = null;
      });
    }
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Pick a color',
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) {
                  setState(() => _selectedColor = color);
                },
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Done'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _addLabel(AppStateProvider appState) {
    if (_labelController.text.isNotEmpty && _selectedCategory != null) {
      final newLabel = Label(
        name: _labelController.text,
        color: _selectedColor.value,
        categoryId: _selectedCategory!.key as int,
      );
      appState.addLabel(newLabel);
      _labelController.clear();
      setState(() {
        _selectedColor = Colors.blue;
        _selectedCategory = null;
      });
    }
  }

  void _deleteLabel(AppStateProvider appState, Label label) {
    final tasksUsingLabel =
        appState.tasks.where((task) => task.label == label.name).toList();

    if (tasksUsingLabel.isNotEmpty) {
      _showCannotDeleteDialog(label.name, tasksUsingLabel.length);
    } else {
      _showConfirmDeleteDialog(appState, label);
    }
  }

  void _showCannotDeleteDialog(String labelName, int taskCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unable to delete'),
          content: Text(
            'The label "$labelName" is used by $taskCount task(s) and cannot be deleted.',
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

  void _showConfirmDeleteDialog(AppStateProvider appState, Label label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm deletion'),
          content: Text(
            'Are you sure you want to delete the label "${label.name}"?',
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
                appState.deleteLabel(label);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
