import 'package:emma/eisenhower-matrix/task_modal.dart';
import 'package:emma/eisenhower-matrix/task_page.dart';
import 'package:emma/models/task.dart';
import 'package:flutter/material.dart';

class EisenhowerMatrixPage extends StatefulWidget {
  @override
  _EisenhowerMatrixPageState createState() => _EisenhowerMatrixPageState();
}

class _EisenhowerMatrixPageState extends State<EisenhowerMatrixPage> {
  List<Task> _urgentImportantTasks = [];
  List<Task> _notUrgentImportantTasks = [];
  List<Task> _urgentNotImportantTasks = [];
  List<Task> _notUrgentNotImportantTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Method untuk memuat task dari Firebase
  void _loadTasks() async {
    List<Task> urgentImportantTasks =
        await Task.findTasksByCategory('uw0sLWpsSWYFPfeTbijO');
    List<Task> notUrgentImportantTasks =
        await Task.findTasksByCategory('Pnkb6VLOhryAjrwCOyes');
    List<Task> urgentNotImportantTasks =
        await Task.findTasksByCategory('cl0BxRTOXKkS2DmO0DC8');
    List<Task> notUrgentNotImportantTasks =
        await Task.findTasksByCategory('qUPKuIqJioKvZO8qYD3L');

    setState(() {
      _urgentImportantTasks = urgentImportantTasks;
      _notUrgentImportantTasks = notUrgentImportantTasks;
      _urgentNotImportantTasks = urgentNotImportantTasks;
      _notUrgentNotImportantTasks = notUrgentNotImportantTasks;
    });
  }

  Widget buildTaskList(List<Task> tasks, String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        color: const Color(0xffF0ECE5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailPage(
                            task: tasks[index],
                            onTaskChanged: () => _loadTasks()),
                      ),
                    );
                  },
                  title: Text(
                    task.name.length > 30
                        ? '${task.name.substring(0, 20)}...'
                        : task.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eisenhower Matrix'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return TaskModal(
                  onTaskAdded: () {
                    _loadTasks();
                  },
                );
              });
        },
        // foregroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: buildTaskList(_urgentImportantTasks, 'Do Now')),
                Expanded(
                    child: buildTaskList(_urgentNotImportantTasks, 'Delegate')),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                    child: buildTaskList(_notUrgentImportantTasks, 'Decide')),
                Expanded(
                    child:
                        buildTaskList(_notUrgentNotImportantTasks, 'Postpone')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
