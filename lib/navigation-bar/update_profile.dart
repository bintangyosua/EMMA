import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadCurrentUserData();
  }

  Future<void> loadCurrentUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      _usernameController.text = userDoc['name'];
      _emailController.text = userDoc['email'];
      _passwordController.text = userDoc['password'];
    }
  }

  Future<void> updateProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'name': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        });

        // Optionally, update the Firebase Auth email or password
        await currentUser.updateEmail(_emailController.text);
        await currentUser.updatePassword(_passwordController.text);

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Profile updated successfully!"),
        ));

        // Navigate back to profile page
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Update failed. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
