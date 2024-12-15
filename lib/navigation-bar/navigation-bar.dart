import 'package:emma/colors.dart';
import 'package:emma/eisenhower-matrix/eisenhower-matrix.page.dart';
import 'package:emma/finished-tasks/finished_task.page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emma/navigation-bar/update_profile.dart';
import 'package:emma/ui/login_screen.dart';
import 'package:emma/navigation-bar/statistic_page.dart';

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
        password = userDoc['password']; // Ambil password dari Firestore
      });
    }
  }

  Future<void> refreshUserData() async {
    await fetchUserData();
  }

  Future<void> deleteTask(String taskId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete ?? false) {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
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
                  Icon(Icons.bar_chart, color: Colors.black), // Updated icon
              icon: Icon(Icons.task, color: Colors.black54), // Updated icon
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
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                const Color.fromARGB(255, 101, 101, 101),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8.0),
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
                              // Refresh user data after returning from update profile page
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
                    const SizedBox(height: 16.0),
                    // User Details
                    Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading:
                            const Icon(Icons.person, color: AppColors.color2),
                        title: const Text('Username'),
                        subtitle: Text(username!),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.white,
                      child: ListTile(
                        leading:
                            const Icon(Icons.email, color: AppColors.color2),
                        title: const Text('Email'),
                        subtitle: Text(email!),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.white,
                      child: ListTile(
                        leading:
                            const Icon(Icons.lock, color: AppColors.color2),
                        title: const Text('Password'),
                        subtitle: Text(
                            '*' * (password?.length ?? 0)), // Tampilkan bintang
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color4,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 32,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          },
                          child: const Text(
                            "Log Out",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ][currentPageIndex],
    );
  }
}
