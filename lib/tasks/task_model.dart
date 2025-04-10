// The University of Texas at El Paso
// Bryan Perez

import '../base_model.dart';
import 'task.dart';
import 'task_db_worker.dart';

/// The model for managing tasks in the FlutterBook app.
///
/// This class extends [BaseModel] to manage a list of tasks, the task being edited,
/// and navigation between the list and entry views.
class TaskModel extends BaseModel<Task> {
  /// Creates an instance of [TaskModel].
  ///
  /// This constructor is used by the Provider for state management.
  TaskModel();

  /// Loads all tasks from the database.
  ///
  /// This method retrieves all tasks and notifies listeners to update the UI.
  @override
  Future<void> loadData(String entityType, dynamic database) async {
    entityList = await TasksDBWorker.db.getAll();
    notifyListeners();
  }

  /// Creates a new task in the database and updates the model.
  ///
  /// @param task The task to add.
  Future<void> create(Task task) async {
    int id = await TasksDBWorker.db.create(task);
    final newTask = task.copyWith(id: id);
    entityList.add(newTask);
    notifyListeners();
  }

  /// Updates an existing task in the database and model.
  ///
  /// @param task The updated task.
  Future<void> update(Task task) async {
    await TasksDBWorker.db.update(task);
    int index = entityList.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      entityList[index] = task;
    }
    notifyListeners();
  }

  /// Deletes a task from the database and model.
  ///
  /// @param id The ID of the task to remove.
  Future<void> delete(int id) async {
    await TasksDBWorker.db.delete(id);
    entityList.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Clears the currently edited task.
  ///
  /// This helps reset state when canceling or completing edits.
  @override
  void clearEntityBeingEdited() {
    entityBeingEdited = null;
    notifyListeners();
  }

  /// Sets the currently edited task using a copy.
  ///
  /// This ensures UI state is not bound directly to the list model.
  @override
  void setEntityBeingEdited(Task task) {
    entityBeingEdited = task.copyWith();
    notifyListeners();
  }
}

