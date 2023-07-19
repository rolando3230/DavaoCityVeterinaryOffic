import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Users1 {
  final String id;
  final String username;
  final String password;
  final String email;
  final String name;
  final String role;

  Users1({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.name,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late String error;
  UserRole selectedRole = UserRole.user;

  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    error = "";
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Account'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        imageFile != null ? FileImage(File(imageFile!.path)) : null,
                    child: imageFile == null ? const Icon(Icons.add_a_photo) : null,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: usernameController,
                    onChanged: (content) {
                      setState(() {
                        emailController.text = content;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter username',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter password',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter email',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter name',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    onChanged: (UserRole? newValue) {
                      setState(() {
                        selectedRole = newValue!;
                      });
                    },
                    items: UserRole.values.map<DropdownMenuItem<UserRole>>(
                      (UserRole role) {
                        return DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(role == UserRole.admin ? 'Admin' : 'User'),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      registerUser();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      createUser();

      setState(() {
        error = "";
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        error = e.message.toString();
      });
    }
    Navigator.pop(context);
  }

  Future<void> createUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final docUser = FirebaseFirestore.instance.collection('Users').doc(userId);

    final newUser = Users1(
      id: userId,
      username: usernameController.text,
      password: passwordController.text,
      email: emailController.text,
      name: nameController.text,
      role: selectedRole == UserRole.admin ? 'admin' : 'user',
    );

    final json = newUser.toJson();
    await docUser.set(json);

    Navigator.pop(context);
  }
}

enum UserRole { admin, user }
