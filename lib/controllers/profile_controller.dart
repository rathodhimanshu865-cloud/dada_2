import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';

class ProfileController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ProfileData? _profileData;
  bool _isLoading = false;

  ProfileData? get profileData => _profileData;
  bool get isLoading => _isLoading;

  ProfileController() {
    _listenToProfile();
  }

  void _listenToProfile() {
    _isLoading = true;
    notifyListeners();

    _firestore.collection('profile').doc('aboutPage').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _profileData = ProfileData.fromMap(doc.data()!);
      } else {
        _profileData = ProfileData();
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error listening to profile: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Save the full ProfileData object (all sections) to Firestore.
  Future<void> saveProfileData(ProfileData data) async {
    try {
      data.lastUpdated = DateTime.now();
      await _firestore.collection('profile').doc('aboutPage').set(data.toMap());
    } catch (e) {
      debugPrint("Error saving profile: $e");
      rethrow;
    }
  }

  /// Legacy helper — saves only the introduction HTML/delta, preserving other fields.
  Future<void> saveProfile(String html, String delta) async {
    final current = _profileData ?? ProfileData();
    current.contentHTML  = html;
    current.contentDelta = delta;
    await saveProfileData(current);
  }
}
