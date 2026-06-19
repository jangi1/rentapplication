import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userModel;
  User? _firebaseUser;
  bool _isInitialized = false;
  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;
  String? _lastUid;

  UserProvider() {
    _authSubscription = _authService.user.listen(_onAuthChanged, onError: (e) {
      debugPrint("Auth Stream Error: $e");
      _isInitialized = true;
      notifyListeners();
    });
  }

  UserModel? get user => _userModel;
  User? get firebaseUser => _firebaseUser;
  bool get isInitialized => _isInitialized;
  bool get isLoadingProfile => _firebaseUser != null && _userModel == null && !_isInitialized;

  Future<void> _onAuthChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    final String? newUid = firebaseUser?.uid;

    if (newUid == null) {
      _userDocSubscription?.cancel();
      _userModel = null;
      _lastUid = null;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    if (newUid == _lastUid && _userModel != null) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    _lastUid = newUid;
    _userModel = null;
    _isInitialized = false; 
    notifyListeners();
    
    _userDocSubscription?.cancel();
    _userDocSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(newUid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
        NotificationService().updateToken(newUid);
        _isInitialized = true;
      } else {
        _userModel = null;
        _isInitialized = true; // Still initialized, but no profile
        debugPrint("UserProvider: Firestore document does not exist for $newUid");
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error listening to user profile: $e");
      _isInitialized = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
