import 'package:emma/eisenhower-matrix/task-item.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // title: const Text('Add Task'),
      // content: const Text('Add your task'),
      // actions: [],
      child: Text('Hello'),
    );
  }
}
