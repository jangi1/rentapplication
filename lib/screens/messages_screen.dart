import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/message_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'chat_room_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    final db = DatabaseService();

    if (currentUser == null) {
      return const Center(child: Text('Please log in to see your messages.'));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: db.getAllUserMessages(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // Group by conversation (participants)
          final Map<String, MessageModel> conversations = {};
          for (var msg in snapshot.data!) {
            final participants = List<String>.from(msg.participants);
            participants.sort();
            final convId = participants.join('_');
            if (!conversations.containsKey(convId)) {
              conversations[convId] = msg;
            }
          }

          final conversationMessages = conversations.values.toList();

          return ListView.builder(
            itemCount: conversationMessages.length,
            itemBuilder: (context, index) {
              final msg = conversationMessages[index];
              final otherUserId = msg.participants.firstWhere((id) => id != currentUser.uid);

              return FutureBuilder<UserModel?>(
                future: AuthService().getUserData(otherUserId),
                builder: (context, userSnapshot) {
                  final otherUserName = userSnapshot.hasData 
                      ? (userSnapshot.data!.fullName) 
                      : 'Loading...';

                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.person, color: Color(0xFF1E88E5)),
                    ),
                    title: Text(
                      otherUserName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      msg.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTimestamp(msg.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            otherUserId: otherUserId,
                            otherUserName: otherUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          const Text('No messages yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    if (now.day == date.day && now.month == date.month && now.year == date.year) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}/${date.day}/${date.year}';
  }
}
