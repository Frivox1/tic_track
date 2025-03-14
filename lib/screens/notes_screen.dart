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
                width: MediaQuery.of(context).size.width * 0.5,
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
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Title',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Content',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
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

  void _editNote(Note note, int index) {
    TextEditingController titleController = TextEditingController(
      text: note.title,
    );
    TextEditingController contentController = TextEditingController(
      text: note.content,
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Note',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: contentController,
                      maxLines: null,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Content',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedNote = Note(
                          title: titleController.text,
                          content: contentController.text,
                        );
                        await HiveService.updateNote(index, updatedNote);
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ), // Limite la largeur de la liste
            child: ValueListenableBuilder(
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
                return Column(
                  children: [
                    SizedBox(height: 60),
                    Expanded(
                      child: ListView.builder(
                        itemCount: box.length,
                        itemBuilder: (context, index) {
                          final note = box.getAt(index);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                title: Text(
                                  note?.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  note?.content ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _editNote(note!, index),
                                trailing: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => _deleteNote(note!),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
        tooltip: 'New Note',
      ),
    );
  }
}
