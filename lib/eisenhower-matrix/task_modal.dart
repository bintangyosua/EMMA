import 'package:emma/models/category.dart';
import 'package:emma/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class TaskModal extends StatefulWidget {
  final Function onTaskAdded;

  const TaskModal({super.key, required this.onTaskAdded});

  @override
  _TaskModalState createState() => _TaskModalState();
}

class _TaskModalState extends State<TaskModal> {
  DateTime? _taskDeadline;
  DateTime? _taskReminder;
  List<Category> categories = [];

  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  final TextEditingController _taskCategoryController = TextEditingController();
  final TextEditingController _taskDeadlineController = TextEditingController();
  final TextEditingController _taskReminderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  void _loadCategory() async {
    List<Category> res = await Category.findAll();

    if (res.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No category found'),
        ),
      );

      return;
    }

    setState(() {
      categories = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: double.maxFinite),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: _taskNameController,
            decoration: const InputDecoration(
              labelText: 'Task Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<String>(
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Select Category',
            ),
            items:
                categories.map<DropdownMenuItem<String>>((Category category) {
              return DropdownMenuItem<String>(
                value: category.uid, // Set `uid` as the value
                child: Text(category.name), // Show `name` in the UI
              );
            }).toList(),
            onChanged: (String? selectedUid) {
              // Update the controller based on selected category
              if (selectedUid == null) {
                _taskCategoryController.text = 'Do Now';
              } else {
                // Find the selected category by its uid
                final selectedCategory = categories.firstWhere(
                  (category) => category.uid == selectedUid,
                );
                _taskCategoryController.text = selectedCategory.uid;
              }
            },
          ),
          const SizedBox(height: 16.0),
          TextButton(
            child: const Text('Generate AI'),
            onPressed: () async {
              if (_taskNameController.text.isNotEmpty) {
                final model = GenerativeModel(
                    model: 'gemini-1.5-flash',
                    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '');
                final response = await model.generateContent([
                  Content.text(
                      'Create a short description for the task named "${_taskNameController.text}". Describe its purpose, key steps, and expected outcomes.')
                ]);
                _taskDescController.text = '${response.text}';
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Alert'),
                      content: const Text(
                          'Please enter a task name before generating AI description.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          TextFormField(
            controller: _taskDescController,
            maxLines: 5, // Change to text area
            decoration: const InputDecoration(
              labelText: 'Task Description',
              alignLabelWithHint: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _taskDeadlineController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Deadline',
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
                helpText: 'Select Deadline',
                errorFormatText: 'Enter valid date',
                errorInvalidText: 'Enter date in valid range',
              );
              if (picked != null) {
                setState(() {
                  _taskDeadline = picked;
                  _taskDeadlineController.text = DateFormat('dd/MM/yyyy')
                      .format(_taskDeadline ?? DateTime.now());
                });
              }
            },
          ),
          TextFormField(
            controller: _taskReminderController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Reminder',
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
                helpText: 'Select Reminder',
                errorFormatText: 'Enter valid date',
                errorInvalidText: 'Enter date in valid range',
              );
              if (picked != null) {
                setState(() {
                  _taskReminder = picked;
                  _taskReminderController.text = DateFormat('dd/MM/yyyy')
                      .format(_taskReminder ?? DateTime.now());
                });
              }
            },
          ),
        ]),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
            child: const Text('Add'),
            onPressed: () {
              User currentUser = FirebaseAuth.instance.currentUser!;
              Task newTask = Task(
                name: _taskNameController.text,
                desc: _taskDescController.text,
                category_id: _taskCategoryController.text,
                deadline: _taskDeadline,
                reminder: _taskReminder,
                user_id: currentUser.uid,
              );

              if (_taskNameController.text.isEmpty ||
                  _taskDescController.text.isEmpty ||
                  _taskCategoryController.text.isEmpty ||
                  _taskDeadline == null ||
                  _taskReminder == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua field wajib diisi'),
                  ),
                );
                return; // Exit the function if any field is empty
              } else {
                Navigator.of(context).pop();
                newTask.save();
                widget.onTaskAdded();
              }
            }),
      ],
    );
  }
}
