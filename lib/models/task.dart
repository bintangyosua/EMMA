import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Task {
  final DateTime? deadline;
  final String desc;
  final String name;
  final DateTime? reminder;
  final String? user_id;
  final String category_id;

  Task({
    required this.deadline,
    required this.desc,
    required this.name,
    required this.reminder,
    required this.user_id,
    required this.category_id,
  });

  // Method untuk mengambil semua task dari Firestore
  static Future<List<Task>> findAll() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      // Mengambil snapshot dari koleksi 'tasks'
      QuerySnapshot<Map<String, dynamic>> snapshot = await db.collection('tasks').get();

      // Mapping data dari snapshot ke dalam list Task
      List<Task> tasks = snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();

      return tasks; // Mengembalikan list task
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  // Metode statis untuk mendapatkan task berdasarkan kategori
  static Future<List<Task>> findTasksByCategory(String categoryId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await db
          .collection('tasks')
          .where('category_id', isEqualTo: '/category/uw0sLWpsSWYFPfeTbijO')
          .get();

      // Mapping data from snapshot to a list of Task objects
      List<Task> tasks = snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();

      return tasks;
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  // Factory method untuk konversi data dari Firestore ke dalam objek Task
  factory Task.fromMap(Map<String, dynamic> map, String uid) {
    return Task(
      deadline: map['deadline'] != null ? (map['deadline'] as Timestamp).toDate() : null,
      desc: map['desc'] ?? 'No description',  // Nilai default jika deskripsi kosong
      name: map['name'] ?? 'Untitled',               // Nilai default jika name kosong
      reminder: map['reminder'] != null ? (map['reminder'] as Timestamp).toDate() : null,
      user_id: map['user_id'] is DocumentReference ? (map['user_id'] as DocumentReference).id : map['user_id'],
      category_id: map['category_id'] is DocumentReference ? (map['category_id'] as DocumentReference).id : map['category_id'],
    );
  }
}
