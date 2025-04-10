import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'task.dart';
import '../utils/db_worker.dart';

/// Database provider class for managing tasks in the FlutterBook app.
///
/// This class provides methods to initialize the database and perform CRUD
/// operations on the tasks table.
class TasksDBWorker implements DBWorker<Task> {
  static final TasksDBWorker db = TasksDBWorker._();
  Database? _db;

  TasksDBWorker._();

  /// Gets the database instance, initializing it if necessary.
  Future<Database> get database async {
    _db ??= await init();
    print("📦 [DB] TasksDBWorker.database initialized.");
    return _db!;
  }

  /// Initializes the database by creating the tasks table if it doesn’t exist.
  Future<Database> init() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    print("🛠 [DB INIT] Path: $path");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        print("🆕 [DB CREATE] Creating tasks table...");
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY,
            description TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            isComplete INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /// Inserts a new Task into the database.
  @override
  Future<int> create(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap());
    print("✅ [CREATE] Task inserted with id: $id => ${task.toMap()}");
    return id;
  }

  /// Retrieves a single Task from the database by id.
  @override
  Future<Task?> get(int id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final task = Task.fromMap(maps.first);
      print("📥 [GET] Retrieved Task: $task");
      return task;
    }

    print("⚠️ [GET] No task found with id: $id");
    return null;
  }

  /// Retrieves all Tasks from the database.
  @override
  Future<List<Task>> getAll() async {
    final db = await database;
    final maps = await db.query('tasks');
    final tasks = List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    print("📋 [GET ALL] ${tasks.length} tasks loaded.");
    return tasks;
  }

  /// Updates an existing Task in the database.
  @override
  Future<int> update(Task task) async {
    final db = await database;
    final count = await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    print("🔄 [UPDATE] Task updated (id: ${task.id}) => $count row(s)");
    return count;
  }

  /// Deletes a Task from the database by id.
  @override
  Future<int> delete(int id) async {
    final db = await database;
    final count = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    print("🗑️ [DELETE] Task deleted (id: $id) => $count row(s)");
    return count;
  }
}

