import 'package:emma/eisenhower-matrix/task-item.dart';
import 'package:emma/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class TaskModal extends StatefulWidget {
  const TaskModal({Key? key}) : super(key: key);

  @override
  _TaskModalState createState() => _TaskModalState();
}

class _TaskModalState extends State<TaskModal> {
  final _formKey = GlobalKey<FormState>();
  late String _taskName;
  late DateTime _taskDeadline;
  late DateTime _taskReminder;

  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  final TextEditingController _taskCategoryController = TextEditingController();

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
          SizedBox(height: 16.0),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Category',
            ),
            items: <String>[
              'Do Now',
              'Urgent & Not Important',
              'Not Urgent & Important',
              'Not Urgent & Not Important'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              // Handle change
              if (newValue == null)
                _taskCategoryController.text = 'Do Now';
              else
                _taskCategoryController.text = newValue;
            },
          ),
          SizedBox(height: 16.0),
          TextButton(
            child: const Text('Generate AI'),
            onPressed: () async {
              if (_taskNameController.text.isNotEmpty) {
                final model = GenerativeModel(
                    model: 'gemini-1.5-flash',
                    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '');
                final response = await model.generateContent([
                  Content.text(
                      'I want to make a task called ${_taskNameController.text.toLowerCase()}. what shoulod i do?')
                ]);
                _taskDescController.text = '${response.text}';
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Alert'),
                      content: Text(
                          'Please enter a task name before generating AI description.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
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
            if (_formKey.currentState!.validate()) {
              _taskName = _taskNameController.text;

              Task task = new Task(
                name: _taskNameController.text,
                category_id: _taskCategoryController.text,
                desc: _taskDescController.text,
                deadline: DateTime.now(),
                reminder: DateTime.now(),
                user_id: '5g7TjtnXiOUPlwQaiuX1',
              );

              //TODO: add task to database
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
