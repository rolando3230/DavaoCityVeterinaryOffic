import 'package:davaocityvet/chatsupport.dart';
import 'package:davaocityvet/createreport.dart';
import 'package:davaocityvet/historydashboardinspector.dart';
import 'package:davaocityvet/login.dart';
import 'package:davaocityvet/market.dart';
import 'package:davaocityvet/myevaluation.dart';
import 'package:davaocityvet/schedulescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen',
        style: TextStyle(
          fontSize: 30,
          color: Colors.white
        ),),
        actions: [Column(
             children: [
               Padding(
                 padding: const EdgeInsets.only(top: 5),
                 child: IconButton(
          onPressed: () async {
                _handleLogout(context);
          },
          icon: const Icon(Icons.logout_sharp,
          size: 25,),
        ),
               ),
    
             ],
           ),],
      ),
      body: Column(
        children:[ SizedBox(height: 25,),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16.0),
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              FeatureCard(
                icon: Icons.shopping_basket,
                title: 'Market',
                onTap: () {
                  
                     Navigator.push(context, MaterialPageRoute(builder: (context)
            => MarketList()));
                 
                },
              ),
              FeatureCard(
                icon: Icons.calendar_today,
                title: 'Schedule',
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context)
            =>  ScheduleScreen()));
                },
              ),
              FeatureCard(
                icon: Icons.assessment,
                title: 'Performance Evaluation',
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)
            =>  EvaluationScreen()));
                },
              ),
              FeatureCard(
                icon: Icons.chat_bubble,
                title: 'Chat Support',
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context)
            =>    GroupChat()));
                },
              ),
              FeatureCard(
                icon: Icons.library_books,
                title: 'Create Report',
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context)
            =>   const CreateReport(postid: 'id',)));
                },
              ),
              FeatureCard(
                icon: Icons.history,
                title: 'Report History',
                onTap: () {    
                   Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryDashBoardInspector()),
    );   
                },
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const FeatureCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
            ),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(fontSize: 16.0,
              color: Colors.blue[900],
              fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Handle Logout
      // Navigate to the login screen after successful logout using pushReplacement
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
    } catch (e) {
      print('Error logging out: $e');
    }
  }