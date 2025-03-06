import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/label.dart';
import '../providers/app_state_provider.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  Label? _selectedLabel;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _dueDate = widget.task.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        _selectedLabel = appState.getLabelByName(widget.task.label);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 120,
            title: const Text(
              'Task Details',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            forceMaterialTransparency: true,
            surfaceTintColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitleField(_titleController, 'Title'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _descriptionController,
                      'Description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildLabelAndCategory(appState),
                    const SizedBox(height: 20),
                    _buildDatePicker(),
                    const SizedBox(height: 24),
                    _buildStatusChip(),
                    const SizedBox(height: 32),
                    _buildSaveAndDeleteButtons(appState),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          maxLength: 12,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          maxLength: 80,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildLabelAndCategory(AppStateProvider appState) {
    final labels = appState.labels;
    return Row(
      children: [
        Expanded(child: _buildLabelSection(labels, appState)),
        const SizedBox(width: 16),
        Expanded(child: _buildCategorySection(appState)),
      ],
    );
  }

  Widget _buildLabelSection(List<Label> labels, AppStateProvider appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Label',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              menuTheme: MenuThemeData(
                style: MenuStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // ✅ Ajout du BorderRadius
                    ),
                  ),
                ),
              ),
            ),
            child: DropdownButtonFormField<Label>(
              value: labels.contains(_selectedLabel) ? _selectedLabel : null,
              dropdownColor: Colors.grey[100],
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
              ),
              onChanged: (Label? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLabel = newValue;
                  });
                  appState.updateTask(widget.task, newLabel: newValue);
                }
              },
              items:
                  labels.map((Label label) {
                    return DropdownMenuItem<Label>(
                      value: label,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(label.color),
                            radius: 6,
                          ),
                          SizedBox(width: 8),
                          Text(label.name),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(AppStateProvider appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _selectedLabel != null
                ? appState.getCategory(_selectedLabel!.categoryId)?.name ??
                    'No Category'
                : 'Select a label',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Due Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            DateFormat('dd MMM yyyy').format(_dueDate),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: _getStatusColor(widget.task.status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.task.status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          _daysRemaining(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveAndDeleteButtons(AppStateProvider appState) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _confirmDeleteTask(appState),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.red,
                textStyle: TextStyle(fontSize: 18),
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (states) =>
                      states.contains(MaterialState.hovered)
                          ? Colors.red
                          : Colors.transparent,
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (states) =>
                      states.contains(MaterialState.hovered)
                          ? Colors.white
                          : Colors.red,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Delete Task'),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _saveTask(appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'To Do':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _daysRemaining() {
    final now = DateTime.now();
    final difference = _dueDate.difference(now).inDays;

    if (difference > 0) {
      return '${difference + 1} days remaining';
    } else if (difference == 0) {
      return 'Today';
    } else {
      return 'Overdue by ${difference.abs()} days';
    }
  }

  void _saveTask(AppStateProvider appState) {
    widget.task
      ..title = _titleController.text
      ..description = _descriptionController.text
      ..label = _selectedLabel?.name ?? 'Unknown'
      ..dueDate = _dueDate;
    appState.updateTask(widget.task).then((_) {
      setState(() {});
      Navigator.pop(context);
    });
  }

  void _confirmDeleteTask(AppStateProvider appState) {
    appState.deleteTask(widget.task);
    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }
}
