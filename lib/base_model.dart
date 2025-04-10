// The University of Texas at El Paso
// Bryan Perez

import 'dart:io' show stdout;
import 'package:flutter/foundation.dart';
import '../utils/db_worker.dart';

/// Base class that the model for all entities extends.
///
/// This generic class manages the state for a list of entities of type [T],
/// navigation between views, and editing of entities. Listeners are notified
/// whenever the state changes.
class BaseModel<T> extends ChangeNotifier {
  /// The index for the currently active view (e.g., list view or entry view).
  ///
  /// Typically, 0 represents the list view, and 1 represents the entry view.
  int stackIndex = 0;

  /// The list of entities currently loaded in the model.
  List<T> entityList = [];

  /// The entity currently being edited.
  T? entityBeingEdited;

  /// The date chosen by the user, for example in MM/DD/YYYY format.
  String? chosenDate;

  /// Sets the entity to be edited and notifies listeners.
  ///
  /// [entity] is the entity to set as being edited.
  void setEntityBeingEdited(T entity) {
    stdout.writeln("## BaseModel.setEntityBeingEdited(): entity = $entity");
    entityBeingEdited = entity;
    notifyListeners();
  }

  /// Sets the chosen date and notifies listeners.
  ///
  /// [date] must be provided in MM/DD/YYYY format.
  void setChosenDate(String date) {
    stdout.writeln("## BaseModel.setChosenDate(): date = $date");
    chosenDate = date;
    notifyListeners();
  }

  /// Loads data from the database for the specified entity type.
  ///
  /// [entityType] indicates the type of entity being loaded (e.g., "notes").
  /// [database] is the database worker instance for fetching data.
  Future<void> loadData(String entityType, DBWorker<T> database) async {
    stdout.writeln("## ${entityType}Model.loadData()");
    // Load entities from the database.
    entityList = await database.getAll();
    // Notify listeners that the data has been updated.
    notifyListeners();
  }

  /// Sets the stack index for navigation between views and notifies listeners.
  ///
  /// [stackIndex] is the index of the view to display (e.g., 0 for list view, 1 for entry view).
  void setStackIndex(int stackIndex) {
    stdout.writeln("## BaseModel.setStackIndex(): stackIndex = $stackIndex");
    this.stackIndex = stackIndex;
    notifyListeners();
  }

  /// Clears the currently edited entity and notifies listeners.
  void clearEntityBeingEdited() {
    stdout.writeln("## BaseModel.clearEntityBeingEdited()");
    entityBeingEdited = null;
    notifyListeners();
  }
}
