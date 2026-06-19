import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/apartment_model.dart';
import '../models/inquiry_model.dart';
import '../models/location_model.dart';
import '../models/message_model.dart';
import '../models/viewing_request_model.dart';

class DatabaseService {
  FirebaseFirestore? _db;
  FirebaseStorage? _storage;

  // Local session cache to ensure newly added apartments are visible immediately
  static final List<ApartmentModel> _sessionApartments = [];

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

  Future<void> addApartment(ApartmentModel apartment, List<dynamic> images) async {
    List<String> imageUrls = [];
    
    // Attempt upload if Firebase is available
    if (_db != null && _storage != null) {
      try {
        for (var image in images) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference ref = _storage!.ref().child('apartments/$fileName');
          
          if (image is File) {
            await ref.putFile(image);
          } else {
            // For web or other data types
            await ref.putData(image);
          }
          
          String url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      } catch (e) {
        debugPrint("Image upload failed: $e");
      }
    }

    // Create the final model with uploaded URLs
    final finalApt = ApartmentModel(
      id: apartment.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : apartment.id,
      landlordId: apartment.landlordId,
      landlordName: apartment.landlordName,
      title: apartment.title,
      description: apartment.description,
      price: apartment.price,
      propertyType: apartment.propertyType,
      bedrooms: apartment.bedrooms,
      bathrooms: apartment.bathrooms,
      floorArea: apartment.floorArea,
      amenities: apartment.amenities,
      imageUrls: imageUrls,
      status: apartment.status,
      createdAt: apartment.createdAt,
      location: apartment.location,
      isFurnished: apartment.isFurnished,
      hasParking: apartment.hasParking,
      isPetFriendly: apartment.isPetFriendly,
      contactNumber: apartment.contactNumber,
    );

    // Update session cache immediately for instant UI feedback
    _sessionApartments.insert(0, finalApt);

    // Persist to Firestore if available
    if (_db != null) {
      final apartmentData = finalApt.toMap();
      apartmentData['imageUrls'] = imageUrls;
      apartmentData['createdAt'] = FieldValue.serverTimestamp();
      await _db!.collection('apartments').add(apartmentData);
    }
  }

  Stream<List<ApartmentModel>> getApartments() {
    Stream<List<ApartmentModel>> firestoreStream;
    
    if (_db == null) {
      firestoreStream = Stream.value([]);
    } else {
      firestoreStream = _db!.collection('apartments').orderBy('createdAt', descending: true).snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => ApartmentModel.fromMap(doc.data(), doc.id)).toList());
    }

    return firestoreStream.map((list) {
      // Combine Firestore data with local session data, filtering duplicates
      final merged = [..._sessionApartments];
      for (var apt in list) {
        if (!_sessionApartments.any((s) => s.id == apt.id || (s.title == apt.title && s.landlordId == apt.landlordId))) {
          merged.add(apt);
        }
      }
      return merged;
    });
  }

  Stream<List<ApartmentModel>> getLandlordApartments(String landlordId) {
    if (_db == null) {
      return Stream<List<ApartmentModel>>.value(_sessionApartments.where((a) => a.landlordId == landlordId).toList());
    }
    
    return _db!.collection('apartments')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => ApartmentModel.fromMap(doc.data(), doc.id)).toList();
          final session = _sessionApartments.where((a) => a.landlordId == landlordId).toList();
          
          final merged = [...session];
          for (var apt in list) {
            // Check by ID or title+landlordId to prevent duplicates from session cache
            if (!session.any((s) => s.id == apt.id || (s.title == apt.title && s.landlordId == apt.landlordId))) {
              merged.add(apt);
            }
          }
          return merged;
        });
  }

  Future<void> updateApartment(String id, Map<String, dynamic> data) async {
    // Update session cache if exists
    final index = _sessionApartments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _sessionApartments[index];
      _sessionApartments[index] = ApartmentModel.fromMap({...old.toMap(), ...data}, id);
    }

    if (_db == null) return;
    await _db!.collection('apartments').doc(id).update(data);
  }

  Future<void> deleteApartment(String id) async {
    // Remove from session cache
    _sessionApartments.removeWhere((a) => a.id == id);

    if (_db == null) return;
    await _db!.collection('apartments').doc(id).delete();
  }

  // --- Inquiries ---

  Future<void> sendInquiry(InquiryModel inquiry) async {
    if (_db == null) return;
    await _db!.collection('inquiries').add(inquiry.toMap());
  }

  Stream<List<InquiryModel>> getLandlordInquiries(String landlordId) {
    debugPrint("Fetching inquiries for landlord: $landlordId");
    if (_db == null) return Stream<List<InquiryModel>>.value([]);
    return _db!.collection('inquiries')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => InquiryModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort client-side to avoid mandatory composite index requirement
          list.sort((a, b) => b.inquiryDate.compareTo(a.inquiryDate));
          return list;
        });
  }

  Stream<List<InquiryModel>> getTenantInquiries(String tenantId) {
    if (_db == null) return Stream<List<InquiryModel>>.value([]);
    return _db!.collection('inquiries')
        .where('tenantId', isEqualTo: tenantId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => InquiryModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort client-side to avoid mandatory composite index requirement
          list.sort((a, b) => b.inquiryDate.compareTo(a.inquiryDate));
          return list;
        });
  }

  Future<void> updateInquiryStatus(String id, String status) async {
    if (_db == null) return;
    await _db!.collection('inquiries').doc(id).update({'status': status});
  }

  // --- Messaging ---

  Future<void> sendMessage(MessageModel message) async {
    if (_db == null) return;
    await _db!.collection('messages').add(message.toMap());
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    if (_db == null) return Stream.value([]);
    
    return _db!
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort client-side to avoid mandatory composite index requirement
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  Stream<List<MessageModel>> getAllUserMessages(String userId) {
    debugPrint("Fetching all messages for user: $userId");
    if (_db == null) return Stream<List<MessageModel>>.value([]);
    return _db!
        .collection('messages')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList();
          // Sort client-side to avoid mandatory composite index requirement
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    if (_db == null) return;
    final unreadMessages = await _db!
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({'isRead': true});
    }
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

  // --- Verification ---

  Future<void> submitVerification(String userId, File idImage) async {
    if (_db == null || _storage == null) return;
    
    try {
      String fileName = "id_$userId";
      Reference ref = _storage!.ref().child('verifications/$fileName');
      await ref.putFile(idImage);
      String url = await ref.getDownloadURL();

      await _db!.collection('users').doc(userId).update({
        'idImageUrl': url,
        'verificationStatus': 'Pending', // Statuses: None, Pending, Verified, Rejected
      });
    } catch (e) {
      debugPrint("Verification upload failed: $e");
      rethrow;
    }
  }

  // --- Viewing Requests ---

  Future<void> requestViewing(ViewingRequestModel request) async {
    if (_db == null) return;
    await _db!.collection('viewing_requests').add(request.toMap());
  }

  Stream<List<ViewingRequestModel>> getLandlordViewingRequests(String landlordId) {
    if (_db == null) return Stream.value([]);
    return _db!.collection('viewing_requests')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => ViewingRequestModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> updateViewingStatus(String requestId, String status) async {
    if (_db == null) return;
    await _db!.collection('viewing_requests').doc(requestId).update({'status': status});
  }
}
