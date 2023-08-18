import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Evaluation {
  final String userName;
  final double timeManagementRating;
  final double communicationRating;
  final double attentionToDetailRating;
  final String feedback;

  Evaluation({
    required this.userName,
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
  TextEditingController _userNameController = TextEditingController();
  late String _selectedUserName;
  double _timeManagementRating = 0;
  double _communicationRating = 0;
  double _attentionToDetailRating = 0;
  late String _feedback;

  List<String> matchingUserNames = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedUserName = '';
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                  controller: _userNameController,
                  onTap: () {
                    setState(() {
                      matchingUserNames = [];
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedUserName = value;
                    });
                    updateMatchingUserNames(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'User Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a user name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8.0),
                if (_isLoading)
                  CircularProgressIndicator()
                else if (_selectedUserName.isNotEmpty)
                  Expanded(
                    child: Container(
                      height: matchingUserNames.length * 40.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: matchingUserNames.length,
                        itemBuilder: (context, index) {
                          String userName = matchingUserNames[index];
                          int matchStartIndex = userName.toLowerCase().indexOf(_selectedUserName.toLowerCase());

                          return ListTile(
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  if (matchStartIndex >= 0)
                                    TextSpan(text: userName.substring(0, matchStartIndex)),
                                  if (matchStartIndex >= 0)
                                    TextSpan(
                                      text: userName.substring(matchStartIndex, matchStartIndex + _selectedUserName.length),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                  if (matchStartIndex >= 0)
                                    TextSpan(text: userName.substring(matchStartIndex + _selectedUserName.length)),
                                  if (matchStartIndex < 0)
                                    TextSpan(text: userName),
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedUserName = userName;
                                matchingUserNames.clear();
                                _userNameController.text = _selectedUserName;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 8.0),
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
                  maxLines: null, // Allow for multiple lines
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
                        userName: _selectedUserName,
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
      ),
    );
  }

  Future<List<String>> fetchUserNames(String input) async {
    List<String> searchTerms = input.replaceAll(' ', '').toLowerCase().split(' ');

    QuerySnapshot querySnapshot = await _firestore.collection('Users')
        .where('name', arrayContainsAny: searchTerms)
        .get();

    List<String> userNames = [];
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      String userName = document['name'];
      userNames.add(userName);
    }

    return userNames;
  }

  Future<void> updateMatchingUserNames(String input) async {
    setState(() {
      _isLoading = true;
      matchingUserNames = []; // Clear the list immediately
    });

    try {
      List<String> usersFromFirestore = await fetchUserNames(input);

      setState(() {
        _isLoading = false;
        matchingUserNames = usersFromFirestore;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user names: $error');
    }
  }

  void _storeEvaluation(Evaluation evaluation) {
    String cleanedUserName = evaluation.userName.replaceAll(' ', '').toLowerCase();
    _firestore.collection('Users').get().then((querySnapshot) {
      var matchingUsers = querySnapshot.docs.where((doc) => doc['name'].replaceAll(' ', '').trim().toLowerCase() == cleanedUserName);
      if (matchingUsers.isNotEmpty) {
        var userDoc = matchingUsers.first;
        userDoc.reference.collection('evaluations').add({
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('User with the provided name not found.'),
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
      }
    });
  }
}


