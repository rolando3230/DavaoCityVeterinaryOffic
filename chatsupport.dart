import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SenderRole {
  admin,
  user,
}

class Message {
  final SenderRole senderRole;
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderRole,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Convert message to JSON
  Map<String, dynamic> toJson() {
    return {
      'senderRole': senderRole.toString(),
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create a message from a Firebase snapshot
  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Message(
      senderRole: data['senderRole'] == SenderRole.admin.toString() ? SenderRole.admin : SenderRole.user,
      senderId: data['senderId'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class FirebaseMessagingService {
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  // Send a message to Firebase
  Future<void> sendMessage(Message message) async {
    await messagesCollection.add(message.toJson());
  }

  // Retrieve all messages from Firebase
  Stream<List<Message>> getMessages() {
    return messagesCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromSnapshot(doc)).toList());
  }
}

class GroupChat extends StatefulWidget {
  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final FirebaseMessagingService messagingService = FirebaseMessagingService();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.isNotEmpty) {
      final senderRole = SenderRole.admin; // Replace with the current user's role (admin or user)
      final senderId = 'admin1'; // Replace with the current user's ID
      final message = Message(
        senderRole: senderRole,
        senderId: senderId,
        text: text,
        timestamp: DateTime.now(),
      );
      await messagingService.sendMessage(message);
      textController.clear();
      scrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: messagingService.getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.senderId == 'admin1'; // Replace with the current user's ID
                    return ListTile(
                      title: Text(
                        message.text,
                        style: TextStyle(
                          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        'Sender: ${message.senderId}',
                        style: TextStyle(
                          color: isCurrentUser ? Colors.blue : Colors.grey,
                        ),
                      ),
                      tileColor: isCurrentUser ? Colors.grey[200] : null,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      trailing: isCurrentUser ? Icon(Icons.person) : null,
                      leading: !isCurrentUser ? Icon(Icons.person) : null,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

