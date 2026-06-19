import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_model.dart';

class ApartmentModel {
  final String id;
  final String landlordId;
  final String landlordName;
  final String title;
  final String description;
  final double price;
  final String propertyType;
  final int bedrooms;
  final int bathrooms;
  final double floorArea;
  final List<String> amenities;
  final List<String> imageUrls;
  final String status; // 'Available', 'Reserved', 'Rented'
  final DateTime createdAt;
  
  // Location details
  final LocationModel location;
  
  // Additional Features
  final bool isFurnished;
  final bool hasParking;
  final bool isPetFriendly;
  final String contactNumber;

  ApartmentModel({
    required this.id,
    required this.landlordId,
    required this.landlordName,
    required this.title,
    required this.description,
    required this.price,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.floorArea,
    required this.amenities,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
    required this.location,
    this.isFurnished = false,
    this.hasParking = false,
    this.isPetFriendly = false,
    required this.contactNumber,
  });

  factory ApartmentModel.fromMap(Map<String, dynamic> data, String id) {
    return ApartmentModel(
      id: id,
      landlordId: data['landlordId'] ?? '',
      landlordName: data['landlordName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      propertyType: data['propertyType'] ?? 'Apartment',
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      floorArea: (data['floorArea'] ?? 0).toDouble(),
      amenities: List<String>.from(data['amenities'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: data['status'] ?? 'Available',
      createdAt: (data['createdAt'] is Timestamp) 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      location: LocationModel.fromMap(data['location'] ?? {}),
      isFurnished: data['isFurnished'] ?? false,
      hasParking: data['hasParking'] ?? false,
      isPetFriendly: data['isPetFriendly'] ?? false,
      contactNumber: data['contactNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'landlordId': landlordId,
      'landlordName': landlordName,
      'title': title,
      'description': description,
      'price': price,
      'propertyType': propertyType,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'floorArea': floorArea,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'status': status,
      'createdAt': createdAt,
      'location': location.toMap(),
      'isFurnished': isFurnished,
      'hasParking': hasParking,
      'isPetFriendly': isPetFriendly,
      'contactNumber': contactNumber,
    };
  }
}
