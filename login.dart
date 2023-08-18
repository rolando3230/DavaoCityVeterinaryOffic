import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:davaocityvet/adminpage.dart';
import 'package:davaocityvet/homescreen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController identifierController;
  late TextEditingController passwordController;
  late String error;

  @override
  void initState() {
    super.initState();
    identifierController = TextEditingController();
    passwordController = TextEditingController();
    error = "";
    checkCurrentUser();
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            children: [
              const SizedBox(height: 130),
              Image.asset(
                'assets/images/city.jpg',
                height: 200,
                width: 200,
              ),
              const Text(
                'Login',
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: identifierController,
                decoration: const InputDecoration(
                  labelText: 'Enter Your Email Address or ID',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loginUser,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0D47A1)),
                  minimumSize: MaterialStateProperty.all<Size>(const Size(250, 50)),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loginUser() async {
    try {
      final String identifier = identifierController.text.trim();
      UserCredential userCredential;

      // Determine whether the identifier is an email or an ID
      if (identifier.contains('@')) {
        // Identifier contains '@', treat it as an email
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: identifier,
          password: passwordController.text.trim(),
        );
      } else {
        // Identifier doesn't contain '@', treat it as an ID
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: await getUserEmailById(identifier), // Fetch email by ID
          password: passwordController.text.trim(),
        );
      }

      final User? user = userCredential.user;

      if (user != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          final role = userData['role'];

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          } else if (role == 'user') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            setState(() {
              error = 'Invalid role';
            });
          }
        } else {
          setState(() {
            error = 'User data not found';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message!;
      });
    }
  }

  Future<String> getUserEmailById(String id) async {
    // Implement your logic to fetch user email by ID from Firestore
    // For example:
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get();

    if (userSnapshot.exists) {
      return userSnapshot.get('email');
    } else {
      throw Exception('User not found');
    }
  }

  void checkCurrentUser() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final role = userData['role'];

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
        } else if (role == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          setState(() {
            error = 'Invalid role';
          });
        }
      } else {
        setState(() {
          error = 'User data not found';
        });
      }
    }
  }
}
