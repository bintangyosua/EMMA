import 'package:emma/colors.dart';
import 'package:emma/eisenhower-matrix/eisenhower-matrix.page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emma/navigation-bar/update_profile.dart';
import 'package:emma/ui/login_screen.dart'; // Import your login page

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
        password = userDoc['password'];
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
              selectedIcon: Icon(Icons.search, color: Colors.black),
              icon: Icon(Icons.search_outlined, color: Colors.black54),
              label: 'Search',
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
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                elevation: 5,
                child: ListTile(
                  leading:
                      Icon(Icons.notifications_sharp, color: AppColors.color2),
                  title: Text('Notification 1'),
                  subtitle: Text('This is a notification'),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                elevation: 5,
                child: ListTile(
                  leading:
                      Icon(Icons.notifications_sharp, color: AppColors.color2),
                  title: Text('Notification 2'),
                  subtitle: Text('This is a notification'),
                ),
              ),
            ],
          ),
        ),
        username != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'EMMA',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 26.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Profile Text
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
                    // Profile Icon
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            const Color.fromARGB(255, 101, 101, 101),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
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
                        subtitle: Text('*************'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width:
                                200, // Set the width to ensure both buttons are the same size
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.color2,
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
                                      builder: (context) =>
                                          UpdateProfilePage()),
                                );
                              },
                              child: const Text(
                                "Update Profile",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 20), // Add some spacing between buttons
                          SizedBox(
                            width:
                                200, // Set the width to ensure both buttons are the same size
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
                                      builder: (context) =>
                                          LoginScreen()), // Replace with your login page
                                );
                              },
                              child: const Text(
                                "Log Out",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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
