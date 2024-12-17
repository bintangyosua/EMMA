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
  String? selectedProfilePicture;

  // List of predefined profile pictures
  final List<String> profilePictures = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
    'assets/images/profile6.jpg',
  ];

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
        selectedProfilePicture =
            userDoc['profilePicture'] ?? profilePictures[0];
      });
    }
  }

  Future<void> refreshUserData() async {
    await fetchUserData();
  }

  void _showProfilePictureModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.color2,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: profilePictures.map((picturePath) {
                    return GestureDetector(
                      onTap: () async {
                        // Update profile picture in Firestore
                        User? currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .update({'profilePicture': picturePath});

                          setState(() {
                            selectedProfilePicture = picturePath;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedProfilePicture == picturePath
                                ? AppColors.color2
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(picturePath),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.color4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              selectedIcon: Icon(Icons.bar_chart, color: Colors.black),
              icon: Icon(Icons.bar_chart_outlined, color: Colors.black54),
              label: 'Statistics',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.task, color: Colors.black),
              icon: Icon(Icons.task_outlined, color: Colors.black54),
              label: 'Tasks',
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
                            onTap: _showProfilePictureModal,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.color2,
                              backgroundImage: selectedProfilePicture != null
                                  ? AssetImage(selectedProfilePicture!)
                                  : null,
                              child: selectedProfilePicture == null
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
                            onTap: _showProfilePictureModal,
                            child: Text(
                              "Change Profile Picture",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.color2,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
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
