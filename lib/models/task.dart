import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Task {
  final String uid;
  final DateTime deadline;
  final String description;
  final String name;
  final DateTime reminder;
  final String user_id;

  Task({
    required this.uid,
    required this.deadline,
    required this.description,
    required this.name,
    required this.reminder,
    required this.user_id,
  });

  Future<List<Task>> findAll() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await db.collection('tasks').get();

    List<Task> tasks =
        snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();

    return tasks;
  }

  factory Task.fromMap(Map<String, dynamic> map, String uid) {
    return Task(
      uid: uid,
      deadline: (map['deadline'] as Timestamp).toDate(),
      description: map['description'],
      name: map['name'],
      reminder: (map['reminder'] as Timestamp).toDate(),
      user_id: map['user_id'],
    );
  }
}
