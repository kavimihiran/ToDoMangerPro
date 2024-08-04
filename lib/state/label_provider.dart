import 'package:flutter/material.dart';
import 'package:todo_manager_pro/data/services/database_helper.dart';
import '../data/models/label_model.dart';

class LabelProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Label> _labels = [];

  List<Label> get labels => _labels;

  LabelProvider() {
    _loadLabels();
  }

  Future<void> _loadLabels() async {
    _labels = await _dbHelper.getLabels();
    notifyListeners();
  }

  Future<void> addLabel(Label label) async {
    await _dbHelper.insertLabel(label);
    _labels.add(label);
    notifyListeners();
  }

  Future<void> editLabel(String id, String newName) async {
    final label = _labels.firstWhere((l) => l.id == id);
    final updatedLabel = Label(id: id, name: newName);
    await _dbHelper.updateLabel(updatedLabel);
    label.name = newName;
    notifyListeners();
  }

  Future<void> deleteLabel(String id) async {
    await _dbHelper.deleteLabel(id);
    _labels.removeWhere((l) => l.id == id);
    notifyListeners();
  }
}
