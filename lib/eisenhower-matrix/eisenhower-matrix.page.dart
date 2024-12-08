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
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color.fromARGB(137, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Color.fromARGB(137, 0, 0, 0),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Tasks list section
                      Expanded(
                        flex: 2,
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
                                      onTaskChanged: () => _loadTasks(),
                                    ),
                                  ),
                                );
                              },
                              title: Text(
                                task.name.length > 30
                                    ? '${task.name.substring(0, 20)}...'
                                    : task.name,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              dense: true,
                            );
                          },
                        ),
                      ),
                    ],
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
        backgroundColor: const Color(0xFFF3E5F5),
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
              // return TaskModal(
              //   onTaskAdded: () {
              //     _loadTasks();
              //   },
              // );
              return TaskCreatePage(onTaskChanged: () => _loadTasks());
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: const Color(0xFFF3E5F5),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: buildTaskList(
                      _urgentImportantTasks,
                      'Do Now',
                      'Do it Now.',
                      const Color.fromARGB(255, 69, 225, 74),
                    ),
                  ),
                  Expanded(
                    child: buildTaskList(
                      _urgentNotImportantTasks,
                      'Delegate',
                      'Who can do it for you?',
                      const Color.fromARGB(255, 255, 39, 24),
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
                      'Schedule a time',
                      const Color.fromARGB(255, 15, 214, 249),
                    ),
                  ),
                  Expanded(
                    child: buildTaskList(
                      _notUrgentNotImportantTasks,
                      'Postpone',
                      'Eliminate it',
                      Colors.grey,
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
