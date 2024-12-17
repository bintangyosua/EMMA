import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emma/colors.dart';
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

  DateTime? _taskDeadline;

  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await Category.findAll();

    if (categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No category found'),
          ),
        );
      }
      return;
    }

    setState(() {
      _categories = categories;
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDescController.dispose();
    _taskCategoryController.dispose();
    _taskDeadlineController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      User currentUser = FirebaseAuth.instance.currentUser!;
      final newTask = Task(
          name: _taskNameController.text,
          desc: _taskDescController.text,
          category_id: _taskCategoryController.text,
          deadline: _taskDeadline,
          user_id: currentUser.uid,
          is_done: false);

      if (_taskNameController.text.isEmpty ||
          _taskDescController.text.isEmpty ||
          _taskCategoryController.text.isEmpty ||
          _taskDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Every tasks must not be empty'),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.color2,
        title: const Text(
          "Create New Task",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
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
              _buildTextFormField(
                controller: _taskNameController,
                labelText: 'Task Name',
                icon: Icons.task,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter some text'
                    : null,
              ),
              const SizedBox(height: 16.0),
              _buildDropdownButtonFormField(),
              const SizedBox(height: 16.0),
              _buildGenerateAiButton(context),
              const SizedBox(height: 16.0),
              _buildTextFormField(
                controller: _taskDescController,
                labelText: 'Task Description',
                maxLines: 5,
                alignLabelWithHint: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter some text'
                    : null,
              ),
              const SizedBox(height: 16.0),
              _buildDatePickerTextField(
                controller: _taskDeadlineController,
                labelText: 'Deadline',
                onDateSelected: (date) {
                  setState(() {
                    _taskDeadline = date;
                    _taskDeadlineController.text =
                        DateFormat('dd/MM/yyyy').format(_taskDeadline!);
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveTask,
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    int maxLines = 1,
    bool alignLabelWithHint = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: icon != null ? Icon(icon) : null,
        alignLabelWithHint: alignLabelWithHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      validator: (value) => value == null ? 'Please select a category' : null,
      decoration: InputDecoration(
        labelText: 'Select Category',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _categories.map<DropdownMenuItem<String>>((Category category) {
        return DropdownMenuItem<String>(
          value: category.uid,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (String? selectedUid) {
        if (selectedUid == null) {
          _taskCategoryController.text = 'Do Now';
        } else {
          final selectedCategory = _categories.firstWhere(
            (category) => category.uid == selectedUid,
          );
          _taskCategoryController.text = selectedCategory.uid;
        }
      },
    );
  }

  Widget _buildGenerateAiButton(BuildContext context) {
    return TextButton(
      child: const Text('Generate AI'),
      onPressed: () async {
        if (_taskNameController.text.isNotEmpty) {
          final model = GenerativeModel(
            model: 'gemini-1.5-flash',
            apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
          );
          final response = await model.generateContent([
            Content.text(
                'Create a short description for the task named "${_taskNameController.text}". Describe its purpose, key steps, and expected outcomes.')
          ]);
          _taskDescController.text = '${response.text}';
        } else {
          _showAlertDialog(context, 'Alert',
              'Please enter a task name before generating AI description.');
        }
      },
    );
  }

  Widget _buildDatePickerTextField({
    required TextEditingController controller,
    required String labelText,
    required Function(DateTime) onDateSelected,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(Icons.date_range),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          helpText: 'Select $labelText',
          errorFormatText: 'Enter valid date',
          errorInvalidText: 'Enter date in valid range',
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
    );
  }

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
}
