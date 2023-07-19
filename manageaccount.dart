import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({Key? key}) : super(key: key);

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final accounts = snapshot.data!.docs;
            return ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final accountId = account.id;
                final accountData = account.data() as Map<String, dynamic>;

                final profilePictureUrl = accountData['profilePictureUrl'];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: profilePictureUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(profilePictureUrl),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.account_circle),
                          ),
                    title: Text('Account ID: $accountId'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username: ${accountData['username']}'),
                        Text('Email: ${accountData['email']}'),
                        Text('Name: ${accountData['name']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
