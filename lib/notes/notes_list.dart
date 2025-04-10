// The University of Texas at El Paso
// Bryan Perez

import 'dart:io' show stdout;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notes_model.dart';
import 'notes_db_worker.dart';
import '../utils/utils.dart' as utils;
import 'note.dart';

/// A widget that displays a list of notes.
///
/// This widget leverages the [NotesModel] to present a list of notes and facilitates
/// navigation to the [NotesEntry] screen for editing or deleting notes.
class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesModel>(
      builder: (BuildContext context, NotesModel model, Widget? child) {
        // Display a placeholder if the list is empty.
        if (model.entityList.isEmpty) {
          return const Center(
            child: Text(
              "No notes yet. Tap the + button to add a note.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Build a list of notes with lazy loading.
        return ListView.builder(
          itemCount: model.entityList.length,
          itemBuilder: (BuildContext context, int index) {
            final note = model.entityList[index];
            // Wrap each note in a Dismissible widget for swipe-to-delete functionality.
            return Dismissible(
              key: ValueKey(note.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => _handleDismiss(context, model, note),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  tileColor: utils.Utils.parseColor(note.color),
                  onTap: () => _handleTap(context, model, note),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Handles swipe-to-delete actions.
  void _handleDismiss(BuildContext context, NotesModel model, Note note) async {
    stdout.writeln("## NotesList: Dismissing note: $note");
    try {
      // Delete note and reload data.
      await NotesDBWorker.db.delete(note.id!);
      await model.loadData("notes", NotesDBWorker.db);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Note deleted"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      stdout.writeln("## NotesList: Error deleting note: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to delete note: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Handles tap actions on a note, setting it for editing.
  void _handleTap(BuildContext context, NotesModel model, Note note) {
    stdout.writeln("## NotesList: Tapped note: $note");
    model.setEntityBeingEdited(note);
    model.setStackIndex(1);
  }
}


