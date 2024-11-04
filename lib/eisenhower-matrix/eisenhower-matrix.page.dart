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
    
    setState(() {
      _urgentImportantTasks = urgentImportantTasks;

    });
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
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: const Color(0xffF0ECE5),
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Do Now',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _urgentImportantTasks.length,
                                itemBuilder: (context, index) {
                                  final task = _urgentImportantTasks[index];
                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TaskDetailPage(
                                              task:
                                                  _urgentImportantTasks[index],
                                              onTaskChanged: () =>
                                                  _loadTasks()),
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
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: const Color(0xffB6BBC4),
                    ),
                    child: const Center(child: Text('Not Urgent & Important')),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: const Color(0xff31304D),
                    ),
                    child: const Center(
                      child: Text(
                        'Urgent & Not Important',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: const Color(0xff161A30),
                    ),
                    child: const Center(
                      child: Text(
                        'Not Urgent & Not Important',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
