import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_manager_pro/core/constants/app_colors.dart';
import 'package:todo_manager_pro/presentation/screens/widgets/task_item.dart';
import 'package:todo_manager_pro/state/task_provider.dart';
import 'package:todo_manager_pro/state/label_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final labelProvider = Provider.of<LabelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'ToDo Manager Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search by Label',
                              border: InputBorder.none,
                            ),
                            onChanged: (query) {
                              setState(() {
                                _searchQuery = query;
                                if (query.isEmpty) {
                                  taskProvider.clearFilter();
                                } else {
                                  final matchingLabels = labelProvider.labels
                                      .where((label) => label.name
                                          .toLowerCase()
                                          .contains(query.toLowerCase()))
                                      .toList();
                                  if (matchingLabels.isNotEmpty) {
                                    taskProvider.filterTasksByLabel(
                                        matchingLabels.first);
                                  } else {
                                    taskProvider.clearFilter();
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-task');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    '+ Add Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    _showRestoreDialog(context, taskProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: taskProvider.filteredTasks.isEmpty
                  ? const Center(child: Text('No tasks available'))
                  : ListView.builder(
                      itemCount: taskProvider.filteredTasks.length,
                      itemBuilder: (context, index) {
                        return TaskItem(
                            task: taskProvider.filteredTasks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Restore Deleted Tasks"),
          content: taskProvider.deletedTasks.isEmpty
              ? const Text("No deleted tasks available for restoration.")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: taskProvider.deletedTasks.map((task) {
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.restore),
                        onPressed: () {
                          taskProvider.restoreTask(task.id);
                          setState(() {
                            Provider.of<TaskProvider>(context, listen: false)
                                .loadTasks();
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
