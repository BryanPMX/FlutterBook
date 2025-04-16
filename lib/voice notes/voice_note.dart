/// A model representing a voice note entry.
///
/// Stores a unique ID, title, file path to the audio, the duration, and the creation timestamp.
class VoiceNote {
  final int? id;
  final String title;
  final String filePath;
  final String duration;
  final DateTime createdAt;

  /// Constructs a new [VoiceNote] with optional [id], and required [title], [filePath], [duration], and [createdAt].
  VoiceNote({
    this.id,
    required this.title,
    required this.filePath,
    required this.duration,
    required this.createdAt,
  });

  /// Creates a copy of this note with optional field overrides.
  VoiceNote copyWith({
    int? id,
    String? title,
    String? filePath,
    String? duration,
    DateTime? createdAt,
  }) {
    return VoiceNote(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts the voice note to a map for storing in SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Constructs a [VoiceNote] from a map retrieved from SQLite.
  factory VoiceNote.fromMap(Map<String, dynamic> map) {
    return VoiceNote(
      id: map['id'] as int?,
      title: map['title'] as String,
      filePath: map['filePath'] as String,
      duration: map['duration'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'VoiceNote{id: $id, title: $title, filePath: $filePath, duration: $duration, createdAt: $createdAt}';
  }
}
