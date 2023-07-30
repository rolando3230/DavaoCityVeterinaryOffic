import 'package:davaocityvet/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(PerformanceApp());
}

class PerformanceApp extends StatelessWidget {
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
  double timeManagementRating;
  double communicationRating;
  double attentionToDetailsRating;
  String feedback;

  Evaluation({
    required this.employeeName,
    this.timeManagementRating = 0.0,
    this.communicationRating = 0.0,
    this.attentionToDetailsRating = 0.0,
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
            employeeName: 'YAWA KA CARDO', // Replace with user's ID-based employee name
            feedback: '',
          ),
          onFeedbackChanged: (value) {},
          onRateButtonPressed: (rating) {
            // Store the ratings and feedback in Firestore
            _storeEvaluation(
              employeeName: 'YAWA KA CARDO', // Replace with user's ID-based employee name
              timeManagementRating: rating[0],
              communicationRating: rating[1],
              attentionToDetailsRating: rating[2],
              feedback: rating[3],
              onSuccess: () {
                // Show alert dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Success'),
                    content: Text('Ratings successfully submitted.'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              onError: (error) {
                // Show alert dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text('Failed to submit ratings: $error'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _storeEvaluation({
    required String employeeName,
    required double timeManagementRating,
    required double communicationRating,
    required double attentionToDetailsRating,
    required String feedback,
    required void Function() onSuccess,
    required void Function(dynamic) onError,
  }) {
    _firestore.collection('evaluations').add({
      'employeeName': employeeName,
      'timeManagementRating': timeManagementRating,
      'communicationRating': communicationRating,
      'attentionToDetailsRating': attentionToDetailsRating,
      'feedback': feedback,
    }).then((value) {
      print('Evaluation stored in Firestore: $value');
      onSuccess();
    }).catchError((error) {
      print('Failed to store evaluation: $error');
      onError(error);
    });
  }
}

class EvaluationCard extends StatelessWidget {
  final Evaluation evaluation;
  final ValueChanged<String> onFeedbackChanged;
  final ValueChanged<List<dynamic>> onRateButtonPressed;

  EvaluationCard({
    required this.evaluation,
    required this.onFeedbackChanged,
    required this.onRateButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    List<dynamic> rating = [
      evaluation.timeManagementRating,
      evaluation.communicationRating,
      evaluation.attentionToDetailsRating,
      evaluation.feedback,
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
                'Submit Evaluation',
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

             
