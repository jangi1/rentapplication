import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userModel;
  bool _isInitialized = false;
  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _authSubscription;
  String? _lastUid;

  UserProvider() {
    _authSubscription = _authService.user.listen(_onAuthChanged);
  }

  UserModel? get user => _userModel;
  bool get isInitialized => _isInitialized;

  Future<void> _onAuthChanged(User? firebaseUser) async {
    final String? newUid = firebaseUser?.uid;

    // 1. If no user is logged in, immediately mark as initialized and stop loading.
    if (newUid == null) {
      _userModel = null;
      _lastUid = null;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    // 2. If the user is the same as before and we're already initialized, do nothing.
    if (newUid == _lastUid && _isInitialized && _userModel != null) {
      return;
    }

    _lastUid = newUid;

    // 3. Eagerly try to get user data. 
    // We only set _isInitialized to false if we don't have a model yet to prevent UI flickering.
    if (_userModel == null) {
      _isInitialized = false;
      notifyListeners();
    }

    try {
      UserModel? fetchedUser = await _authService.getUserData(newUid);
      
      // 4. Handle slow Firestore writes for brand new registrations.
      if (fetchedUser == null) {
        // Wait briefly and try one more time.
        await Future.delayed(const Duration(milliseconds: 800));
        fetchedUser = await _authService.getUserData(newUid);
      }
      
      if (_lastUid == newUid) {
        _userModel = fetchedUser;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    } finally {
      if (_lastUid == newUid) {
        _isInitialized = true;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
