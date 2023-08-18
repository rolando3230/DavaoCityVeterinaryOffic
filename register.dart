import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, user }

class Users1 {
  final String id;
  final String password;
  final String email;
  final String name;
  final String role;
  final String? profilePictureUrl;
  final DateTime? birthday;
  final String? address;
  final int? age;
  final String? gender;
  final int? contactNumber;

  Users1({
    required this.id,
    required this.password,
    required this.email,
    required this.name,
    required this.role,
    this.profilePictureUrl,
    this.birthday,
    this.address,
    this.age,
    this.gender,
    this.contactNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'email': email,
      'name': name,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'birthday': birthday,
      'address': address,
      'age': age,
      'gender': gender,
      'contactNumber': contactNumber,
    };
  }
}

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController birthdayController;
  late TextEditingController addressController;
  late TextEditingController ageController;
  late TextEditingController contactNumberController;
  late String error;
  UserRole selectedRole = UserRole.user;
  Uint8List? imageBytes;
  DateTime? birthday;
  String? selectedGender;
  int? age;
  int? contactNumber;
  bool isRegistering = false;
  double uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    birthdayController = TextEditingController();
    addressController = TextEditingController();
    ageController = TextEditingController();
    contactNumberController = TextEditingController();
    error = "";
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    addressController.dispose();
    ageController.dispose();
    contactNumberController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (pickedImage != null && pickedImage.files.isNotEmpty) {
        setState(() {
          imageBytes = pickedImage.files.single.bytes;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> pickBirthday() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        birthday = pickedDate;
        birthdayController.text = DateFormat('yyyy-MM-dd').format(birthday!);
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } catch (e) {
      print('Error creating user: $e');
      setState(() {
        error = "Error creating user. Please try again.";
      });
      // Throw an error to stop the function execution
      throw e;
    }
  }

  bool _passwordsMatch() {
    return passwordController.text == confirmPasswordController.text;
  }

  Future<void> registerUser() async {
    setState(() {
      isRegistering = true;
      error = "";
      uploadProgress = 0.0;
    });

    try {
      // Create the user in Firebase Authentication
      await createUserWithEmailAndPassword();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = Users1(
          id: currentUser.uid,
          password: passwordController.text,
          email: emailController.text,
          name: nameController.text,
          role: selectedRole == UserRole.admin ? 'admin' : 'user',
          profilePictureUrl: null,
          birthday: birthday,
          address: addressController.text,
          age: age,
          gender: selectedGender,
          contactNumber: contactNumber,
        ).toJson();

        final usersCollection = FirebaseFirestore.instance.collection('Users');

        // Add the new user data to Firestore
        await usersCollection.doc(currentUser.uid).set(userData);

        // If an image is picked, upload it to Firebase Storage and update the profilePictureUrl
        if (imageBytes != null) {
          final Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${currentUser.uid}.jpg');
          final UploadTask uploadTask = storageRef.putData(imageBytes!);

          // Update the progress of the image upload
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            setState(() {
              uploadProgress = progress;
            });
          });

          final TaskSnapshot storageSnapshot = await uploadTask;
          final profilePictureUrl = await storageSnapshot.ref.getDownloadURL();

          // Update the user data with the profile picture URL
          userData['profilePictureUrl'] = profilePictureUrl;
          await usersCollection.doc(currentUser.uid).set(userData); // Update the data in Firestore
        }

        setState(() {
          error = "";
          isRegistering = false;
        });

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Account registration successful!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e, stackTrace) {
      print('$e\n$stackTrace');
      setState(() {
        error = e.toString();
        isRegistering = false;
      });
    }
  }

  Future<int> generateNumericId() async {
    // You can implement your own logic here to generate a unique numeric ID
    // This might involve querying Firestore for the highest existing numeric ID,
    // and then incrementing it to get the next available ID.

    // For demonstration purposes, let's assume a simple counter approach:
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Counters')
        .doc('userIdCounter')
        .get();
    int currentCounter = snapshot.exists ? snapshot['count'] : 0;

    // Increment the counter for the next user
    final nextCounter = currentCounter + 1;
    await FirebaseFirestore.instance
        .collection('Counters')
        .doc('userIdCounter')
        .set({'count': nextCounter});

    return nextCounter;
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
                  onTap: () async {
                    await pickImage();
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
                    child: imageBytes == null ? const Icon(Icons.add_a_photo) : null,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter complete name',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter email',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Confirm password',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: InkWell(
                          onTap: () async {
                            await pickBirthday();
                          },
                          child: IgnorePointer(
                            child: TextField(
                              controller: birthdayController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter birthday',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: contactNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter contact number',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {
                              contactNumber = int.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter age',
                            suffixIcon: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (age != null) {
                                        age = (age! + 1).clamp(0, 99);
                                        ageController.text = age.toString();
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.keyboard_arrow_up),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (age != null && age! > 0) {
                                        age = (age! - 1).clamp(0, 99);
                                        ageController.text = age.toString();
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.keyboard_arrow_down),
                                ),
                              ],
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {
                              age = int.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter address',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButtonFormField<String>(
                          value: selectedGender,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGender = newValue;
                            });
                          },
                          items: <String>['Male', 'Female']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select gender',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
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
                          decoration: const InputDecoration(
                            labelText: 'Select role',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_passwordsMatch()) {
                        registerUser();
                      } else {
                        setState(() {
                          error = "Passwords do not match.";
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'REGISTER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isRegistering) CircularProgressIndicator(),
                      ],
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
}