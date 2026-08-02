import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  void _listenToProfile() async {
    _isLoading = true;
    notifyListeners();

    // 1. Try loading from local cache instantly
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_profile_data');
      if (cachedStr != null) {
        final decoded = jsonDecode(cachedStr);
        _profileData = ProfileData.fromJson(decoded);
        _isLoading = false; // Turn off loading immediately!
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading profile from cache: $e");
    }

    // 2. Fetch fresh data silently in background
    _firestore.collection('profile').doc('aboutPage').snapshots().listen((doc) async {
      if (doc.exists && doc.data() != null) {
        _profileData = ProfileData.fromMap(doc.data()!);
        
        // Save back to cache
        try {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('cached_profile_data', jsonEncode(_profileData!.toJson()));
        } catch (e) {
          debugPrint("Error saving profile to cache: $e");
        }
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
