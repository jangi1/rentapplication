import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userModel;
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
    
    // Safety timeout for web and emulator to ensure splash screen doesn't hang
    // indefinitely if auth state takes too long to respond.
    Future.delayed(const Duration(seconds: 10), () {
      if (!_isInitialized) {
        debugPrint("UserProvider: Initialization timeout reached. Forcing initialization.");
        _isInitialized = true;
        notifyListeners();
      }
    });
  }

  UserModel? get user => _userModel;
  bool get isInitialized => _isInitialized;

  Future<void> _onAuthChanged(User? firebaseUser) async {
    final String? newUid = firebaseUser?.uid;

    if (newUid == null) {
      _userDocSubscription?.cancel();
      _userModel = null;
      _lastUid = null;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    if (newUid == _lastUid) return;

    _lastUid = newUid;
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
      } else {
        _userModel = null;
      }
      _isInitialized = true;
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
