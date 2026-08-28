import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:io';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  User? _user;
  UserModel? _userModel;
  String? _role;
  bool _showLoginPortal = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get role => _role;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _role?.toLowerCase() == 'admin';
  bool get showLoginPortal => _showLoginPortal;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void toggleLoginPortal(bool show) {
    if (_showLoginPortal == show) return;
    _showLoginPortal = show;
    notifyListeners();
  }

  AuthController() {
    _auth.authStateChanges().listen((User? user) async {
      debugPrint("Auth State Change: User ${user?.email}");
      _user = user;
      if (user != null) {
        await _fetchUserRole(user.uid);
      } else {
        _role = null;
        _userModel = null;
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
        _role = _userModel?.role;
        debugPrint("User Role Fetched: $_role");
      } else {
        debugPrint("No user document found in Firestore for UID: $uid");
        _role = null;
        _userModel = null;
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _fetchUserRole(_user!.uid);
    } catch (e) {
      debugPrint("Error updating profile: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final ref = _storage.ref().child('profile_images').child('${_user!.uid}.jpg');
      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(_user!.uid).update({
        'profileImage': imageUrl,
      });
      await _fetchUserRole(_user!.uid);
    } catch (e) {
      debugPrint("Error updating profile image: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String newPassword) async {
    if (_user == null) return;
    try {
      await _user!.updatePassword(newPassword);
    } catch (e) {
      debugPrint("Error changing password: $e");
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          name: fullName,
          phone: phone,
          profileImage: '',
          role: 'user',
          createdAt: DateTime.now(),
          isActive: true,
        );

        await _firestore.collection('users').doc(credential.user!.uid).set(userModel.toMap());
        _userModel = userModel;
      }
    } catch (e) {
      debugPrint("Signup error: $e");
      _errorMessage = "Registration failed. Please check your details.";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _fetchUserRole(credential.user!.uid);
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        }).catchError((e) {
          debugPrint("Error updating lastLogin: $e");
        });
      }
    } catch (e) {
      debugPrint("Login error: $e");
      _errorMessage = "Login failed. Invalid email or password.";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_profile_data');
    _userModel = null;
    _role = null;
    notifyListeners();
  }
}
