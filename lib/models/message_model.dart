import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String senderRole;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? apartmentId;
  final String? landlordId;
  final String? tenantId;
  final List<String> participants;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    required this.participants,
    this.isRead = false,
    this.apartmentId,
    this.landlordId,
    this.tenantId,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderRole: data['senderRole'] ?? 'Tenant',
      text: data['messageText'] ?? data['text'] ?? '',
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
      isRead: data['isRead'] ?? false,
      apartmentId: data['apartmentId'],
      landlordId: data['landlordId'],
      tenantId: data['tenantId'],
      participants: List<String>.from(data['participants'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderRole': senderRole,
      'messageText': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'apartmentId': apartmentId,
      'landlordId': landlordId,
      'tenantId': tenantId,
      'participants': participants,
    };
  }
}
