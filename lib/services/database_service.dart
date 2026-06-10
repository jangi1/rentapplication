import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/apartment_model.dart';
import '../models/inquiry_model.dart';
import '../models/location_model.dart';
import '../models/message_model.dart';

class DatabaseService {
  FirebaseFirestore? _db;
  FirebaseStorage? _storage;

  DatabaseService() {
    try {
      _db = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
    } catch (e) {
      _db = null;
      _storage = null;
    }
  }

  // --- User Profile ---

  Future<void> updateUserLocation(String uid, LocationModel location) async {
    if (_db == null) return;
    await _db!.collection('users').doc(uid).update({
      'location': location.toMap(),
    });
  }

  // --- Apartment CRUD ---

  Future<void> addApartment(ApartmentModel apartment, List<File> images) async {
    if (_db == null || _storage == null) return;

    List<String> imageUrls = [];
    for (var image in images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage!.ref().child('apartments/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();
      imageUrls.add(url);
    }

    final apartmentData = apartment.toMap();
    apartmentData['imageUrls'] = imageUrls;
    apartmentData['createdAt'] = FieldValue.serverTimestamp();

    await _db!.collection('apartments').add(apartmentData);
  }

  Stream<List<ApartmentModel>> getApartments() {
    if (_db == null) {
      return Stream<List<ApartmentModel>>.value([]);
    }

    return _db!.collection('apartments').orderBy('createdAt', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ApartmentModel.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<ApartmentModel>> getLandlordApartments(String landlordId) {
    if (_db == null) {
      return Stream<List<ApartmentModel>>.value([]);
    }
    return _db!.collection('apartments').where('landlordId', isEqualTo: landlordId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ApartmentModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateApartment(String id, Map<String, dynamic> data) async {
    if (_db == null) return;
    await _db!.collection('apartments').doc(id).update(data);
  }

  Future<void> deleteApartment(String id) async {
    if (_db == null) return;
    await _db!.collection('apartments').doc(id).delete();
  }

  // --- Inquiries ---

  Future<void> sendInquiry(InquiryModel inquiry) async {
    if (_db == null) return;
    await _db!.collection('inquiries').add(inquiry.toMap());
  }

  Stream<List<InquiryModel>> getLandlordInquiries(String landlordId) {
    if (_db == null) return Stream<List<InquiryModel>>.value([]);
    return _db!.collection('inquiries').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InquiryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // --- Messaging ---

  Future<void> sendMessage(MessageModel message) async {
    if (_db == null) return;
    await _db!.collection('messages').add(message.toMap());
  }

  Stream<List<MessageModel>> getMessages(String currentUserId, String otherUserId) {
    if (_db == null) return Stream.value([]);
    
    // Sort IDs to ensure consistent conversation participant matching
    List<String> participants = [currentUserId, otherUserId];
    participants.sort();

    return _db!
        .collection('messages')
        .where('participants', isEqualTo: participants)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<MessageModel>> getAllUserMessages(String userId) {
    if (_db == null) return Stream<List<MessageModel>>.value([]);
    return _db!
        .collection('messages')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList());
  }

  // --- Favorites ---

  Future<void> toggleFavorite(String tenantId, String apartmentId) async {
    if (_db == null) return;
    var favDoc = await _db!.collection('favorites')
        .where('tenantId', isEqualTo: tenantId)
        .where('apartmentId', isEqualTo: apartmentId)
        .get();

    if (favDoc.docs.isEmpty) {
      await _db!.collection('favorites').add({
        'tenantId': tenantId,
        'apartmentId': apartmentId,
      });
    } else {
      await _db!.collection('favorites').doc(favDoc.docs.first.id).delete();
    }
  }

  Stream<List<String>> getFavoriteApartmentIds(String tenantId) {
    if (_db == null) return Stream<List<String>>.value([]);
    return _db!.collection('favorites').where('tenantId', isEqualTo: tenantId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()['apartmentId'] as String).toList());
  }
}
