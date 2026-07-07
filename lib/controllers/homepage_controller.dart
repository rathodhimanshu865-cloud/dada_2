import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path_helper;
import '../models/homepage_model.dart';
import '../models/contact_model.dart';

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
  
  KathaAboutPageData bhagvatKathaPage = KathaAboutPageData(heroBadge: 'ABOUT KATHA &', heroTitle: 'PU. JIGNESH DADA (RADHE RADHE)');
  KathaAboutPageData deviKathaPage = KathaAboutPageData(heroBadge: 'DIVINE GRACE', heroTitle: 'SHREEMAD DEVI BHAGVAT');
  KathaAboutPageData shivKathaPage = KathaAboutPageData(heroBadge: 'ETERNAL WISDOM', heroTitle: 'SHREE SHIVMAHAPURAN');

  List<KathaRecord> allKathas = [];
  KathaListPageData kathaListPageData = KathaListPageData();
  ContactPageData contactPageData = ContactPageData();
  VideoGalleryPageData videoGalleryData = VideoGalleryPageData();
  PhotoGalleryPageData photoGalleryData = PhotoGalleryPageData();
  
  List<ContactInquiry> inquiries = [];

  bool isLoading = false;
  bool isUploading = false;

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
        
        bhagvatKathaPage = KathaAboutPageData.fromMap(data['bhagvatKathaPage'] ?? {});
        deviKathaPage = KathaAboutPageData.fromMap(data['deviKathaPage'] ?? {});
        shivKathaPage = KathaAboutPageData.fromMap(data['shivKathaPage'] ?? {});

        allKathas = (data['allKathas'] as List? ?? []).map((e) => KathaRecord.fromMap(e)).toList();
        kathaListPageData = KathaListPageData.fromMap(data['kathaListPageData'] ?? {});
        contactPageData = ContactPageData.fromMap(data['contactPageData'] ?? {});
        videoGalleryData = VideoGalleryPageData.fromMap(data['videoGalleryData'] ?? {});
        photoGalleryData = PhotoGalleryPageData.fromMap(data['photoGalleryData'] ?? {});
      }
      
      final inquirySnapshot = await _firestore.collection('inquiries').orderBy('timestamp', descending: true).get();
      inquiries = inquirySnapshot.docs.map((doc) => ContactInquiry.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      debugPrint("Load error: $e");
    }
    
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

  Future<void> submitInquiry(ContactInquiry inquiry) async {
    try {
      await _firestore.collection('inquiries').add(inquiry.toMap());
      await loadData();
    } catch (e) {
      debugPrint("Submit error: $e");
    }
  }

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
      isUploading = true;
      notifyListeners();
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image, 
        allowMultiple: false,
        withData: kIsWeb,
      );
      
      if (result == null || result.files.isEmpty) {
        isUploading = false;
        notifyListeners();
        return null;
      }
      
      final fileName = result.files.single.name;
      final uploadName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final reference = _storage.ref('uploads/$uploadName');
      
      UploadTask task;
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes == null) throw Exception("Failed to read file bytes");
        task = reference.putData(bytes, SettableMetadata(contentType: 'image/${path_helper.extension(fileName).replaceFirst('.', '')}'));
      } else {
        final filePath = result.files.single.path;
        if (filePath == null) throw Exception("Failed to get file path");
        final file = File(filePath);
        task = reference.putFile(file);
      }

      final snapshot = await task;
      final url = await snapshot.ref.getDownloadURL();
      
      isUploading = false;
      notifyListeners();
      return url;
    } catch (e) {
      isUploading = false;
      notifyListeners();
      debugPrint("Upload error details: $e");
      return null;
    }
  }

  Future<void> addPhotoToCategoryFromPicker(int catIdx) async {
    final url = await uploadPhotoFromFile();
    if (url != null && catIdx >= 0 && catIdx < photoGalleryData.sections.length) {
      photoGalleryData.sections[catIdx].photoUrls.add(url);
      notifyListeners();
    }
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
        'bhagvatKathaPage': bhagvatKathaPage.toMap(),
        'deviKathaPage': deviKathaPage.toMap(),
        'shivKathaPage': shivKathaPage.toMap(),
        'allKathas': allKathas.map((e) => e.toMap()).toList(),
        'kathaListPageData': kathaListPageData.toMap(),
        'contactPageData': contactPageData.toMap(),
        'videoGalleryData': videoGalleryData.toMap(),
        'photoGalleryData': photoGalleryData.sections.isNotEmpty ? photoGalleryData.toMap() : {},
      });
      await loadData();
    } catch (e) {
      debugPrint("Save error: $e");
    }
    isLoading = false;
    notifyListeners();
  }
}
