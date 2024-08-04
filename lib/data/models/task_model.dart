import 'dart:convert';

import 'package:todo_manager_pro/data/models/label_model.dart';

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  List<Label> labels;
  String imagePath;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.labels,
    required this.imagePath,
    required this.isCompleted,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    // Convert labels JSON string to List<Label>
    List<Label> labels = [];
    if (map['labels'] != null &&
        map['labels'] is String &&
        map['labels'].isNotEmpty) {
      try {
        List<dynamic> labelsJson = json.decode(map['labels'] as String);
        labels = labelsJson
            .map((item) => Label.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing labels: $e');
      }
    }

    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      labels: labels,
      imagePath: map['imagePath'] as String? ?? '',
      isCompleted: map['isCompleted'] as int == 1,
    );
  }

  Map<String, dynamic> toMap() {
    String labelsJson =
        json.encode(labels.map((label) => label.toMap()).toList());

    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'labels': labelsJson,
      'imagePath': imagePath,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
