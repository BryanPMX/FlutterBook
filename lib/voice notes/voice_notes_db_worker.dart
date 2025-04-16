import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/db_worker.dart';
import 'voice_note.dart';

/// Database provider class for managing voice notes in the FlutterBook app.
///
/// This class performs all necessary CRUD operations and ensures that the
/// voice notes are persisted using SQLite.
class VoiceNotesDBWorker implements DBWorker<VoiceNote> {
  /// Singleton instance
  static final VoiceNotesDBWorker db = VoiceNotesDBWorker._();
  VoiceNotesDBWorker._();

  Database? _db;

  /// Getter for the database instance
  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  /// Initializes the database and creates the voice_notes table if it doesn't exist.
  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'voice_notes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE voice_notes (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            filePath TEXT NOT NULL,
            duration TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<int> create(VoiceNote note) async {
    final db = await database;
    return await db.insert('voice_notes', note.toMap());
  }

  @override
  Future<VoiceNote?> get(int id) async {
    final db = await database;
    final result = await db.query('voice_notes', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? VoiceNote.fromMap(result.first) : null;
  }

  @override
  Future<List<VoiceNote>> getAll() async {
    final db = await database;
    final results = await db.query('voice_notes');
    return results.map((map) => VoiceNote.fromMap(map)).toList();
  }

  @override
  Future<int> update(VoiceNote note) async {
    final db = await database;
    return await db.update(
      'voice_notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('voice_notes', where: 'id = ?', whereArgs: [id]);
  }
}