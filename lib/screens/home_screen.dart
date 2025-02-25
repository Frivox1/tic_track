import 'package:flutter/material.dart';
import '../widgets/task_card.dart';
import '../services/hive_service.dart';
import '../models/task.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kanban Board')),
      body: Row(
        children: [
          _buildColumn('To Do'),
          _buildColumn('In Progress'),
          _buildColumn('Done'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildColumn(String status) {
    return Expanded(
      child: Column(
        children: [
          Text(
            status,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<Task>>(
              valueListenable: HiveService.getTaskBox().listenable(),
              builder: (context, box, _) {
                final tasks =
                    box.values.where((task) => task.status == status).toList();
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => TaskCard(task: tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        String label = '';
        DateTime dueDate = DateTime.now();

        return AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: 'Title'),
                  onChanged: (value) => title = value,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Description'),
                  onChanged: (value) => description = value,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Label'),
                  onChanged: (value) => label = value,
                ),
                ElevatedButton(
                  child: Text('Due Date: ${dueDate.toString().split(' ')[0]}'),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2026),
                    );
                    if (picked != null) dueDate = picked;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (title.isNotEmpty) {
                  final newTask = Task(
                    title: title,
                    description: description,
                    label: label,
                    dueDate: dueDate,
                  );
                  HiveService.addTask(newTask);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
