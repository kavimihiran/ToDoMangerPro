import 'package:todo_manager_pro/data/models/task_model.dart';
import 'package:todo_manager_pro/data/services/database_helper.dart';

class LocalStorageService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> saveTask(Task task) async {
    await _dbHelper.insertTask(task);
  }

  Future<List<Task>> getTasks() async {
    return await _dbHelper.getTasks();
  }

  Future<void> deleteTask(String id) async {
    await _dbHelper.deleteTask(id);
  }

  Future<void> restoreTask(String id) async {
    await _dbHelper.restoreTask(id);
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
  }

  Future<List<Task>> getDeletedTasks() async {
    return await _dbHelper.getDeletedTasks();
  }
}
