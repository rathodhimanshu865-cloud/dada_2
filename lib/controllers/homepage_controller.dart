import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path_helper;
import '../models/homepage_model.dart';

class HomePageController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  WebsiteSettings websiteSettings = WebsiteSettings();
  HeroSection heroSection = HeroSection();
  List<UpcomingKatha> upcomingKathas = [];
  AboutSection aboutSection = AboutSection();
  DailySuvichar dailySuvichar = DailySuvichar();
  List<VideoItem> videos = [];
  RamKathaSection ramKatha = RamKathaSection();
  StotraSection stotraSection = StotraSection();
  FooterData footer = FooterData();
  AboutKathaPageData aboutKathaPage = AboutKathaPageData();
  List<KathaRecord> allKathas = [];
  KathaListPageData kathaListPageData = KathaListPageData();
  VideoGalleryPageData videoGalleryData = VideoGalleryPageData();
  PhotoGalleryPageData photoGalleryData = PhotoGalleryPageData();

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
        while (heroSection.bannerUrls.length < 8) {
          heroSection.bannerUrls.add('');
        }
        upcomingKathas = (data['upcomingKathas'] as List? ?? []).map((e) => UpcomingKatha.fromMap(e)).toList();
        aboutSection = AboutSection.fromMap(data['aboutSection'] ?? {});
        dailySuvichar = DailySuvichar.fromMap(data['dailySuvichar'] ?? {});
        videos = (data['videos'] as List? ?? []).map((e) => VideoItem.fromMap(e)).toList();
        ramKatha = RamKathaSection.fromMap(data['ramKatha'] ?? {});
        stotraSection = StotraSection.fromMap(data['stotraSection'] ?? {});
        footer = FooterData.fromMap(data['footer'] ?? {});
        aboutKathaPage = AboutKathaPageData.fromMap(data['aboutKathaPage'] ?? {});
        allKathas = (data['allKathas'] as List? ?? []).map((e) => KathaRecord.fromMap(e)).toList();
        kathaListPageData = KathaListPageData.fromMap(data['kathaListPageData'] ?? {});
        videoGalleryData = VideoGalleryPageData.fromMap(data['videoGalleryData'] ?? {});
        photoGalleryData = PhotoGalleryPageData.fromMap(data['photoGalleryData'] ?? {});
      }
    } catch (e) {
      debugPrint("Load error: $e");
    }
    // Ensure default sections if empty
    if (photoGalleryData.sections.isEmpty) {
      photoGalleryData.sections = [
        PhotoGallerySection(heading: 'Bapu & Ram Katha'),
        PhotoGallerySection(heading: 'Temples in Taljagrda'),
      ];
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
  void addStotraItem() { stotraSection.items.add(StotraItem()); notifyListeners(); }
  void removeStotraItem(int i) { stotraSection.items.removeAt(i); notifyListeners(); }

  void addVideoCategory() { videoGalleryData.categories.add(VideoCategory()); notifyListeners(); }
  void removeVideoCategory(int i) { videoGalleryData.categories.removeAt(i); notifyListeners(); }
  void addVideoToCategory(int catIdx) { videoGalleryData.categories[catIdx].videos.add(VideoGalleryEntry()); notifyListeners(); }
  void removeVideoFromCategory(int catIdx, int vidIdx) { videoGalleryData.categories[catIdx].videos.removeAt(vidIdx); notifyListeners(); }

  void addPhotoCategory() {
    photoGalleryData.sections.add(PhotoGallerySection(heading: 'New Heading'));
    notifyListeners();
  }

  void removePhotoCategory(int i) {
    if (i >= 0 && i < photoGalleryData.sections.length) {
      photoGalleryData.sections.removeAt(i);
      notifyListeners();
    }
  }

  void removePhotoFromCategory(int catIdx, int photoIdx) {
    if (catIdx >= 0 && catIdx < photoGalleryData.sections.length) {
      photoGalleryData.sections[catIdx].photoUrls.removeAt(photoIdx);
      notifyListeners();
    }
  }

  void addPhotoUrlToSection(int sectionIndex) {
    if (sectionIndex >= 0 && sectionIndex < photoGalleryData.sections.length) {
      photoGalleryData.sections[sectionIndex].photoUrls.add('');
      notifyListeners();
    }
  }

  Future<String?> uploadPhotoFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
      if (result == null || result.files.isEmpty) return null;
      
      final fileName = result.files.single.name;
      final uploadName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final reference = _storage.ref('photo_gallery/$uploadName');
      
      UploadTask task;
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes == null) return null;
        task = reference.putData(bytes);
      } else {
        final filePath = result.files.single.path;
        if (filePath == null) return null;
        final file = File(filePath);
        task = reference.putFile(file);
      }

      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  Future<void> addPhotoToCategoryFromPicker(int catIdx) async {
    isLoading = true;
    notifyListeners();
    final url = await uploadPhotoFromFile();
    if (url != null && catIdx >= 0 && catIdx < photoGalleryData.sections.length) {
      photoGalleryData.sections[catIdx].photoUrls.add(url);
    }
    isLoading = false;
    notifyListeners();
  }

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
        'stotraSection': stotraSection.toMap(),
        'footer': footer.toMap(),
        'aboutKathaPage': aboutKathaPage.toMap(),
        'allKathas': allKathas.map((e) => e.toMap()).toList(),
        'kathaListPageData': kathaListPageData.toMap(),
        'videoGalleryData': videoGalleryData.toMap(),
        'photoGalleryData': photoGalleryData.toMap(),
      });
      await loadData();
    } catch (e) {
      debugPrint("Save error: $e");
    }
    isLoading = false;
    notifyListeners();
  }
}
