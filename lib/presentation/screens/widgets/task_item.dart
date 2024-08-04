import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:todo_manager_pro/presentation/screens/edit_task_screen.dart';
import 'package:todo_manager_pro/state/task_provider.dart';
import 'package:todo_manager_pro/data/models/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  FlutterTts flutterTts = FlutterTts();

  TaskItem({required this.task});

  void textToSpeech(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.3);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (task.imagePath.isNotEmpty)
                  Image.file(
                    File(task.imagePath),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                else
                  const Icon(Icons.image, size: 100),
                Text(
                  task.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    color: Color.fromARGB(255, 72, 2, 247),
                  ),
                  onPressed: () {
                    textToSpeech(
                        'Title is ${task.title} And the Description is ${task.description}');
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              "Description :  ${task.description}",
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      taskProvider.toggleTaskCompletion(task.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Color.fromARGB(255, 72, 2, 247),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      taskProvider.deleteTask(task.id);
                      Provider.of<TaskProvider>(context, listen: false)
                          .loadTasks();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
