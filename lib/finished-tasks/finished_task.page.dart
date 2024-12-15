import 'package:emma/colors.dart';
import 'package:emma/models/task.dart';
import 'package:flutter/material.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    List<Task> tasks = await Task.findAll();
    setState(() {
      _tasks = tasks;
    });
  }

  void _filterTasks(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = _selectedCategory == 'All'
        ? _tasks
        : _tasks
            .where((task) => task.category_id == _selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'EMMA',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            focusColor: AppColors.color1,
            value: _selectedCategory,
            items: [
              'All',
              'Category 1',
              'Category 2',
              'Category 3',
              'Category 4',
            ].map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
                // style: TextStyle(color: Colors.black),
              );
            }).toList(),
            onChanged: (String? newCategory) {
              if (newCategory != null) {
                _filterTasks(newCategory);
              }
            },
            style: TextStyle(color: Colors.black),
            dropdownColor: Colors.white,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text('Deadline: ${task.deadline}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: task.is_done,
                        onChanged: (bool? value) {
                          setState(() {
                            task.checkDone(task.uid!);
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                    'Are you sure you want to delete this task?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          ).then((confirmDelete) {
                            if (confirmDelete ?? false) {
                              task.delete().then((_) {
                                setState(() {
                                  _tasks.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Task deleted")),
                                );
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
