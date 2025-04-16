import '../base_model.dart';
import 'voice_note.dart';
import 'voice_notes_db_worker.dart';

/// A state management class for voice notes.
///
/// This class is responsible for interacting with the database,
/// maintaining the list of voice notes, and tracking the currently
/// edited voice note.
class VoiceNotesModel extends BaseModel<VoiceNote> {
  /// Constructs the [VoiceNotesModel].
  ///
  /// It uses the base model to initialize with the [VoiceNote] type.
  VoiceNotesModel();

  /// Loads all voice notes from the database and notifies listeners.
  ///
  /// This method should be called when the UI needs to refresh.
  @override
  Future<void> loadData(String entityType, dynamic db) async {
    entityList = await VoiceNotesDBWorker.db.getAll();
    notifyListeners();
  }

  /// Sets the voice note that is currently being edited.
  ///
  /// This enables the editing screen to be pre-populated.
  @override
  void setEntityBeingEdited(VoiceNote voiceNote) {
    entityBeingEdited = voiceNote.copyWith();
    notifyListeners();
  }

  /// Clears the current entity being edited.
  ///
  /// Call this when the edit session is canceled or saved.
  @override
  void clearEntityBeingEdited() {
    entityBeingEdited = null;
    notifyListeners();
  }

  /// Deletes a voice note from the database and updates the UI.
  ///
  /// Removes the item from both the database and the local model list.
  Future<void> delete(int id) async {
    await VoiceNotesDBWorker.db.delete(id);
    entityList.removeWhere((vn) => vn.id == id);
    notifyListeners();
  }
}