import 'package:flutter/material.dart';
import '../widgets/task_card.dart';
import '../services/hive_service.dart';
import '../models/task.dart';
import '../models/label.dart';
import '../screens/task_detail_screen.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
              'Kanban Board',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          _buildColumn('To Do', context),
          _buildColumn('In Progress', context),
          _buildColumn('Done', context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildColumn(String status, BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 40.0, bottom: 8.0),
            child: Text(
              status,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              builder: (context, candidateData, rejectedData) {
                return ValueListenableBuilder<Box<Task>>(
                  valueListenable: HiveService.getTaskBox().listenable(),
                  builder: (context, box, _) {
                    final tasks =
                        box.values
                            .where((task) => task.status == status)
                            .toList();
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _buildDraggableTaskCard(tasks[index], context);
                      },
                    );
                  },
                );
              },
              onAccept: (Task task) {
                task.status = status;
                HiveService.updateTask(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTaskCard(Task task, BuildContext context) {
    return Draggable<Task>(
      data: task,
      child: TaskCard(task: task, onTap: () => _openTaskDetails(context, task)),
      feedback: SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Material(elevation: 4.0, child: TaskCard(task: task)),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: TaskCard(task: task)),
    );
  }

  void _openTaskDetails(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
  }

  void _addTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        Label? selectedLabel;
        DateTime dueDate = DateTime.now();

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Ajouter une nouvelle tâche',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Titre',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                          style: const TextStyle(color: Colors.black),
                          onChanged: (value) => title = value,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Description',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                          style: const TextStyle(color: Colors.black),
                          maxLines: 3, // Limite le nombre de lignes visibles
                          onChanged: (value) => description = value,
                        ),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<Box<Label>>(
                          valueListenable:
                              HiveService.getLabelBox().listenable(),
                          builder: (context, box, _) {
                            final labels = box.values.toList();
                            return DropdownButton<Label>(
                              value: selectedLabel,
                              hint: const Text(
                                'Choisir un label',
                                style: TextStyle(color: Colors.black),
                              ),
                              isExpanded: true,
                              onChanged: (Label? value) {
                                setState(() {
                                  selectedLabel = value;
                                });
                              },
                              items:
                                  labels.map<DropdownMenuItem<Label>>((
                                    Label label,
                                  ) {
                                    return DropdownMenuItem<Label>(
                                      value: label,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Color(label.color),
                                            radius: 10,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            label.name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          child: Text(
                            'Date et heure d\'échéance: ${_formatDateTime(dueDate)}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: dueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2026),
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      dueDate,
                                    ),
                                  );
                              if (pickedTime != null) {
                                setState(() {
                                  dueDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: const Text(
                                'Annuler',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text(
                                'Ajouter',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                if (title.isNotEmpty && selectedLabel != null) {
                                  final newTask = Task(
                                    title: title,
                                    description: description,
                                    label: selectedLabel!.name,
                                    dueDate: dueDate,
                                    status: 'To Do',
                                  );
                                  HiveService.addTask(newTask);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
