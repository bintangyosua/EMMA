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

  const TaskCreatePage({super.key, required this.onTaskChanged});

  @override
  _TaskCreatePageState createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _taskNameController =
      TextEditingController();
  late final TextEditingController _taskDescController =
      TextEditingController();
  late final TextEditingController _taskCategoryController =
      TextEditingController();
  late final TextEditingController _taskDeadlineController =
      TextEditingController();
  late final TextEditingController _taskReminderController =
      TextEditingController();

  DateTime? _taskDeadline;
  DateTime? _taskReminder;

  List<Category> categories =
      []; // Ganti dengan daftar kategori yang Anda miliki

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

      _firestore.collection('tasks').add(newTask.toMap()).then((value) {
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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Task"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Name Text Field
              _buildTextField(
                controller: _taskNameController,
                label: 'Task Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Category Dropdown
              _buildDropdownField(
                label: 'Select Category',
                valueController: _taskCategoryController,
                items: categories
                    .map<DropdownMenuItem<String>>((Category category) {
                  return DropdownMenuItem<String>(
                    value: category.uid, // Set `uid` as the value
                    child: Text(category.name), // Show `name` in the UI
                  );
                }).toList(),
                onChanged: (String? selectedUid) {
                  if (selectedUid != null) {
                    _taskCategoryController.text = selectedUid;
                  }
                },
              ),
              const SizedBox(height: 16.0),

              // AI Generate Button
              ElevatedButton.icon(
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
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                icon: const Icon(Icons.smart_toy),
                label: const Text('Generate AI'),
              ),
              const SizedBox(height: 16.0),

              // Task Description Text Field
              _buildTextField(
                controller: _taskDescController,
                label: 'Task Description',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Deadline Date Picker
              _buildDateField(
                controller: _taskDeadlineController,
                label: 'Deadline',
                onDateSelected: (date) {
                  setState(() {
                    _taskDeadline = date;
                    _taskDeadlineController.text =
                        DateFormat('dd/MM/yyyy').format(_taskDeadline!);
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Reminder Date Picker
              _buildDateField(
                controller: _taskReminderController,
                label: 'Reminder',
                onDateSelected: (date) {
                  setState(() {
                    _taskReminder = date;
                    _taskReminderController.text =
                        DateFormat('dd/MM/yyyy').format(_taskReminder!);
                  });
                },
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9F7BFF), // Warna tombol
                    foregroundColor: Colors.white, // Warna teks tombol
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to create text fields with full width
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: validator,
    );
  }

  // Widget for Dropdown fields with full width
  Widget _buildDropdownField({
    required String label,
    required TextEditingController valueController,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  // Widget to create date picker fields
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
    );
  }
}
