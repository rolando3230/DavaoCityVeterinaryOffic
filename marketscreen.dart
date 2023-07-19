import 'package:flutter/material.dart';

class MarketScreen extends StatelessWidget {
  final List<String> imageAssets;
  final List<String> titles;

  MarketScreen({required this.imageAssets, required this.titles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market /Slaughter House'),
      ),
      body: ListView.builder(
        itemCount: imageAssets.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    titles[index],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 200.0, // Set a fixed height for the container
                  child: Image.asset(
                    imageAssets[index],
                    fit: BoxFit.contain, // Use BoxFit.contain for infinite aspect ratio
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  List<String> imageAssets = [
    'assets/images/DSAWED.jpg',
    'assets/images/EWDSAWE.jpg',
    'assets/images/DSAWED.jpg',
    'assets/images/EWDSAWE.jpg',
    'assets/images/FDSF.jpg',
    'assets/images/DSAWED.jpg',
  ];

  List<String> titles = [
    'Toril Public Market',
    'Boulevard Shit',
    'Talamo Slaughter House',
    'AMBOT',
    'KAPOY',
    'HUHUHU',
  ];

  runApp(MaterialApp(
    home: MarketScreen(imageAssets: imageAssets, titles: titles),
  ));
}
