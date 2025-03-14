import 'package:flutter/material.dart';
import '../models/note.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../services/hive_service.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  void _addNote() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return FadeTransition(
          opacity: anim1,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width:
                    MediaQuery.of(context).size.width *
                    0.5, // Largeur 50% de l'écran
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New Note',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final newNote = Note(
                              title: titleController.text,
                              content: contentController.text,
                            );
                            await HiveService.addNote(newNote);
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text('Save'),
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
  }

  void _deleteNote(Note note) async {
    await HiveService.deleteNote(note);
    setState(() {});
  }

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
              'Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.getNoteBox().listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No notes yet. Add some!',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final note = box.getAt(index);
              return Card(
                child: ListTile(
                  title: Text(note?.title ?? ''),
                  subtitle: Text(note?.content ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => _deleteNote(note!),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
        tooltip: 'New Note',
      ),
    );
  }
}
