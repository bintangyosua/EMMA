import 'package:flutter/material.dart';

class TaskItem extends StatefulWidget {
  final String title;
  final bool isChecked;

  const TaskItem({
    Key? key,
    required this.title,
    required this.isChecked,
  }) : super(key: key);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style: TextStyle(
          decoration: _isChecked ? TextDecoration.lineThrough : null,
        ),
      ),
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
      },
      tileColor: const Color(0xffE9F4F6),
    );
  }
}
