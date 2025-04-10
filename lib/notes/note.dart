// The University of Texas at El Paso
// Bryan Perez

/// A class representing a Note entity in the FlutterBook app.
///
/// This class defines the structure of a note, including its [id], [title],
/// [content], and [color]. All fields except [id] are immutable to ensure
/// data consistency.
class Note {
  /// The unique identifier for the note.
  final int? id;

  /// The title of the note.
  final String title;

  /// The content of the note.
  final String content;

  /// The color of the note, represented as a string (e.g., "red", "blue").
  final String color;

  /// The allowed color values for a note.
  static const List<String> allowedColors = [
    'red',
    'green',
    'blue',
    'yellow',
    'grey',
    'purple',
  ];

  /// Creates a [Note] instance.
  ///
  /// The [id] is optional and typically set by the database.
  /// The [title], [content], and [color] are required and must not be empty.
  /// The [color] must be one of the [allowedColors].
  /// @throws ArgumentError if validation fails.
  Note({
    this.id,
    required String title,
    required String content,
    required String color,
  })  : title = title.trim(),
        content = content.trim(),
        color = color.toLowerCase() {
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (content.isEmpty) {
      throw ArgumentError('Content cannot be empty');
    }
    if (!allowedColors.contains(color.toLowerCase())) {
      throw ArgumentError(
          'Color must be one of ${allowedColors.join(', ')}, but was "$color"');
    }
  }

  /// Creates a copy of this note with updated fields.
  ///
  /// Used for updating a note while preserving immutability.
  /// @param id The new ID, or null to keep the current value.
  /// @param title The new title, or null to keep the current value.
  /// @param content The new content, or null to keep the current value.
  /// @param color The new color, or null to keep the current value.
  /// @return A new [Note] instance with the updated fields.
  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
    );
  }

  /// Converts the note to a map for database storage.
  ///
  /// Useful for database operations, such as saving to SQLite.
  /// @return A [Map] representing the note's fields.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
    };
  }

  /// Creates a [Note] instance from a map.
  ///
  /// Useful for retrieving a note from the database.
  /// @param map The [Map] containing the note's data.
  /// @return A new [Note] instance.
  /// @throws ArgumentError if the map contains invalid data.
  factory Note.fromMap(Map<String, dynamic> map) {
    if (map['title'] is! String || (map['title'] as String).trim().isEmpty) {
      throw ArgumentError('Invalid or missing title in map: ${map['title']}');
    }
    if (map['content'] is! String || (map['content'] as String).trim().isEmpty) {
      throw ArgumentError('Invalid or missing content in map: ${map['content']}');
    }
    if (map['color'] is! String || (map['color'] as String).trim().isEmpty) {
      throw ArgumentError('Invalid or missing color in map: ${map['color']}');
    }
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      color: map['color'] as String,
    );
  }

  @override
  String toString() {
    return '{ id=$id, title=$title, content=$content, color=$color }';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.color == color;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ content.hashCode ^ color.hashCode;
}
