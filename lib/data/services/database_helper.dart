import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_manager_pro/data/models/label_model.dart';
import 'package:todo_manager_pro/data/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'task_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        dueDate TEXT,
        labels TEXT,
        imagePath TEXT,
        isCompleted INTEGER,
        deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE labels(
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE task_labels(
        task_id TEXT,
        label_id TEXT,
        FOREIGN KEY (task_id) REFERENCES tasks (id),
        FOREIGN KEY (label_id) REFERENCES labels (id),
        PRIMARY KEY (task_id, label_id)
      )
    ''');
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertLabel(Label label) async {
    final db = await database;
    await db.insert(
      'labels',
      label.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('tasks', where: 'deleted = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<List<Label>> getLabels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('labels');
    return List.generate(maps.length, (i) {
      return Label.fromMap(maps[i]);
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> updateLabel(Label label) async {
    final db = await database;
    await db.update(
      'labels',
      label.toMap(),
      where: 'id = ?',
      whereArgs: [label.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.update(
      'tasks',
      {'deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> getDeletedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'deleted = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<void> restoreTask(String id) async {
    final db = await database;
    await db.update(
      'tasks',
      {'deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteLabel(String id) async {
    final db = await database;
    await db.delete(
      'labels',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Also remove related entries in task_labels table
    await db.delete(
      'task_labels',
      where: 'label_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addLabelToTask(String taskId, String labelId) async {
    final db = await database;
    await db.insert(
      'task_labels',
      {'task_id': taskId, 'label_id': labelId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeLabelFromTask(String taskId, String labelId) async {
    final db = await database;
    await db.delete(
      'task_labels',
      where: 'task_id = ? AND label_id = ?',
      whereArgs: [taskId, labelId],
    );
  }

  Future<List<Label>> getLabelsForTask(String taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT l.* FROM labels l
    INNER JOIN task_labels tl ON l.id = tl.label_id
    WHERE tl.task_id = ?
  ''', [taskId]);
    return List.generate(maps.length, (i) {
      return Label.fromMap(maps[i]);
    });
  }
}
