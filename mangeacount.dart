import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String? profilePictureUrl;
  int? age;
  String? address;
  DateTime? birthday;
  int? contactNumber;

  User({
    this.id = '',
    this.name = '',
    this.email = '',
    this.password = '',
    this.profilePictureUrl,
    this.age,
    this.address,
    this.birthday,
    this.contactNumber,
  });

  User.fromMap(Map<String, dynamic>? map)
      : id = map?['id'] ?? '',
        name = map?['name'] ?? '',
        email = map?['email'] ?? '',
        password = map?['password'] ?? '',
        profilePictureUrl = map?['profilePictureUrl'],
        age = map?['age'],
        address = map?['address'],
        birthday = (map?['birthday'] as Timestamp?)?.toDate(),
        contactNumber = map?['contactNumber'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profilePictureUrl': profilePictureUrl,
      'age': age,
      'address': address,
      'birthday': birthday,
      'contactNumber': contactNumber,
    };
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manage User',
      home: UserManagementScreen(),
    );
  }
}

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    // Call the function to fetch user data when the screen loads
    fetchUsers();
  }

  Future<List<User>> getUsersFromFirestore() async {
    List<User> users = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Users').get();
      snapshot.docs.forEach((doc) {
        users.add(User.fromMap(doc.data() as Map<String, dynamic>?));
      });
    } catch (e) {
      // Handle errors
      print(e.toString());
    }
    return users;
  }

  void fetchUsers() async {
    List<User> userList = await getUsersFromFirestore();
    setState(() {
      users = userList;
    });
  }

  void deleteUser(String userId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('Users').doc(userId).delete();
                  Navigator.of(context).pop(); // Close the dialog
                  fetchUsers(); // Refresh the user list after deletion
                } catch (e) {
                  // Handle errors
                  print(e.toString());
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List?> getProfilePicture(String? url) async {
    if (url == null || url.isEmpty) return null;

    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      final data = await ref.getData();
      return data;
    } catch (e) {
      print('Error fetching profile picture: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // Display 5 cards in a row
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                // Implement update functionality here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
                ).then((value) {
                  // Trigger a refresh of the user list after updating
                  if (value == true) {
                    fetchUsers();
                  }
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<Uint8List?>(
                      future: getProfilePicture(user.profilePictureUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
                          return CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 25,
                            backgroundImage: MemoryImage(snapshot.data!),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(user.email),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditUserScreen extends StatefulWidget {
  final User user;

  EditUserScreen({required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController ageController;
  late TextEditingController addressController;
  late TextEditingController birthdayController;
  late TextEditingController contactNumberController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    ageController = TextEditingController(text: widget.user.age?.toString() ?? '');
    addressController = TextEditingController(text: widget.user.address ?? '');
    birthdayController = TextEditingController(text: widget.user.birthday != null ? widget.user.birthday!.toString() : '');
    contactNumberController = TextEditingController(text: widget.user.contactNumber?.toString() ?? '');
  }

  void updateUser() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Update'),
          content: Text('Are you sure you want to update this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('Users').doc(widget.user.id).update(
                    {
                      'name': nameController.text,
                      'email': emailController.text,
                      'age': int.tryParse(ageController.text),
                      'address': addressController.text,
                      'birthday': DateTime.tryParse(birthdayController.text),
                      'contactNumber': int.tryParse(contactNumberController.text),
                    },
                  );
                  Navigator.of(context).pop(); // Close the dialog
                  // Notify the previous screen that the user data has been updated
                  Navigator.pop(context, true);
                } catch (e) {
                  // Handle errors
                  print(e.toString());
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: birthdayController,
              decoration: InputDecoration(labelText: 'Birthday (YYYY-MM-DD)'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contactNumberController,
              decoration: InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement update user functionality here
                updateUser();
              },
              child: Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}
