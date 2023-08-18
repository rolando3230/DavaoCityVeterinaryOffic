import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryDashBoardAdmin extends StatefulWidget {
  const HistoryDashBoardAdmin({Key? key}) : super(key: key);

  @override
  _HistoryDashBoardAdminState createState() => _HistoryDashBoardAdminState();
}

class _HistoryDashBoardAdminState extends State<HistoryDashBoardAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Report').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;

              final establishment = report['establishment'] as String?;
              final date = report['date'] as String?;
              final location = report['location'] as String?;
              final submittedBy = report['submittedby'] as String?;

              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  title: Text(
                    establishment ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      Text(
                        'Submission ID:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        reports[index].id,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Date:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        date ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      FutureBuilder<User?>(
                        future: FirebaseAuth.instance.authStateChanges().first,
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Text('Loading...');
                          }
                          if (userSnapshot.hasData) {
                            final user = userSnapshot.data!;
                            return Text(
                              'Submitted by: ${user.displayName ?? user.email}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return Text('Submitted by: N/A');
                        },
                      ),
                      const SizedBox(height: 4.0),
                    ],
                  ),
                  trailing: Text(
                    location ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
