import 'package:emma/colors.dart';
import 'package:emma/eisenhower-matrix/eisenhower-matrix.page.dart';
import 'package:emma/finished-tasks/finished_task.page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emma/navigation-bar/update_profile.dart';
import 'package:emma/ui/login_screen.dart';
import 'package:emma/navigation-bar/statistic_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  String? username;
  String? email;
  String? password;
  File? profilePicture;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        username = userDoc['name'];
        email = userDoc['email'];
        password = userDoc['password'];
      });
    }
  }

  Future<void> refreshUserData() async {
    await fetchUserData();
  }

  Future<void> confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirm ?? false) {
      FirebaseAuth.instance.signOut(); // Perform logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        profilePicture = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.color1,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home, color: Colors.black),
              icon: Icon(Icons.home_outlined, color: Colors.black54),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon:
                  Icon(Icons.bar_chart, color: Colors.black), // Updated icon
              icon: Icon(Icons.bar_chart_outlined,
                  color: Colors.black54), // Updated icon
              label: 'Statistics', // Updated label
            ),
            NavigationDestination(
              selectedIcon:
                  Icon(Icons.task, color: Colors.black), // Updated icon
              icon: Icon(Icons.task_outlined, color: Colors.black54),
              label: 'Tasks', // Updated label
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person, color: Colors.black),
              icon: Icon(Icons.person_outlined, color: Colors.black54),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: <Widget>[
        EisenhowerMatrixPage(),
        StatisticPage(),
        TaskListPage(),
        username != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.color2,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: pickImage,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.color2,
                              backgroundImage: profilePicture != null
                                  ? FileImage(profilePicture!)
                                  : null,
                              child: profilePicture == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateProfilePage(
                                    reloadDataCallback: refreshUserData,
                                  ),
                                ),
                              );
                              await refreshUserData();
                            },
                            child: Text(
                              "Update Profile",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.color2,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        leading:
                            const Icon(Icons.person, color: AppColors.color2),
                        title: const Text('Username'),
                        subtitle: Text(username!),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        leading:
                            const Icon(Icons.email, color: AppColors.color2),
                        title: const Text('Email'),
                        subtitle: Text(email!),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        leading:
                            const Icon(Icons.lock, color: AppColors.color2),
                        title: const Text('Password'),
                        subtitle: Text('*' * (password?.length ?? 0)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color4,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 32,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 3,
                          ),
                          onPressed: confirmLogout,
                          child: const Text(
                            "Log Out",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator())
      ][currentPageIndex],
    );
  }
}
