import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/apartment_model.dart';
import '../models/inquiry_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- Apartment CRUD ---

  Future<void> addApartment(ApartmentModel apartment, List<File> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('apartments/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();
      imageUrls.add(url);
    }

    await _db.collection('apartments').add({
      'landlordId': apartment.landlordId,
      'title': apartment.title,
      'location': apartment.location,
      'price': apartment.price,
      'description': apartment.description,
      'bedrooms': apartment.bedrooms,
      'bathrooms': apartment.bathrooms,
      'floorArea': apartment.floorArea,
      'propertyType': apartment.propertyType,
      'amenities': apartment.amenities,
      'contactNumber': apartment.contactNumber,
      'imageUrls': imageUrls,
      'status': apartment.status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ApartmentModel>> getApartments() {
    return _db.collection('apartments').orderBy('createdAt', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ApartmentModel.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<ApartmentModel>> getLandlordApartments(String landlordId) {
    return _db.collection('apartments').where('landlordId', isEqualTo: landlordId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ApartmentModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateApartment(String id, Map<String, dynamic> data) async {
    await _db.collection('apartments').doc(id).update(data);
  }

  Future<void> deleteApartment(String id) async {
    await _db.collection('apartments').doc(id).delete();
  }

  // --- Inquiries ---

  Future<void> sendInquiry(InquiryModel inquiry) async {
    await _db.collection('inquiries').add(inquiry.toMap());
  }

  Stream<List<InquiryModel>> getLandlordInquiries(String landlordId) {
    return _db.collection('inquiries').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => InquiryModel.fromMap(doc.data(), doc.id)).toList());
  }

  // --- Favorites ---

  Future<void> toggleFavorite(String tenantId, String apartmentId) async {
    var favDoc = await _db.collection('favorites')
        .where('tenantId', isEqualTo: tenantId)
        .where('apartmentId', isEqualTo: apartmentId)
        .get();

    if (favDoc.docs.isEmpty) {
      await _db.collection('favorites').add({
        'tenantId': tenantId,
        'apartmentId': apartmentId,
      });
    } else {
      await _db.collection('favorites').doc(favDoc.docs.first.id).delete();
    }
  }

  Stream<List<String>> getFavoriteApartmentIds(String tenantId) {
    return _db.collection('favorites').where('tenantId', isEqualTo: tenantId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()['apartmentId'] as String).toList());
  }
}
