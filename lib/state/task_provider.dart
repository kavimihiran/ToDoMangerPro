import 'package:flutter/material.dart';
import 'package:todo_manager_pro/core/constants/utils/notification_util.dart';
import 'package:todo_manager_pro/data/models/label_model.dart';
import 'package:todo_manager_pro/data/models/task_model.dart';
import 'package:todo_manager_pro/data/services/database_helper.dart';
import 'package:todo_manager_pro/data/services/local_storage_services.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  List<Task> _deletedTasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;
  List<Task> get deletedTasks => _deletedTasks;
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  void addTask(Task task) {
    _tasks.add(task);
    LocalStorageService().saveTask(task);
    notifyListeners();
  }

  Future<void> filterTasksByLabel(Label? label) async {
    if (label == null) {
      _filteredTasks = List.from(_tasks);
    } else {
      print('Filtering tasks by label: ${label.name}');
      _filteredTasks = _tasks.where((task) {
        return task.labels.any((taskLabel) => taskLabel.name == label.name);
      }).toList();
      print('Filtered tasks: ${_filteredTasks.length}');
    }
    notifyListeners();
  }

  void clearFilter() {
    _filteredTasks = _tasks;
    notifyListeners();
  }

  Future<void> getTaskLabels(String taskId) async {
    final labels = await _dbHelper.getLabelsForTask(taskId);
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
    // Update labels
    for (final label in task.labels) {
      await _dbHelper.addLabelToTask(task.id, label.id);
    }
    notifyListeners();
  }

  void deleteTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    _tasks.remove(task);
    _deletedTasks.add(task);
    LocalStorageService().deleteTask(id);
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    LocalStorageService().updateTask(task);
    notifyListeners();
  }

  void restoreTask(String id) {
    final task = _deletedTasks.firstWhere((t) => t.id == id);
    _deletedTasks.remove(task);
    _tasks.add(task);
    LocalStorageService().saveTask(task);
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _tasks = await DatabaseHelper().getTasks();
    _deletedTasks = await DatabaseHelper().getDeletedTasks();
    _filteredTasks = List.from(_tasks);
    notifyListeners();
  }
}
