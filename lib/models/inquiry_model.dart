import 'package:cloud_firestore/cloud_firestore.dart';

class InquiryModel {
  final String id;
  final String apartmentId;
  final String propertyTitle;
  final String tenantId;
  final String tenantName;
  final String landlordId;
  final String landlordName;
  final String message;
  final DateTime inquiryDate;
  final String status; // 'Pending', 'Accepted', 'Declined'

  InquiryModel({
    required this.id,
    required this.apartmentId,
    required this.propertyTitle,
    required this.tenantId,
    required this.tenantName,
    required this.landlordId,
    required this.landlordName,
    required this.message,
    required this.inquiryDate,
    required this.status,
  });

  factory InquiryModel.fromMap(Map<String, dynamic> data, String id) {
    return InquiryModel(
      id: id,
      apartmentId: data['apartmentId'] ?? '',
      propertyTitle: data['propertyTitle'] ?? '',
      tenantId: data['tenantId'] ?? '',
      tenantName: data['tenantName'] ?? '',
      landlordId: data['landlordId'] ?? '',
      landlordName: data['landlordName'] ?? '',
      message: data['message'] ?? '',
      inquiryDate: data['inquiryDate'] != null 
          ? (data['inquiryDate'] as Timestamp).toDate() 
          : DateTime.now(),
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apartmentId': apartmentId,
      'propertyTitle': propertyTitle,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'landlordId': landlordId,
      'landlordName': landlordName,
      'message': message,
      'inquiryDate': inquiryDate,
      'status': status,
    };
  }
}
