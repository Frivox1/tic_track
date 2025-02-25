import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/label.dart';
import '../services/hive_service.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
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
    _selectedLabel = HiveService.getLabelByName(widget.task.label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de la tâche',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDeleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Titre', Icons.title),
              SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                'Description',
                Icons.description,
                maxLines: 3,
              ),
              SizedBox(height: 24),
              _buildLabelDropdown(),
              SizedBox(height: 24),
              _buildDatePicker(),
              SizedBox(height: 24),
              _buildStatusChip(),
              SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildLabelDropdown() {
    return ValueListenableBuilder<Box<Label>>(
      valueListenable: HiveService.getLabelBox().listenable(),
      builder: (context, box, _) {
        final labels = box.values.toList();
        return DropdownButtonFormField<Label>(
          value: _selectedLabel,
          decoration: InputDecoration(
            labelText: 'Étiquette',
            prefixIcon: Icon(Icons.label),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          onChanged: (Label? newValue) {
            setState(() {
              _selectedLabel = newValue;
            });
          },
          items:
              labels.map<DropdownMenuItem<Label>>((Label label) {
                return DropdownMenuItem<Label>(
                  value: label,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(label.color),
                        radius: 10,
                      ),
                      SizedBox(width: 10),
                      Text(label.name),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date d\'échéance',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        child: Text(
          DateFormat('dd MMM yyyy à HH:mm').format(_dueDate),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        'Statut: ${widget.task.status}',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: _getStatusColor(widget.task.status),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTask,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Enregistrer les modifications',
            style: TextStyle(fontSize: 18),
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );
      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveTask() {
    if (_selectedLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une étiquette')),
      );
      return;
    }
    widget.task.title = _titleController.text;
    widget.task.description = _descriptionController.text;
    widget.task.label = _selectedLabel!.name;
    widget.task.dueDate = _dueDate;
    HiveService.updateTask(widget.task);
    Navigator.pop(context);
  }

  void _confirmDeleteTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteTask();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask() {
    HiveService.deleteTask(widget.task);
    Navigator.of(context).pop(); // Retour à l'écran précédent
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'to do':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
