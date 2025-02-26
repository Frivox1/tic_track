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
        forceMaterialTransparency: true,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: MediaQuery.of(context).size.height * 0.7,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  // Utilisation d'un Stack
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add a new task',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title TextField
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Title',
                              hintStyle: const TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            onChanged: (value) => title = value,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Description',
                              hintStyle: const TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            maxLines: 2,
                            onChanged: (value) => description = value,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ValueListenableBuilder<Box<Label>>(
                            valueListenable:
                                HiveService.getLabelBox().listenable(),
                            builder: (context, box, _) {
                              final labels = box.values.toList();
                              return DropdownButton<Label>(
                                value: selectedLabel,
                                hint: const Text(
                                  'Choose a label',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                isExpanded: true,
                                underline: SizedBox(),
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
                                              backgroundColor: Color(
                                                label.color,
                                              ),
                                              radius: 6,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(label.name),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Due date button
                        ElevatedButton(
                          child: Text(
                            'Due date: ${_formatDateTime(dueDate)}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
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
                      ],
                    ),
                    Positioned(
                      bottom: 10,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
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
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
