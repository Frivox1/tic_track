import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/label.dart';
import '../models/category.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
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
          _buildAddLabelSection(),
          SizedBox(height: 16),
          Expanded(child: _buildLabelList()),
        ],
      ),
    );
  }

  Widget _buildAddLabelSection() {
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
            value: _selectedCategory,
            hint: Text('Choose a category for this label'),
            onChanged: (Category? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            items:
                HiveService.getCategoryBox().values
                    .map<DropdownMenuItem<Category>>((Category category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name),
                      );
                    })
                    .toList(),
          ),
          SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _addLabel,
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

  Widget _buildLabelList() {
    return ValueListenableBuilder<Box<Label>>(
      valueListenable: HiveService.getLabelBox().listenable(),
      builder: (context, box, _) {
        final labels = box.values.toList();
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
              trailing: IconButton(
                icon: Icon(Icons.close, size: 18),
                onPressed: () => _deleteLabel(label),
                color: Colors.grey,
              ),
            );
          },
        );
      },
    );
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

  void _addLabel() {
    if (_labelController.text.isNotEmpty && _selectedCategory != null) {
      final newLabel = Label(
        name: _labelController.text,
        color: _selectedColor.value,
        categoryId: _selectedCategory!.key as int,
      );
      HiveService.addLabel(newLabel);
      _selectedCategory!.labelIds.add(newLabel.key.toString());
      HiveService.updateCategory(_selectedCategory!);
      _labelController.clear();
      setState(() {
        _selectedColor = Colors.blue;
        _selectedCategory = null;
      });
    }
  }

  void _deleteLabel(Label label) {
    HiveService.deleteLabel(label);
  }
}
