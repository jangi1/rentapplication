import 'package:cloud_firestore/cloud_firestore.dart';

class InquiryModel {
  final String id;
  final String apartmentId;
  final String tenantId;
  final String message;
  final DateTime inquiryDate;
  final String status; // 'Pending', 'Replied', 'Closed'

  InquiryModel({
    required this.id,
    required this.apartmentId,
    required this.tenantId,
    required this.message,
    required this.inquiryDate,
    required this.status,
  });

  factory InquiryModel.fromMap(Map<String, dynamic> data, String id) {
    return InquiryModel(
      id: id,
      apartmentId: data['apartmentId'] ?? '',
      tenantId: data['tenantId'] ?? '',
      message: data['message'] ?? '',
      inquiryDate: (data['inquiryDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apartmentId': apartmentId,
      'tenantId': tenantId,
      'message': message,
      'inquiryDate': inquiryDate,
      'status': status,
    };
  }
}
