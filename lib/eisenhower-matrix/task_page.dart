import 'package:cloud_firestore/cloud_firestore.dart';
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
  late TextEditingController _taskReminderController;

  DateTime? _taskDeadline;
  DateTime? _taskReminder;

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
    _taskReminderController =
        TextEditingController(text: widget.task.reminder.toString());

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

  void _deleteTask() {
    // Attempt to delete the task
    widget.task.delete().then((value) {
      if (mounted) {
        widget.onTaskChanged();
        // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task deleted")),
        );
        Navigator.pop(context); // Kembali setelah penghapusan
      }
    }).catchError((error) {
      if (mounted) {
        // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    });
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Tambahkan logika penyimpanan di sini
      _firestore.collection('tasks').doc(widget.task.uid).update({
        'name': _taskNameController.text,
        'desc': _taskDescController.text,
        'deadline': Task.parseDateTime(_taskDeadlineController.text),
        'reminder': Task.parseDateTime(_taskReminderController.text),
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
        title: const Text("Task Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Allow scrolling for small screens
            child: Column(
              children: [
                TextFormField(
                  controller: _taskNameController,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    // Only bottom border with minimal styling
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
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
                  value: widget.task.category_id,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    // Only bottom border with minimal styling
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  items: categories
                      .map<DropdownMenuItem<String>>((Category category) {
                    return DropdownMenuItem<String>(
                      value: category.uid, // Set `uid` as the value
                      child: Text(category.name), // Show `name` in the UI
                    );
                  }).toList(),
                  onChanged: (String? selectedUid) {
                    if (selectedUid != null) {
                      _taskCategoryController.text =
                          selectedUid; // Update category
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
                    // Only bottom border with minimal styling
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _taskDeadlineController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    // Only bottom border with minimal styling
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: widget.task.deadline ?? DateTime.now(),
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
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _taskReminderController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Reminder',
                    // Only bottom border with minimal styling
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: widget.task.reminder ?? DateTime.now(),
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
                SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9F7BFF), // Warna ungu
                      foregroundColor: Colors.white, // Warna teks putih
                    ),
                    child: const Text('Save'),
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
