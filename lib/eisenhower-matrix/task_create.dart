import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emma/models/category.dart';
import 'package:emma/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart'; // Pastikan untuk menambahkan ini untuk format tanggal
import 'package:google_generative_ai/google_generative_ai.dart';

final _firestore = FirebaseFirestore.instance;

class TaskCreatePage extends StatefulWidget {
  final Function onTaskChanged;

  const TaskCreatePage(
      {super.key, required this.onTaskChanged});

  @override
  _TaskCreatePageState createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _taskNameController = TextEditingController();
  late final TextEditingController _taskDescController = TextEditingController();
  late final TextEditingController _taskCategoryController = TextEditingController();
  late final TextEditingController _taskDeadlineController = TextEditingController();
  late final TextEditingController _taskReminderController = TextEditingController();

  DateTime? _taskDeadline;
  DateTime? _taskReminder;

  List<Category> categories = []; // Ganti dengan daftar kategori yang Anda miliki

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  void _loadCategory() async {
    // Ambil task berdasarkan kategori tanpa `setState` terlebih dahulu
    List<Category> res = await Category.findAll();

    if (res.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No category found'),
          ),
        );
      }

      return;
    }

    // Panggil `setState` hanya untuk memperbarui state setelah data diambil
    setState(() {
      categories = res;
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDescController.dispose();
    _taskCategoryController.dispose();
    _taskDeadlineController.dispose();
    _taskReminderController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
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
      }

      _firestore
          .collection('tasks')
          .add(newTask.toMap())
          .then((value) {
        widget.onTaskChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task saved'),
          ),
        );
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Task"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              const SizedBox(height: 16.0),
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
                      _taskDeadlineController.text =
                          DateFormat('dd/MM/yyyy').format(_taskDeadline!);
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
                      _taskReminderController.text =
                          DateFormat('dd/MM/yyyy').format(_taskReminder!);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
