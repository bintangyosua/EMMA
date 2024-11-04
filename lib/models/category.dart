import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Category {
  final String uid;
  final String name;
  final String desc;

  Category({
    required this.uid,
    required this.name,
    required this.desc,
  });

  // Method untuk mengambil semua task dari Firestore
  static Future<List<Category>> findAll() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      // Mengambil snapshot dari koleksi 'tasks'
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await db.collection('category').get();

      // Mapping data dari snapshot ke dalam list Task
      List<Category> tasks = snapshot.docs.map((doc) {
        return Category.fromMap(doc.data(), doc.id);
      }).toList();

      return tasks; // Mengembalikan list task
    } catch (e) {
      return [];
    }
  }

  // Factory method untuk konversi data dari Firestore ke dalam objek Task
  factory Category.fromMap(Map<String, dynamic> map, String uid) {
    return Category(
        desc: map['desc'] ??
            'No description', // Nilai default jika deskripsi kosong
        name: map['name'] ?? 'Untitled', // Nilai default jika name kosong
        uid: uid);
  }
}
