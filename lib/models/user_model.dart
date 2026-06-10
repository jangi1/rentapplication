import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_model.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role; // 'Landlord' or 'Tenant'
  final String contactNumber;
  final DateTime createdAt;
  final LocationModel? location;
  final bool isVerified;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.contactNumber,
    required this.createdAt,
    this.location,
    this.isVerified = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Tenant',
      contactNumber: data['contactNumber'] ?? '',
      createdAt: (data['createdAt'] is Timestamp) 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      location: data['location'] != null ? LocationModel.fromMap(data['location']) : null,
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'contactNumber': contactNumber,
      'createdAt': createdAt,
      'location': location?.toMap(),
      'isVerified': isVerified,
    };
  }
}
