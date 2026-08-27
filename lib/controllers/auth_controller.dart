import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _role;
  bool _showLoginPortal = false;

  User? get user => _user;
  String? get role => _role;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _role?.toLowerCase() == 'admin';
  bool get showLoginPortal => _showLoginPortal;

  void toggleLoginPortal(bool show) {
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
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _role = doc.data()?['role'];
        debugPrint("User Role Fetched: $_role");
      } else {
        debugPrint("No user document found in Firestore for UID: $uid");
        _role = null;
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': fullName, // Changed from fullName to name as per instructions
        'phone': phone,
        'profileImage': '', // Added field
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true, // Added field
      });
    }
  }

  Future<void> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (credential.user != null) {
      await _fetchUserRole(credential.user!.uid);
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      }).catchError((e) {
        debugPrint("Error updating lastLogin: $e");
      });
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
