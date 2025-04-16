import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'contact.dart';
import '../utils/db_worker.dart';

/// Handles all database operations for contacts.
class ContactsDBWorker implements DBWorker<Contact> {
  static final ContactsDBWorker db = ContactsDBWorker._();
  ContactsDBWorker._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT NOT NULL,
            notes TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<int> create(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  @override
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Contact?> get(int id) async {
    final db = await database;
    final maps = await db.query('contacts', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Contact.fromMap(maps.first) : null;
  }

  @override
  Future<List<Contact>> getAll() async {
    final db = await database;
    final maps = await db.query('contacts');
    return maps.map((map) => Contact.fromMap(map)).toList();
  }

  @override
  Future<int> update(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }
}