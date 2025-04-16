import '../base_model.dart';
import 'contact.dart';
import 'contacts_db_worker.dart';

/// Model class managing the state and data of contacts.
class ContactsModel extends BaseModel<Contact> {
  ContactsModel();

  /// Loads all contacts from the database.
  @override
  Future<void> loadData(String entityType, dynamic db) async {
    entityList = await ContactsDBWorker.db.getAll();
    notifyListeners();
  }

  /// Sets the current contact being edited.
  @override
  void setEntityBeingEdited(Contact contact) {
    entityBeingEdited = contact.copyWith();
    notifyListeners();
  }

  /// Clears the contact currently being edited.
  @override
  void clearEntityBeingEdited() {
    entityBeingEdited = null;
    notifyListeners();
  }

  /// Deletes a contact from the database and updates the model.
  ///
  /// @param id The ID of the contact to remove.
  Future<void> delete(int id) async {
    await ContactsDBWorker.db.delete(id);
    entityList.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}