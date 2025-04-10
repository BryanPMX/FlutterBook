// The University of Texas at El Paso
// Bryan Perez

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notes_db_worker.dart';
import 'notes_model.dart';
import '../utils/utils.dart' as utils;
import 'note.dart';

/// A widget that provides a form to input a note's title, content, and color,
/// and allows saving the note to the database.
class NotesEntry extends StatefulWidget {
  /// Creates a [NotesEntry] widget.
  const NotesEntry({super.key});

  @override
  NotesEntryState createState() => NotesEntryState();
}

class NotesEntryState extends State<NotesEntry> {
  /// Controller for the title text field.
  final TextEditingController _titleEditingController = TextEditingController();

  /// Controller for the content text field.
  final TextEditingController _contentEditingController = TextEditingController();

  /// A key that uniquely identifies the form and allows for form validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// The ID of the note whose data is currently loaded into the text controllers.
  int? _currentLoadedNoteId;

  @override
  void initState() {
    super.initState();
    // Load initial data after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  /// Loads note data into the text controllers if needed.
  void _loadInitialData() {
    final notesModel = Provider.of<NotesModel>(context, listen: false);
    final note = notesModel.entityBeingEdited;
    if (note != null) {
      _titleEditingController.text = note.title;
      _contentEditingController.text = note.content;
      _currentLoadedNoteId = note.id;
    } else {
      _titleEditingController.clear();
      _contentEditingController.clear();
      _currentLoadedNoteId = null;
    }
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _contentEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesModel>(
      builder: (context, notesModel, child) {
        // If the selected note has changed, update the text controllers.
        final note = notesModel.entityBeingEdited;
        if (note != null && note.id != _currentLoadedNoteId) {
          _titleEditingController.text = note.title;
          _contentEditingController.text = note.content;
          _currentLoadedNoteId = note.id;
        }
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Row(
              children: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    notesModel.setStackIndex(0);
                  },
                ),
                const Spacer(),
                TextButton(
                  child: const Text("Save"),
                  onPressed: () => _save(context, notesModel),
                ),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.title),
                  title: TextFormField(
                    controller: _titleEditingController,
                    decoration: const InputDecoration(hintText: "Title"),
                    validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? "Please enter a title" : null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.content_paste),
                  title: TextFormField(
                    controller: _contentEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 8,
                    decoration: const InputDecoration(hintText: "Content"),
                    validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? "Please enter content" : null,
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.color_lens),
                  title: ColorPicker(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Saves or updates the note after writing current field values back into it.
  Future<void> _save(BuildContext context, NotesModel model) async {
    if (!_formKey.currentState!.validate()) return;

    if (model.entityBeingEdited == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: No note to save"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Create an updated copy of the note with the current text field values.
    final updatedNote = model.entityBeingEdited!.copyWith(
      title: _titleEditingController.text,
      content: _contentEditingController.text,
    );
    // Update the model with the new note.
    model.setEntityBeingEdited(updatedNote);

    try {
      final isCreating = updatedNote.id == null;
      if (isCreating) {
        await NotesDBWorker.db.create(updatedNote);
      } else {
        await NotesDBWorker.db.update(updatedNote);
      }
      await model.loadData("notes", NotesDBWorker.db);
      model.setStackIndex(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Note saved"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to save note: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

/// A widget for selecting the color of a note.
class ColorPicker extends StatelessWidget {
  /// Creates a [ColorPicker] widget.
  const ColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesModel>(
      builder: (context, model, child) {
        return Row(
          children: Note.allowedColors.map((colorName) {
            final color = utils.Utils.parseColor(colorName);
            return Expanded(
              child: GestureDetector(
                onTap: () => model.setColor(colorName),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: ShapeDecoration(
                    shape: Border.all(color: color!, width: 18) +
                        Border.all(
                          width: 6,
                          color: model.color == colorName
                              ? color
                              : Theme.of(context).canvasColor,
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}


