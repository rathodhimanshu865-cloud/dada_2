import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/homepage_model.dart';

class HomePageController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WebsiteSettings websiteSettings = WebsiteSettings();
  HeroSection heroSection = HeroSection();
  List<UpcomingKatha> upcomingKathas = [];
  AboutSection aboutSection = AboutSection();
  DailySuvichar dailySuvichar = DailySuvichar();
  List<VideoItem> videos = [];
  RamKathaSection ramKatha = RamKathaSection();
  FooterData footer = FooterData();
  AboutKathaPageData aboutKathaPage = AboutKathaPageData();
  List<KathaRecord> allKathas = [];
  KathaListPageData kathaListPageData = KathaListPageData();

  bool isLoading = false;

  HomePageController() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('cms').doc('homepage').get();
      if (doc.exists) {
        final data = doc.data()!;
        websiteSettings = WebsiteSettings.fromMap(data['websiteSettings'] ?? {});
        heroSection = HeroSection.fromMap(data['heroSection'] ?? {});
        // Ensure we always have 8 slots for hero images
        while (heroSection.bannerUrls.length < 8) {
          heroSection.bannerUrls.add('');
        }
        upcomingKathas = (data['upcomingKathas'] as List? ?? []).map((e) => UpcomingKatha.fromMap(e)).toList();
        aboutSection = AboutSection.fromMap(data['aboutSection'] ?? data['aboutDada'] ?? {});
        dailySuvichar = DailySuvichar.fromMap(data['dailySuvichar'] ?? {});
        videos = (data['videos'] as List? ?? []).map((e) => VideoItem.fromMap(e)).toList();
        ramKatha = RamKathaSection.fromMap(data['ramKatha'] ?? {});
        footer = FooterData.fromMap(data['footer'] ?? {});
        aboutKathaPage = AboutKathaPageData.fromMap(data['aboutKathaPage'] ?? {});
        allKathas = (data['allKathas'] as List? ?? []).map((e) => KathaRecord.fromMap(e)).toList();
        kathaListPageData = KathaListPageData.fromMap(data['kathaListPageData'] ?? {});
      }
    } catch (e) {
      debugPrint("Load error: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  void addKatha() { upcomingKathas.add(UpcomingKatha()); notifyListeners(); }
  void removeKatha(int i) { upcomingKathas.removeAt(i); notifyListeners(); }
  void addVideo() { videos.add(VideoItem()); notifyListeners(); }
  void removeVideo(int i) { videos.removeAt(i); notifyListeners(); }

  void addKathaRecord() { allKathas.add(KathaRecord()); notifyListeners(); }
  void removeKathaRecord(int i) { allKathas.removeAt(i); notifyListeners(); }

  Future<void> publish() async {
    isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('cms').doc('homepage').set({
        'websiteSettings': websiteSettings.toMap(),
        'heroSection': heroSection.toMap(),
        'upcomingKathas': upcomingKathas.map((e) => e.toMap()).toList(),
        'aboutSection': aboutSection.toMap(),
        'dailySuvichar': dailySuvichar.toMap(),
        'videos': videos.map((e) => e.toMap()).toList(),
        'ramKatha': ramKatha.toMap(),
        'footer': footer.toMap(),
        'aboutKathaPage': aboutKathaPage.toMap(),
        'allKathas': allKathas.map((e) => e.toMap()).toList(),
        'kathaListPageData': kathaListPageData.toMap(),
      });
    } catch (e) {
      debugPrint("Save error: $e");
    }
    isLoading = false;
    notifyListeners();
  }
}
