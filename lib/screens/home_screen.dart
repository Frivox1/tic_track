import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import '../screens/task_detail_screen.dart';
import '../providers/app_state_provider.dart';
import '../models/label.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              const double minColumnWidth = 300;
              const int columnCount = 3;
              final double availableWidth = constraints.maxWidth;
              final double columnWidth =
                  availableWidth / columnCount > minColumnWidth
                      ? availableWidth / columnCount
                      : minColumnWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumn('To Do', context, appState, columnWidth),
                    _buildColumn('In Progress', context, appState, columnWidth),
                    _buildColumn('Done', context, appState, columnWidth),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addTask(context, appState),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildColumn(
    String status,
    BuildContext context,
    AppStateProvider appState,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 40.0,
              bottom: 8.0,
              right: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (status == 'Done')
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => _sureToDeleteAllDoneTasks(context),
                  )
                else
                  // Réserve l'espace du bouton pour éviter le décalage des tâches
                  const SizedBox(height: 40),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              builder: (context, candidateData, rejectedData) {
                final tasks =
                    appState.tasks
                        .where((task) => task.status == status)
                        .toList();

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          candidateData.isNotEmpty
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _buildDraggableTaskCard(
                          tasks[index],
                          context,
                          appState,
                        );
                      },
                    ),
                  ),
                );
              },
              onAccept: (Task task) {
                task.status = status;
                appState.updateTask(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTaskCard(
    Task task,
    BuildContext context,
    AppStateProvider appState,
  ) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: TaskCard(task: task),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: TaskCard(task: task)),
      child: TaskCard(task: task, onTap: () => _openTaskDetails(context, task)),
    );
  }

  void _openTaskDetails(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
  }

  void _sureToDeleteAllDoneTasks(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete all done tasks?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final appState = Provider.of<AppStateProvider>(
                  context,
                  listen: false,
                );
                _clearDoneTasks(appState);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearDoneTasks(AppStateProvider appState) {
    final doneTasks = appState.tasks.where((task) => task.status == 'Done');
    for (final task in doneTasks) {
      appState.deleteTask(task);
    }
  }

  void _addTask(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        Label? selectedLabel;
        DateTime dueDate = DateTime.now();

        TextEditingController titleController = TextEditingController(
          text: title,
        );
        TextEditingController descriptionController = TextEditingController(
          text: description,
        );

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: const EdgeInsets.all(32.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(context, titleController),
                      const SizedBox(height: 14),
                      _buildTextField(
                        context,
                        descriptionController,
                        'Description',
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                        ),
                        child: Consumer<AppStateProvider>(
                          builder: (context, appState, child) {
                            final labels = appState.labels;
                            return Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Theme.of(context).cardColor,
                              ),
                              child: DropdownButton<Label>(
                                value: selectedLabel,
                                hint: Text(
                                  'Choose a label',
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.color,
                                  ),
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
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        child: Text('Due date: ${_formatDateTime(dueDate)}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
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
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(dueDate),
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (titleController.text.isNotEmpty &&
                                  selectedLabel != null) {
                                final newTask = Task(
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  label: selectedLabel!.name,
                                  dueDate: dueDate,
                                  status: 'To Do',
                                );
                                appState.addTask(newTask);
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTitleField(
    BuildContext context,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      cursorColor: Colors.grey,
      maxLength: 22,
      decoration: InputDecoration(
        labelText: 'Titre',
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).textTheme.bodyMedium!.color!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      cursorColor: Colors.grey,
      maxLength: 100,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).textTheme.bodyMedium!.color!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }
}
