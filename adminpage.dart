import 'package:davaocityvet/Register.dart';
import 'package:davaocityvet/admindashboard.dart';
import 'package:davaocityvet/darkmood.dart';
import 'package:davaocityvet/historydashboardadmin.dart';
import 'package:davaocityvet/login.dart';
import 'package:davaocityvet/mangeacount.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  // Function to handle logout
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Handle Logout
      // Navigate to the login screen after successful logout using pushReplacement
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin DashBoard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/city.jpg'),
                    radius: 30,
                  ),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'VetInspect',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChartsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: const Text('Reports'),
              onTap: () {
                // TODO: Handle Reports navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: const Text('Accomplishment Report'),
              onTap: () {
                // TODO: Handle Accomplishment Report navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.supervised_user_circle),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserManagementScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryDashBoardAdmin()));
              },
            ),
            ListTile(
              leading: Icon(Icons.list_alt),
              title: const Text('Audit Logs'),
              onTap: () {
                // TODO: Handle Audit Logs navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.file_copy),
              title: const Text('Generate Report'),
              onTap: () {
                // TODO: Handle Generate Report navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DarkModeApp()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: const Text('Register Account'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Admin!'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Register(),
                  ),
                );
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
