import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Market {
  final String title;
  final String imageURL;

  Market({required this.title, required this.imageURL});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: MarketList(),
  ));
}

class MarketList extends StatefulWidget {
  @override
  _MarketListState createState() => _MarketListState();
}

class _MarketListState extends State<MarketList> {
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    _firestore = FirebaseFirestore.instance;
  }

  Future<void> _addMarket(String title, File image) async {
    if (image != null) {
      // Upload the image to Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref().child('market_images/${DateTime.now()}.jpg');
      await storageReference.putFile(image);

      // Get the download URL of the uploaded image
      String imageURL = await storageReference.getDownloadURL();

      // Add the market to Firestore
      await _firestore.collection('markets').add({
        'title': title,
        'imageURL': imageURL,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Markets'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('markets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Market> markets = snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Market(title: data['title'], imageURL: data['imageURL']);
            }).toList();

            return ListView.builder(
              itemCount: markets.length,
              itemBuilder: (context, index) {
                final market = markets[index];
                return MarketCard(market: market);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (image != null) {
            _addMarket('New Market', File(image.path));
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MarketCard extends StatelessWidget {
  final Market market;

  MarketCard({required this.market});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(market.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          FutureBuilder<String>(
            future: FirebaseStorage.instance.ref(market.imageURL).getDownloadURL(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Container(
                  width: 80,
                  height: 80,
                  child: Image.network(snapshot.data!),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
