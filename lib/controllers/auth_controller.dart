import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';
import '../firebase_options.dart';
import 'dart:io';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseAuth _adminAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  User? _user;
  UserModel? _userModel;
  String? _role;

  User? _adminUser;
  String? _adminRole;

  bool _showLoginPortal = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isDisposed = false;
  String? _errorMessage;

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get role => _role;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _role?.toLowerCase() == 'admin';

  User? get adminUser => _adminUser;
  bool get isAdminAuthenticated => _adminUser != null && _adminRole?.toLowerCase() == 'admin';

  bool get showLoginPortal => _showLoginPortal;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  void toggleLoginPortal(bool show) {
    if (_showLoginPortal == show) return;
    _showLoginPortal = show;
    _safeNotifyListeners();
  }

  AuthController() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserRole(user.uid);
      } else {
        _role = null;
        _userModel = null;
      }
      _isInitialized = true;
      _safeNotifyListeners();
    });

    // Admin listener will be initialized on demand during login
  }

  Future<String?> _getRoleOnly(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
        _role = _userModel?.role;
      } else {
        _role = null;
        _userModel = null;
      }
    } catch (e) {
      AppLogger.error("Error fetching user role", e);
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
    _safeNotifyListeners();

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
      AppLogger.error("Error updating profile", e);
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    if (_user == null) return;
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final ref = _storage.ref().child('profile_images').child('${_user!.uid}.jpg');
      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(_user!.uid).update({
        'profileImage': imageUrl,
      });
      await _fetchUserRole(_user!.uid);
    } catch (e) {
      AppLogger.error("Error updating profile image", e);
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> changePassword(String newPassword) async {
    if (_user == null) return;
    try {
      await _user!.updatePassword(newPassword);
    } catch (e) {
      AppLogger.error("Error changing password", e);
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
    _safeNotifyListeners();

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
      AppLogger.error("Signup error", e);
      _errorMessage = "Registration failed. Please check your details.";
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _fetchUserRole(credential.user!.uid);
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      AppLogger.error("Login error", e);
      _errorMessage = "Login failed. Invalid email or password.";
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> adminLogin(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      // Lazy Initialize Secondary Firebase App for Admin Session
      try {
        FirebaseAuth.instanceFor(app: Firebase.app('AdminApp'));
      } catch (e) {
        await Firebase.initializeApp(
          name: 'AdminApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      final adminAuth = FirebaseAuth.instanceFor(app: Firebase.app('AdminApp'));
      final credential = await adminAuth.signInWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null) {
        final role = await _getRoleOnly(credential.user!.uid);
        if (role?.toLowerCase() != 'admin') {
          await adminAuth.signOut();
          _errorMessage = "Access Denied: You do not have administrator privileges.";
          throw Exception(_errorMessage);
        }
        _adminUser = credential.user;
        _adminRole = role;
      }
    } catch (e) {
      AppLogger.error("Admin Login error", e);
      _errorMessage ??= "Login failed. Invalid email or password.";
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_profile_data');
    _userModel = null;
    _role = null;
    _safeNotifyListeners();
  }

  Future<void> adminLogout() async {
    await _adminAuth.signOut();
    _adminUser = null;
    _adminRole = null;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}