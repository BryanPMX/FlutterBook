// The University of Texas at El Paso
// Bryan Perez

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/utils.dart' as utils;
import 'note.dart';
import '../utils/db_worker.dart';

/// Database provider class for managing notes in the FlutterBook app.
///
/// This class provides methods to initialize the database and perform CRUD
/// operations on the notes table.
class NotesDBWorker implements DBWorker<Note> {
  /// Private constructor for the singleton pattern.
  NotesDBWorker._();

  /// The singleton instance of the database worker.
  static final NotesDBWorker db = NotesDBWorker._();

  /// The database instance, initialized lazily.
  Database? _db;

  /// Gets the database instance, initializing it if necessary.
  ///
  /// @return A [Future] that resolves to the [Database] instance.
  Future<Database> get database async {
    // Use a null-aware assignment to initialize the database if it's null.
    _db ??= await init();
    print("DEBUG: NotesDBWorker.get-database(): _db = $_db");
    return _db!;
  }

  /// Initializes the database by creating the notes table if it doesn’t exist.
  ///
  /// @return A [Future] that resolves to the initialized [Database] instance.
  Future<Database> init() async {
    print("DEBUG: NotesDBWorker.init()");
    // Initialize the Utils class to ensure docsDir is ready.
    await utils.Utils.init();
    // Construct the path to the database file.
    final String path = join(utils.Utils.docsDir.path, "notes.db");
    print("DEBUG: NotesDBWorker.init(): path = $path");
    // Open the database and create the notes table if it doesn’t exist.
    final Database db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {
        print("DEBUG: Database opened");
      },
      onCreate: (Database db, int version) async {
        await db.execute(
          """
          CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            color TEXT NOT NULL
          )
          """,
        );
        print("DEBUG: Notes table created");
      },
    );
    return db;
  }

  @override
  Future<int> create(Note note) async {
    print("DEBUG: NotesDBWorker.create(): note = $note");
    try {
      final Database db = await database;
      // Get the largest current ID in the table, plus one, to be the new ID.
      final result = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM notes");
      int? id = result.first["id"] as int?;
      id ??= 1; // If no records exist, start with ID 1.
      // Insert the note into the table.
      final int newId = await db.rawInsert(
        "INSERT INTO notes (id, title, content, color) VALUES (?, ?, ?, ?)",
        [id, note.title, note.content, note.color],
      );
      print("DEBUG: NotesDBWorker.create(): newId = $newId");
      print("DEBUG: Note created successfully with ID: $newId");
      return newId;
    } catch (e) {
      print("DEBUG: NotesDBWorker.create(): Error = $e");
      rethrow;
    }
  }

  @override
  Future<Note?> get(int id) async {
    print("DEBUG: NotesDBWorker.get(): id = $id");
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> records =
      await db.query("notes", where: "id = ?", whereArgs: [id]);
      if (records.isEmpty) {
        print("DEBUG: NotesDBWorker.get(): No note found with id = $id");
        return null;
      }
      final note = Note.fromMap(records.first);
      print("DEBUG: NotesDBWorker.get(): note = $note");
      return note;
    } catch (e) {
      print("DEBUG: NotesDBWorker.get(): Error = $e");
      rethrow;
    }
  }

  @override
  Future<List<Note>> getAll() async {
    print("DEBUG: NotesDBWorker.getAll()");
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> records = await db.query("notes");
      final List<Note> notes = records.isNotEmpty
          ? records.map((m) => Note.fromMap(m)).toList()
          : [];
      print("DEBUG: NotesDBWorker.getAll(): Retrieved ${notes.length} notes: $notes");
      return notes;
    } catch (e) {
      print("DEBUG: NotesDBWorker.getAll(): Error = $e");
      rethrow;
    }
  }

  @override
  Future<int> update(Note note) async {
    print("DEBUG: NotesDBWorker.update(): note = $note");
    try {
      final Database db = await database;
      final int rowsAffected = await db.update(
        "notes",
        note.toMap(),
        where: "id = ?",
        whereArgs: [note.id],
      );
      print("DEBUG: NotesDBWorker.update(): rowsAffected = $rowsAffected");
      print("DEBUG: Note updated successfully; rows affected: $rowsAffected");
      return rowsAffected;
    } catch (e) {
      print("DEBUG: NotesDBWorker.update(): Error = $e");
      rethrow;
    }
  }

  @override
  Future<int> delete(int id) async {
    print("DEBUG: NotesDBWorker.delete(): id = $id");
    try {
      final Database db = await database;
      final int rowsAffected =
      await db.delete("notes", where: "id = ?", whereArgs: [id]);
      print("DEBUG: NotesDBWorker.delete(): rowsAffected = $rowsAffected");
      print("DEBUG: Note deleted successfully; rows affected: $rowsAffected");
      return rowsAffected;
    } catch (e) {
      print("DEBUG: NotesDBWorker.delete(): Error = $e");
      rethrow;
    }
  }
}