import 'package:emma/eisenhower-matrix/task-item.dart';
import 'package:emma/eisenhower-matrix/task_modal.dart';
import 'package:flutter/material.dart';

class EisenhowerMatrixPage extends StatefulWidget {
  @override
  _EisenhowerMatrixPageState createState() => _EisenhowerMatrixPageState();
}

class _EisenhowerMatrixPageState extends State<EisenhowerMatrixPage> {
  List<TaskItem> _tasks = [
    TaskItem(
      title: 'Task 1',
      isChecked: false,
    ),
    TaskItem(
      title: 'Task 2',
      isChecked: false,
    ),
  ];

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
                return TaskModal();
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
                                itemCount: _tasks.length,
                                itemBuilder: (context, index) {
                                  return _tasks[index];
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: FloatingActionButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Task Name',
                                        ),
                                        onSubmitted: (value) {
                                          setState(() {
                                            _tasks.add(TaskItem(
                                              title: value,
                                              isChecked: false,
                                            ));
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.add),
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
