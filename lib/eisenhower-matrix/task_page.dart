import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emma/colors.dart';
import 'package:emma/models/category.dart';
import 'package:emma/models/task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan untuk menambahkan ini untuk format tanggal

final _firestore = FirebaseFirestore.instance;

class TaskDetailPage extends StatefulWidget {
  final Task task; // Ganti ini sesuai model Task yang Anda miliki
  final Function onTaskChanged;

  const TaskDetailPage(
      {super.key, required this.task, required this.onTaskChanged});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _taskNameController;
  late TextEditingController _taskDescController;
  late TextEditingController _taskCategoryController;
  late TextEditingController _taskDeadlineController;

  DateTime? _taskDeadline;

  List<Category> categories =
      []; // Ganti dengan daftar kategori yang Anda miliki

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task.name);
    _taskDescController = TextEditingController(text: widget.task.desc);
    _taskCategoryController =
        TextEditingController(text: widget.task.category_id);
    _taskDeadlineController =
        TextEditingController(text: widget.task.deadline.toString());

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
    super.dispose();
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                widget.task.delete().then((value) {
                  if (mounted) {
                    widget.onTaskChanged();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Task deleted")),
                    );
                    Navigator.pop(context); // Kembali setelah penghapusan
                    Navigator.of(context).pop(); // Close the dialog
                  }
                }).catchError((error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.toString())),
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _firestore.collection('tasks').doc(widget.task.uid).update({
        'name': _taskNameController.text,
        'desc': _taskDescController.text,
        'deadline': Task.parseDateTime(_taskDeadlineController.text),
        'category_id': _taskCategoryController.text,
      }).then((value) {
        if (mounted) {
          widget.onTaskChanged();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Task saved")),
          );
          Navigator.pop(context); // Kembali setelah menyimpan
        }
      }).onError((handleError, stackTrace) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(handleError.toString())),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.color2,
        title: const Text(
          "Task Details",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                    'Save Task',
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
      value: widget.task.category_id,
      decoration: InputDecoration(
        labelText: 'Select Category',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: categories.map<DropdownMenuItem<String>>((Category category) {
        return DropdownMenuItem<String>(
          value: category.uid,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (String? selectedUid) {
        if (selectedUid == null) {
          _taskCategoryController.text = 'Do Now';
        } else {
          final selectedCategory = categories.firstWhere(
            (category) => category.uid == selectedUid,
          );
          _taskCategoryController.text = selectedCategory.uid;
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
          initialDate: DateTime.parse(controller.text),
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
}
