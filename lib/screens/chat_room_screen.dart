import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String apartmentId;
  final String landlordId;
  final String tenantId;

  const ChatRoomScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.apartmentId,
    required this.landlordId,
    required this.tenantId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  late final String _conversationId;

  @override
  void initState() {
    super.initState();
    _conversationId = "${widget.apartmentId}_${widget.tenantId}_${widget.landlordId}";
  }

  void _sendMessage() async {
    final messageContent = _messageController.text.trim();
    if (messageContent.isEmpty) return;

    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) return;

    final List<String> participants = [currentUser.uid, widget.otherUserId];
    participants.sort();

    final message = MessageModel(
      id: '',
      conversationId: _conversationId,
      senderId: currentUser.uid,
      receiverId: widget.otherUserId,
      senderRole: currentUser.role,
      text: messageContent,
      timestamp: DateTime.now(),
      participants: participants,
      apartmentId: widget.apartmentId,
      landlordId: widget.landlordId,
      tenantId: widget.tenantId,
    );

    await _db.sendMessage(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Online', style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _db.getMessages(_conversationId),
              builder: (context, snapshot) {
                if (snapshot.hasData && currentUser != null) {
                  _db.markMessagesAsRead(_conversationId, currentUser.uid);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.uid;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 15),
          Text('Send a message to ${widget.otherUserName}', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1E88E5) : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
