import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Task {
  final String? uid;
  final DateTime? deadline;
  final String desc;
  final String name;
  final DateTime? reminder;
  final String? user_id;
  final String category_id;
  bool isCrossedOut;

  Task(
      {this.uid,
      required this.deadline,
      required this.desc,
      required this.name,
      required this.reminder,
      required this.user_id,
      required this.category_id,
      this.isCrossedOut = false});

  Map<String, dynamic> toMap() {
    return {
      'deadline': deadline,
      'desc': desc,
      'name': name,
      'reminder': reminder,
      'user_id': user_id,
      'category_id': category_id,
    };
  }

  static Future<Task?> findOne(String uid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await db.collection('tasks').doc(uid).get();
      return Task.fromMap(snapshot.data()!, uid);
    } catch (e) {
      return null;
      // print(e);
    }
  }

  Future<bool> delete() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db.collection('tasks').doc(uid).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Method untuk mengambil semua task dari Firestore
  static Future<List<Task>> findAll() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      // Mengambil snapshot dari koleksi 'tasks'
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await db.collection('tasks').get();

      // Mapping data dari snapshot ke dalam list Task
      List<Task> tasks = snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();

      return tasks; // Mengembalikan list task
    } catch (e) {
      return [];
    }
  }

  Future<bool> save() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String? currentUid =
        uid ?? db.collection('tasks').doc().id; // Generate if uid is null
    try {
      await db.collection('tasks').doc(currentUid).set(toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Metode statis untuk mendapatkan task berdasarkan kategori
  static Future<List<Task>> findTasksByCategory(String categoryId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

    try {
      // Query berdasarkan category_id
      QuerySnapshot<Map<String, dynamic>> snapshot = await db
          .collection('tasks')
          .where('category_id', isEqualTo: categoryId)
          .where('user_id', isEqualTo: currentUser?.uid)
          .get();

      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Factory method untuk konversi data dari Firestore ke dalam objek Task
  factory Task.fromMap(Map<String, dynamic> map, String uid) {
    return Task(
        deadline: map['deadline'] != null
            ? (map['deadline'] as Timestamp).toDate()
            : null,
        desc: map['desc'] ??
            'No description', // Nilai default jika deskripsi kosong
        name: map['name'] ?? 'Untitled', // Nilai default jika name kosong
        reminder: map['reminder'] != null
            ? (map['reminder'] as Timestamp).toDate()
            : null,
        user_id: map['user_id'] is DocumentReference
            ? (map['user_id'] as DocumentReference).id
            : map['user_id'],
        category_id: map['category_id'] is DocumentReference
            ? (map['category_id'] as DocumentReference).id
            : map['category_id'],
        uid: uid);
  }

  static DateTime? parseDateTime(String dateString) {
    try {
      // Memeriksa jika string dalam format DateTime
      if (dateString.contains('-')) {
        // Jika string adalah format DateTime (seperti '2024-11-14 00:00:00')
        return DateTime.parse(dateString);
      } else {
        // Mem-parsing jika dalam format lain, misalnya 'dd/MM/yyyy'
        return DateFormat('dd/MM/yyyy').parse(dateString);
      }
    } catch (e) {
      print("Error parsing date: $e");
      return null; // Atau bisa return DateTime.now() atau nilai default lainnya
    }
  }
}
