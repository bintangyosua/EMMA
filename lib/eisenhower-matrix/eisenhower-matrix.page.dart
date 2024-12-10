import 'package:emma/eisenhower-matrix/task_create.dart';
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

  Widget buildTaskList(
      List<Task> tasks, String title, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Center(
        child: tasks.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailPage(
                            task: tasks[index],
                            onTaskChanged: () => _loadTasks(),
                          ),
                        ),
                      );
                    },
                    title: Text(
                      tasks[index].name,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'EMMA',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TaskCreatePage(onTaskChanged: () => _loadTasks());
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: buildTaskList(
                      _urgentImportantTasks,
                      'Do Now',
                      'Tasks to be done immediately.',
                      Colors.redAccent,
                    ),
                  ),
                  Expanded(
                    child: buildTaskList(
                      _urgentNotImportantTasks,
                      'Delegate',
                      'Assign to someone else.',
                      Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: buildTaskList(
                      _notUrgentImportantTasks,
                      'Decide',
                      'Schedule a time to do it.',
                      Colors.blueAccent,
                    ),
                  ),
                  Expanded(
                    child: buildTaskList(
                      _notUrgentNotImportantTasks,
                      'Eliminate',
                      'Consider removing it.',
                      Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
