import 'package:cloud_firestore/cloud_firestore.dart';

class ApartmentModel {
  final String id;
  final String landlordId;
  final String title;
  final String location;
  final double price;
  final String description;
  final int bedrooms;
  final int bathrooms;
  final double floorArea;
  final String propertyType;
  final List<String> amenities;
  final String contactNumber;
  final List<String> imageUrls;
  final String status; // 'Available', 'Reserved', 'Rented'
  final DateTime createdAt;

  ApartmentModel({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.location,
    required this.price,
    required this.description,
    required this.bedrooms,
    required this.bathrooms,
    required this.floorArea,
    required this.propertyType,
    required this.amenities,
    required this.contactNumber,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
  });

  factory ApartmentModel.fromMap(Map<String, dynamic> data, String id) {
    return ApartmentModel(
      id: id,
      landlordId: data['landlordId'] ?? '',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      floorArea: (data['floorArea'] ?? 0).toDouble(),
      propertyType: data['propertyType'] ?? 'Apartment',
      amenities: List<String>.from(data['amenities'] ?? []),
      contactNumber: data['contactNumber'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: data['status'] ?? 'Available',
      createdAt: (data['createdAt'] is Timestamp) 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'landlordId': landlordId,
      'title': title,
      'location': location,
      'price': price,
      'description': description,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'floorArea': floorArea,
      'propertyType': propertyType,
      'amenities': amenities,
      'contactNumber': contactNumber,
      'imageUrls': imageUrls,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
