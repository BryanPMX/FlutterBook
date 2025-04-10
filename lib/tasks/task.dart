/// A class representing a Task entity in the FlutterBook app.
///
/// This class defines the structure of a task, including its id, description,
/// due date, and completion status.
class Task {
  int? id;
  final String description;
  final String dueDate;
  final bool isComplete;

  /// Constructor for creating a new Task instance.
  Task({
    this.id,
    required String description,
    required String dueDate,
    this.isComplete = false,
  })  : description = description.trim(),
        dueDate = dueDate.trim();

  /// Creates a copy of this task with updated fields.
  ///
  /// Used for updating a task while preserving immutability.
  Task copyWith({
    int? id,
    String? description,
    String? dueDate,
    bool? isComplete,
  }) {
    return Task(
      id: id ?? this.id,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Converts the task to a map for database storage.
  ///
  /// This is useful for database operations, such as saving to SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'dueDate': dueDate,
      'isComplete': isComplete ? 1 : 0,
    };
  }

  /// Creates a [Task] instance from a map.
  ///
  /// This is useful for retrieving a task from the database.
  factory Task.fromMap(Map<String, dynamic> map) {
    if (map['description'] is! String || map['description'].toString().trim().isEmpty) {
      throw ArgumentError('Invalid or missing description in task map');
    }
    if (map['dueDate'] is! String || map['dueDate'].toString().trim().isEmpty) {
      throw ArgumentError('Invalid or missing due date in task map');
    }

    return Task(
      id: map['id'] as int?,
      description: map['description'] as String,
      dueDate: map['dueDate'] as String,
      isComplete: (map['isComplete'] as int) == 1,
    );
  }

  @override
  String toString() {
    return '{ id=$id, description=$description, dueDate=$dueDate, isComplete=$isComplete }';
  }
}
