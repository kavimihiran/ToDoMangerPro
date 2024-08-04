import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:todo_manager_pro/core/constants/app_colors.dart';
import 'package:todo_manager_pro/core/constants/utils/notification_util.dart';
import 'package:todo_manager_pro/data/models/label_model.dart';
import 'package:todo_manager_pro/data/models/task_model.dart';
import 'package:todo_manager_pro/state/task_provider.dart';
import 'package:todo_manager_pro/state/label_provider.dart';
import 'package:todo_manager_pro/presentation/screens/widgets/label_chip.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final List<Label> _selectedLabels = [];
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  Label? _selectedDropdownLabel;
  File? _image;
  Timer? _speechTimer;

  @override
  void initState() {
    super.initState();
    initSpeech();
    NotificationUtil.initialize();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListeningForTitle() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _titleController.text = result.recognizedWords;
        });
      },
    );
  }

  void _startListeningForDescription() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _descriptionController.text = result.recognizedWords;
        });
      },
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void _showAddEditLabelDialog({Label? label}) async {
    final isEditing = label != null;
    final TextEditingController labelController = TextEditingController(
      text: isEditing ? label.name : '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Label' : 'Add Label'),
          content: TextField(
            controller: labelController,
            decoration: const InputDecoration(labelText: 'Label Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (isEditing) {
                  context
                      .read<LabelProvider>()
                      .editLabel(label.id, labelController.text);
                } else {
                  final newLabel = Label(
                    id: DateTime.now().toString(),
                    name: labelController.text,
                  );
                  context.read<LabelProvider>().addLabel(newLabel);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteLabel(Label label) {
    context.read<LabelProvider>().deleteLabel(label.id);
    setState(() {
      _selectedLabels.remove(label);

      if (_selectedDropdownLabel == label) {
        _selectedDropdownLabel = null;
      }
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _speechTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelProvider = context.watch<LabelProvider>();
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Title',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16.0),
                            hintText: 'Enter task title',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _speechToText.isNotListening
                            ? Icons.mic_off
                            : Icons.mic,
                        color: Colors.red,
                      ),
                      onPressed: _speechToText.isListening
                          ? _stopListening
                          : _startListeningForTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16.0),
                            hintText: 'Enter task description',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _speechToText.isNotListening
                            ? Icons.mic_off
                            : Icons.mic,
                        color: Colors.red,
                      ),
                      onPressed: _speechToText.isListening
                          ? _stopListening
                          : _startListeningForDescription,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Due Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                      hintText: 'Select due date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        _dueDateController.text = pickedDate.toString();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Label',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Label>(
                        hint: const Text('Select Label'),
                        value: _selectedDropdownLabel,
                        items: labelProvider.labels.map((Label label) {
                          return DropdownMenuItem<Label>(
                            value: label,
                            child: Text(label.name),
                          );
                        }).toList(),
                        onChanged: (Label? selectedLabel) {
                          if (selectedLabel != null &&
                              !_selectedLabels.contains(selectedLabel)) {
                            setState(() {
                              _selectedLabels.add(selectedLabel);
                              _selectedDropdownLabel = selectedLabel;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddEditLabelDialog(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        if (_selectedDropdownLabel != null) {
                          _showAddEditLabelDialog(
                              label: _selectedDropdownLabel);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        if (_selectedDropdownLabel != null) {
                          final labelToDelete = _selectedDropdownLabel!;
                          _deleteLabel(labelToDelete);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  children: _selectedLabels
                      .map((label) => LabelChip(
                            label: label,
                            onDeleted: () {
                              setState(() {
                                _selectedLabels.remove(label);
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                if (_image != null)
                  Image.file(
                    _image!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                if (_image == null)
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Pick an Image'),
                  ),
                const SizedBox(height: 16.0),
                Center(
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final newTask = Task(
                              id: DateTime.now().toString(),
                              title: _titleController.text,
                              description: _descriptionController.text,
                              dueDate: DateTime.parse(_dueDateController.text),
                              labels: _selectedLabels,
                              imagePath: _image?.path ?? '',
                              isCompleted: false);
                          taskProvider.addTask(newTask);
                          Provider.of<TaskProvider>(context, listen: false)
                              .loadTasks();
                          NotificationUtil.scheduleNotification(
                            'Task Reminder',
                            'You have a task :${newTask.title}',
                            newTask.dueDate,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Add Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
