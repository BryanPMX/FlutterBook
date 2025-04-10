// The University of Texas at El Paso
// Bryan Perez

import '../base_model.dart';
import 'note.dart';
import 'notes_db_worker.dart';

/// The model for managing notes in the FlutterBook app.
/// This class extends [BaseModel] to manage a list of notes, the note being edited,
/// and navigation between the list and entry views.
class NotesModel extends BaseModel<Note> {
  /// The color of the note being edited.
  String? color;

  /// Constructor initializes the model with empty or default values.
  NotesModel() : super() {
    color = 'defaultColor'; // Define a default color if applicable
  }

  /// Sets the color of the note being edited and updates the entity.
  ///
  /// @param color The color to set (e.g., "red", "blue").
  void setColor(String color) {
    this.color = color;
    if (entityBeingEdited != null) {
      entityBeingEdited = entityBeingEdited!.copyWith(color: color);
      notifyListeners(); // Notify widgets to rebuild with the new color
    }
  }

  /// Loads data from the database.
  /// This method is overridden to specify the type of data to load ('Notes') and
  /// the specific database worker to use (NotesDBWorker.db).
  @override
  Future<void> loadData(String entityType, dynamic database) async {
    // Call to the parent class's loadData method to perform the actual data loading.
    await super.loadData("Notes", NotesDBWorker.db);
  }

  /// Sets the current note being edited.
  /// This method clones the provided note and sets it as the entity being edited.
  ///
  /// @param note The note to set as currently being edited.
  @override
  void setEntityBeingEdited(Note note) {
    entityBeingEdited = note.copyWith();
    notifyListeners();  // Notify listeners about the change to update UI.
  }

  /// Resets the entityBeingEdited to null when editing is finished or canceled.
  /// This is essential to prevent stale data from affecting new edits or note creations.
  @override
  void clearEntityBeingEdited() {
    entityBeingEdited = null;
    notifyListeners();  // Notify to reset any bound UI elements.
  }
}




