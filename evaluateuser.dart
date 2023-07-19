import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huhu/homescreen.dart';

class PerformanceApp extends StatelessWidget {
  const PerformanceApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Performance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EvaluationListScreen(),
    );
  }
}

class Evaluation {
  final String employeeName;
  final double timeManagementRating;
  final double communicationRating;
  final double attentionToDetailsRating;
  String feedback;

  Evaluation({
    required this.employeeName,
    required this.timeManagementRating,
    required this.communicationRating,
    required this.attentionToDetailsRating,
    required this.feedback,
  });
}

class EvaluationListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Evaluations'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Center(
        child: EvaluationCard(
          evaluation: Evaluation(
            employeeName: 'YAWA KA CARDO',
            timeManagementRating: 4.5,
            communicationRating: 3.0,
            attentionToDetailsRating: 4.0,
            feedback: '',
          ),
          onFeedbackChanged: (value) {},
          onRateButtonPressed: (rating) {
            // Store the rating in Firestore
            _storeRating(
              employeeName: 'YAWA KA CARDO',
              timeManagementRating: rating[0],
              communicationRating: rating[1],
              attentionToDetailsRating: rating[2],
            );
          },
        ),
      ),
    );
  }

  void _storeRating({
    required String employeeName,
    required double timeManagementRating,
    required double communicationRating,
    required double attentionToDetailsRating,
  }) {
    _firestore.collection('ratings').add({
      'employeeName': employeeName,
      'timeManagementRating': timeManagementRating,
      'communicationRating': communicationRating,
      'attentionToDetailsRating': attentionToDetailsRating,
    }).then((value) {
      print('Rating stored in Firestore: $value');
    }).catchError((error) {
      print('Failed to store rating: $error');
    });
  }
}

class EvaluationCard extends StatelessWidget {
  final Evaluation evaluation;
  final ValueChanged<String> onFeedbackChanged;
  final ValueChanged<List<double>> onRateButtonPressed;

  EvaluationCard({
    required this.evaluation,
    required this.onFeedbackChanged,
    required this.onRateButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    List<double> rating = [
      evaluation.timeManagementRating,
      evaluation.communicationRating,
      evaluation.attentionToDetailsRating,
    ];

    return Card(
      margin: EdgeInsets.all(8.0),
      color: Colors.white, // Set the background color to white
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/cardo.jpg'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Employee: ${evaluation.employeeName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time Management:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RatingBar(
                  initialRating: rating[0],
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber),
                    half: Icon(Icons.star_half, color: Colors.amber),
                    empty: Icon(Icons.star_border, color: Colors.amber),
                  ),
                  onRatingUpdate: (value) {
                    rating[0] = value;
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Communication:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RatingBar(
                  initialRating: rating[1],
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber),
                    half: Icon(Icons.star_half, color: Colors.amber),
                    empty: Icon(Icons.star_border, color: Colors.amber),
                  ),
                  onRatingUpdate: (value) {
                    rating[1] = value;
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attention to Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RatingBar(
                  initialRating: rating[2],
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                                    itemCount: 5,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber),
                    half: Icon(Icons.star_half, color: Colors.amber),
                    empty: Icon(Icons.star_border, color: Colors.amber),
                  ),
                  onRatingUpdate: (value) {
                    rating[2] = value;
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              onChanged: onFeedbackChanged,
              decoration: InputDecoration(
                labelText: 'Feedback',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                onRateButtonPressed(rating);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                primary: Colors.blue, // Set button background color
              ),
              child: Text(
                'Submit Rating',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

