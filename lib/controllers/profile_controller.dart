import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../services/translation_service.dart';

class ProfileController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ProfileData? _profileData;
  bool _isLoading = false;
  bool _isDisposed = false;

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  ProfileData? get profileData => _profileData;
  bool get isLoading => _isLoading;

  ProfileController() {
    _listenToProfile();
  }

  void loadInitialData() {
    _listenToProfile();
  }

  void _listenToProfile() async {
    _isLoading = true;
    _safeNotifyListeners();

    // 1. Try loading from local cache instantly
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_profile_data');
      if (cachedStr != null) {
        final decoded = jsonDecode(cachedStr);
        _profileData = ProfileData.fromJson(decoded);
        _isLoading = false; // Turn off loading immediately!
        _safeNotifyListeners();
      }
    } catch (_) {}

    // 2. Fetch fresh data silently in background
    _firestore.collection('profile').doc('aboutPage').snapshots().listen((doc) async {
      if (doc.exists && doc.data() != null) {
        _profileData = ProfileData.fromMap(doc.data()!);
        
        // Save back to cache
        try {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('cached_profile_data', jsonEncode(_profileData!.toJson()));
        } catch (_) {}
      } else {
        _profileData = ProfileData();
      }
      _isLoading = false;
      _safeNotifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _safeNotifyListeners();
    });
  }

  /// Save the full ProfileData object (all sections) to Firestore.
  Future<void> saveProfileData(ProfileData data) async {
    try {
      data.lastUpdated = DateTime.now();
      await _firestore.collection('profile').doc('aboutPage').set(data.toMap());
    } catch (_) {
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

  Future<void> translateAll() async {
    if (_profileData == null) return;
    _isLoading = true;
    _safeNotifyListeners();
    try {
      final p = _profileData!;
      final futures = <Future<void>>[];

      if (p.socialInitiativeTitle.isNotEmpty) futures.add(TranslationService.translateToAll(p.socialInitiativeTitle).then((res) { p.socialInitiativeTitleHi = res['hi']!; p.socialInitiativeTitleGu = res['gu']!; }));
      if (p.socialVision.isNotEmpty) futures.add(TranslationService.translateToAll(p.socialVision).then((res) { p.socialVisionHi = res['hi']!; p.socialVisionGu = res['gu']!; }));
      if (p.socialMission.isNotEmpty) futures.add(TranslationService.translateToAll(p.socialMission).then((res) { p.socialMissionHi = res['hi']!; p.socialMissionGu = res['gu']!; }));
      if (p.socialObjective.isNotEmpty) futures.add(TranslationService.translateToAll(p.socialObjective).then((res) { p.socialObjectiveHi = res['hi']!; p.socialObjectiveGu = res['gu']!; }));
      if (p.philosophyOfLife.isNotEmpty) futures.add(TranslationService.translateToAll(p.philosophyOfLife).then((res) { p.philosophyOfLifeHi = res['hi']!; p.philosophyOfLifeGu = res['gu']!; }));
      if (p.signatureIdentityTitle.isNotEmpty) futures.add(TranslationService.translateToAll(p.signatureIdentityTitle).then((res) { p.signatureIdentityTitleHi = res['hi']!; p.signatureIdentityTitleGu = res['gu']!; }));
      if (p.signatureIdentitySubtitle.isNotEmpty) futures.add(TranslationService.translateToAll(p.signatureIdentitySubtitle).then((res) { p.signatureIdentitySubtitleHi = res['hi']!; p.signatureIdentitySubtitleGu = res['gu']!; }));
      
      if (p.contentHTML.isNotEmpty) futures.add(TranslationService.translateToAll(p.contentHTML).then((res) { p.contentHTMLHi = res['hi']!; p.contentHTMLGu = res['gu']!; }));

      if (p.coreCompetencies.isNotEmpty) {
        futures.add(TranslationService.translateBatch(p.coreCompetencies, 'hi').then((res) => p.coreCompetenciesHi = res));
        futures.add(TranslationService.translateBatch(p.coreCompetencies, 'gu').then((res) => p.coreCompetenciesGu = res));
      }
      if (p.professionalHighlights.isNotEmpty) {
        futures.add(TranslationService.translateBatch(p.professionalHighlights, 'hi').then((res) => p.professionalHighlightsHi = res));
        futures.add(TranslationService.translateBatch(p.professionalHighlights, 'gu').then((res) => p.professionalHighlightsGu = res));
      }
      if (p.personalAttributes.isNotEmpty) {
        futures.add(TranslationService.translateBatch(p.personalAttributes, 'hi').then((res) => p.personalAttributesHi = res));
        futures.add(TranslationService.translateBatch(p.personalAttributes, 'gu').then((res) => p.personalAttributesGu = res));
      }

      await Future.wait(futures);
      await saveProfileData(p);
    } catch (_) {}
    _isLoading = false;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
