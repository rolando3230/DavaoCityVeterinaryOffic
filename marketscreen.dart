import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';



class FirebaseService {
  final CollectionReference marketCollection = FirebaseFirestore.instance.collection('markets');

  Future<List<Map<String, dynamic>>> getMarketData() async {
    QuerySnapshot snapshot = await marketCollection.get();
    List<Map<String, dynamic>> data = snapshot.docs.map((DocumentSnapshot doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      docData['id'] = doc.id; // Add document ID for future reference
      return docData;
    }).toList();

    return data;
  }

  Future<void> uploadImageToStorage(String imagePath, String imageName) async {
    Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');
    UploadTask uploadTask = storageReference.putFile(File(imagePath));
    await uploadTask.whenComplete(() => print('Image uploaded'));
  }
}

class MarketScreen extends StatelessWidget {
  Future<void> _pickAndUploadImage(BuildContext context) async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery); // Use pickImage

    if (pickedImage != null) {
      String imagePath = pickedImage.path;
      String imageName = pickedImage.name!;
      await FirebaseService().uploadImageToStorage(imagePath, imageName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market / Slaughter House'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUploadImage(context),
        child: Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirebaseService().getMarketData(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> marketData = snapshot.data!;
            return ListView.builder(
              itemCount: marketData.length,
              itemBuilder: (BuildContext context, int index) {
                String imageUrl = marketData[index]['images'];
                return Card(
                  margin: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          marketData[index]['title'],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        height: 200.0,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
