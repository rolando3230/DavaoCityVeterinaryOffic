import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

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
        profilePictureUrl = map?['profilePictureUrl'] ?? '',
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

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
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

  Future<Uint8List?> getProfilePicture(String? url) async {
    if (url == null || url.isEmpty) {
      return null;
    }

    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      final data = await ref.getData();
      return data;
    } catch (e) {
      print('Error fetching profile picture: $e');
      return null;
    }
  }

  void _showContactInfoDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${user.address ?? 'N/A'}'),
              Text('Email: ${user.email}'),
              Text('Contact Number: ${user.contactNumber ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('User Management'),
          leading: IconButton(icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context); 
          },
          ),
        ),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
                  ).then((value) {
                    if (value == true) {
                      fetchUsers();
                    }
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Container(
                        width: 100,
                        height: 100,
                        child: FutureBuilder<Uint8List?>(
                          future: getProfilePicture(user.profilePictureUrl),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError || snapshot.data == null) {
                              return Image.asset(
                                'assets/images/boy.png',
                                width: 100,
                                height: 100,
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Image.memory(
                                  snapshot.data!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                          },
                        ),
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
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              _showContactInfoDialog(user);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  SizedBox(width: 30,),
                                  Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Contact Info',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
  late TextEditingController profilePictureUrlController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    ageController = TextEditingController(text: widget.user.age?.toString() ?? '');
    addressController = TextEditingController(text: widget.user.address ?? '');
    birthdayController = TextEditingController(text: widget.user.birthday != null ? widget.user.birthday!.toString() : '');
    contactNumberController = TextEditingController(text: widget.user.contactNumber?.toString() ?? '');
    profilePictureUrlController = TextEditingController(text: widget.user.profilePictureUrl ?? '');
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
                Navigator.of(context).pop();
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
                      'profilePictureUrl': profilePictureUrlController.text,
                    },
                  );
                  Navigator.of(context).pop();
                  Navigator.pop(context, true);
                } catch (e) {
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
            TextField(
              controller: profilePictureUrlController,
              decoration: InputDecoration(labelText: 'Profile Picture URL'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
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

