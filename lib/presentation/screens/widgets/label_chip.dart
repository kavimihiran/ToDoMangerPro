import 'package:flutter/material.dart';
import 'package:todo_manager_pro/data/models/label_model.dart';

class LabelChip extends StatelessWidget {
  final Label label;
  final VoidCallback onDeleted;

  const LabelChip({
    Key? key,
    required this.label,
    required this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label.name),
      onDeleted: onDeleted,
    );
  }
}
