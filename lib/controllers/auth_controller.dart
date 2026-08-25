import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthController() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
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
        'fullName': fullName,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
    }
  }

  Future<void> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      }).catchError((e) {
        // If the document doesn't exist (e.g. for old users), you might want to set it instead of update.
        // But for now, we'll just ignore the error if it fails to update the timestamp.
        debugPrint("Error updating lastLogin: $e");
      });
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
