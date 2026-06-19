import 'package:cloud_firestore/cloud_firestore.dart';

class ViewingRequestModel {
  final String id;
  final String apartmentId;
  final String propertyTitle;
  final String tenantId;
  final String tenantName;
  final String landlordId;
  final DateTime preferredDate;
  final String preferredTimeSlot;
  final String message;
  final String status; // 'Pending', 'Accepted', 'Declined', 'Completed', 'Cancelled'
  final DateTime createdAt;

  ViewingRequestModel({
    required this.id,
    required this.apartmentId,
    required this.propertyTitle,
    required this.tenantId,
    required this.tenantName,
    required this.landlordId,
    required this.preferredDate,
    required this.preferredTimeSlot,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory ViewingRequestModel.fromMap(Map<String, dynamic> data, String id) {
    return ViewingRequestModel(
      id: id,
      apartmentId: data['apartmentId'] ?? '',
      propertyTitle: data['propertyTitle'] ?? '',
      tenantId: data['tenantId'] ?? '',
      tenantName: data['tenantName'] ?? '',
      landlordId: data['landlordId'] ?? '',
      preferredDate: (data['preferredDate'] as Timestamp).toDate(),
      preferredTimeSlot: data['preferredTimeSlot'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] is Timestamp) 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apartmentId': apartmentId,
      'propertyTitle': propertyTitle,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'landlordId': landlordId,
      'preferredDate': preferredDate,
      'preferredTimeSlot': preferredTimeSlot,
      'message': message,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
