import 'package:emma/colors.dart';
import 'package:emma/models/task.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = [];
  String _selectedCategory = 'All';
  String _currentUserId = '';

  // Define category IDs as constants
  static const Map<String, String> _categoryIds = {
    'All': 'All',
    'Do Now': 'uw0sLWpsSWYFPfeTbijO',
    'Decide': 'Pnkb6VLOhryAjrwCOyes',
    'Delegate': 'cl0BxRTOXKkS2DmO0DC8',
    'Postpone': 'qUPKuIqJioKvZO8qYD3L',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    // Get the current user's ID
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
      _loadTasks(); // Load tasks after getting the user ID
    }
  }

  Future<void> _loadTasks() async {
    // Fetch all tasks and filter by the current user's ID
    List<Task> tasks = await Task.findAll();
    setState(() {
      _tasks = tasks.where((task) => task.user_id == _currentUserId).toList();
    });
  }

  void _filterTasks(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Updated filtering logic
    List<Task> filteredTasks = _selectedCategory == 'All'
        ? _tasks
        : _tasks
            .where(
                (task) => task.category_id == _categoryIds[_selectedCategory])
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 36,
              width: 36,
            ),
            const SizedBox(width: 8),
            const Text(
              'Tasks',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppColors.color1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categoryIds.keys.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newCategory) {
                    if (newCategory != null) {
                      _filterTasks(newCategory);
                    }
                  },
                  style: const TextStyle(color: Colors.black),
                  dropdownColor: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      task.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                          icon: const Icon(Icons.delete, color: Colors.red),
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
                                    const SnackBar(
                                        content: Text("Task deleted")),
                                  );
                                });
                              }
                            });
                          },
                        ),
                      ],
                    ),
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
