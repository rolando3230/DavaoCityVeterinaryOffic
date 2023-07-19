import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EvaluationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evaluation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EvaluationScreen(),
    );
  }
}

class Evaluation {
  final String userId;
  final double timeManagementRating;
  final double communicationRating;
  final double attentionToDetailRating;
  final String feedback;

  Evaluation({
    required this.userId,
    required this.timeManagementRating,
    required this.communicationRating,
    required this.attentionToDetailRating,
    required this.feedback,
  });
}

class EvaluationScreen extends StatefulWidget {
  @override
  _EvaluationScreenState createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late String _selectedUserId;
  double _timeManagementRating = 0;
  double _communicationRating = 0;
  double _attentionToDetailRating = 0;
  late String _feedback;

  @override
  void initState() {
    super.initState();
    _selectedUserId = ''; // Initialize with an empty string
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluate User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'User ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a user ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Time Management Rating:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RatingBar.builder(
                initialRating: _timeManagementRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30.0,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _timeManagementRating = rating;
                  });
                },
              ),
              SizedBox(height: 8.0),
              Text(
                'Communication Rating:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RatingBar.builder(
                initialRating: _communicationRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30.0,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _communicationRating = rating;
                  });
                },
              ),
              SizedBox(height: 8.0),
              Text(
                'Attention to Detail Rating:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RatingBar.builder(
                initialRating: _attentionToDetailRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30.0,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _attentionToDetailRating = rating;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                onChanged: (value) {
                  _feedback = value;
                },
                decoration: InputDecoration(
                  labelText: 'Feedback',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide feedback';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Evaluation evaluation = Evaluation(
                      userId: _selectedUserId,
                      timeManagementRating: _timeManagementRating,
                      communicationRating: _communicationRating,
                      attentionToDetailRating: _attentionToDetailRating,
                      feedback: _feedback,
                    );
                    _storeEvaluation(evaluation);
                  }
                },
                child: Text('Submit Evaluation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _storeEvaluation(Evaluation evaluation) {
    _firestore
        .collection('users')
        .doc(evaluation.userId)
        .collection('evaluations')
        .add({
      'timeManagementRating': evaluation.timeManagementRating,
      'communicationRating': evaluation.communicationRating,
      'attentionToDetailRating': evaluation.attentionToDetailRating,
      'feedback': evaluation.feedback,
    }).then((value) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Evaluation submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to submit evaluation.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}
