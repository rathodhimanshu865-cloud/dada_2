import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/homepage_model.dart';
import '../models/contact_model.dart';
import '../utils/app_logger.dart';

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
  KathaAboutPageData deviKathaPage = KathaAboutPageData(heroBadge: 'ABOUT DEVI KATHA &', heroTitle: 'PU. JIGNESH DADA (RADHE RADHE)');
  KathaAboutPageData shivKathaPage = KathaAboutPageData(heroBadge: 'ABOUT SHIV KATHA &', heroTitle: 'PU. JIGNESH DADA (RADHE RADHE)');
  AboutDadaPageData aboutDadaPage = AboutDadaPageData();
  HomepageData homepageData = HomepageData();

  List<KathaRecord> allKathas = [];
  KathaListPageData kathaListPageData = KathaListPageData();
  ContactPageData contactPageData = ContactPageData();
  VideoGalleryPageData videoGalleryData = VideoGalleryPageData();
  PhotoGalleryPageData photoGalleryData = PhotoGalleryPageData();
  
  List<ContactInquiry> inquiries = [];

  bool isLoading = false;
  bool isUploading = false;

  List<Map<String, dynamic>> realTimePhotos = [];
  StreamSubscription<QuerySnapshot>? _photosSubscription;

  HomePageController() {
    loadData();
    _initPhotosStream();
  }

  void _initPhotosStream() {
    _photosSubscription?.cancel();
    _photosSubscription = _firestore
        .collection('photos')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      realTimePhotos = snapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    }, onError: (err) {
      AppLogger.error("Photos stream error", err);
    });
  }

  @override
  void dispose() {
    _photosSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('cms').doc('homepage').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['websiteSettings'] != null) websiteSettings = WebsiteSettings.fromMap(data['websiteSettings']);
        if (data['heroSection'] != null) heroSection = HeroSection.fromMap(data['heroSection']);
        if (data['upcomingKathas'] != null) {
          upcomingKathas = (data['upcomingKathas'] as List).map((e) => UpcomingKatha.fromMap(e)).toList();
        }
        if (data['aboutSection'] != null) aboutSection = AboutSection.fromMap(data['aboutSection']);
        if (data['dailySuvichar'] != null) dailySuvichar = DailySuvichar.fromMap(data['dailySuvichar']);
        if (data['videos'] != null) {
          videos = (data['videos'] as List).map((e) => VideoItem.fromMap(e)).toList();
        }
        if (data['ramKatha'] != null) ramKatha = RamKathaSection.fromMap(data['ramKatha']);
        if (data['stotraSection'] != null) stotraSection = StotraSection.fromMap(data['stotraSection']);
        if (data['footer'] != null) footer = FooterData.fromMap(data['footer']);
        if (data['bhagvatKathaPage'] != null) bhagvatKathaPage = KathaAboutPageData.fromMap(data['bhagvatKathaPage']);
        if (data['deviKathaPage'] != null) deviKathaPage = KathaAboutPageData.fromMap(data['deviKathaPage']);
        if (data['shivKathaPage'] != null) shivKathaPage = KathaAboutPageData.fromMap(data['shivKathaPage']);
        if (data['aboutDadaPage'] != null) aboutDadaPage = AboutDadaPageData.fromMap(data['aboutDadaPage']);
        if (data['homepageData'] != null) homepageData = HomepageData.fromMap(data['homepageData']);
        if (data['allKathas'] != null) {
          allKathas = (data['allKathas'] as List).map((e) => KathaRecord.fromMap(e)).toList();
        }
        if (data['kathaListPageData'] != null) kathaListPageData = KathaListPageData.fromMap(data['kathaListPageData']);
        if (data['contactPageData'] != null) contactPageData = ContactPageData.fromMap(data['contactPageData']);
        if (data['videoGalleryData'] != null) videoGalleryData = VideoGalleryPageData.fromMap(data['videoGalleryData']);
        if (data['photoGalleryData'] != null) photoGalleryData = PhotoGalleryPageData.fromMap(data['photoGalleryData']);
      }
      
      final inqSnap = await _firestore.collection('inquiries').get();
      inquiries = inqSnap.docs.map((doc) => ContactInquiry.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      AppLogger.error("Load error", e);
    }
    isLoading = false;
    notifyListeners();
  }

  // Management functions
  void addHeroSlide() { heroSection.slides.add(HeroSlide()); notifyListeners(); }
  void removeHeroSlide(int i) { heroSection.slides.removeAt(i); notifyListeners(); }
  void addKatha() { upcomingKathas.add(UpcomingKatha()); notifyListeners(); }
  void removeKatha(int i) { upcomingKathas.removeAt(i); notifyListeners(); }
  void addVideo() { videos.add(VideoItem(title: 'New Video', youtubeUrl: '')); notifyListeners(); }
  void removeVideo(int i) { videos.removeAt(i); notifyListeners(); }
  void addTeaching() { homepageData.teachings.add(TeachingCard()); notifyListeners(); }
  void removeTeaching(int i) { homepageData.teachings.removeAt(i); notifyListeners(); }
  void addTestimonial() { homepageData.testimonials.add(Testimonial()); notifyListeners(); }
  void removeTestimonial(int i) { homepageData.testimonials.removeAt(i); notifyListeners(); }
  void addKathaRecord() { allKathas.add(KathaRecord()); notifyListeners(); }
  void removeKathaRecord(int i) { allKathas.removeAt(i); notifyListeners(); }
  void addStotraItem() { stotraSection.items.add(StotraItem()); notifyListeners(); }
  void removeStotraItem(int i) { stotraSection.items.removeAt(i); notifyListeners(); }

  // Additional Photo/Video Gallery methods
  void addPhotoCategory() { photoGalleryData.sections.add(PhotoGallerySection()); notifyListeners(); }
  void removePhotoCategory(int i) { photoGalleryData.sections.removeAt(i); notifyListeners(); }
  
  Future<void> addPhotoToCategoryFromPicker(int sectionIndex) async {
    final url = await uploadPhotoFromFile();
    if (url != null) {
      photoGalleryData.sections[sectionIndex].photoUrls.add(url);
      notifyListeners();
    }
  }

  void addVideoCategory() { videoGalleryData.categories.add(VideoCategory()); notifyListeners(); }
  void removeVideoCategory(int i) { videoGalleryData.categories.removeAt(i); notifyListeners(); }
  void addVideoToCategory(int catIndex) { videoGalleryData.categories[catIndex].videos.add(VideoGalleryEntry()); notifyListeners(); }
  void removeVideoFromCategory(int catIndex, int vidIndex) { videoGalleryData.categories[catIndex].videos.removeAt(vidIndex); notifyListeners(); }

  Future<void> submitInquiry(ContactInquiry inquiry) async {
    try {
      await _firestore.collection('inquiries').add(inquiry.toMap());
      await loadData();
    } catch (e) {
      AppLogger.error("Submit error", e);
    }
  }

  Future<String?> uploadPhotoFromFile() async {
    try {
      isUploading = true;
      notifyListeners();
      final PlatformFile? result = await FilePicker.pickFile(
        type: FileType.image,
      );

      if (result != null) {
        final Uint8List fileBytes = await result.readAsBytes();
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.name}';
        
        final Reference ref = _storage.ref().child('cms_uploads').child(fileName);
        final UploadTask uploadTask = ref.putData(fileBytes);
        final TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      AppLogger.error("Upload error", e);
    } finally {
      isUploading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> publish() async {
    try {
      final data = {
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
        'aboutDadaPage': aboutDadaPage.toMap(),
        'homepageData': homepageData.toMap(),
        'allKathas': allKathas.map((e) => e.toMap()).toList(),
        'kathaListPageData': kathaListPageData.toMap(),
        'contactPageData': contactPageData.toMap(),
        'videoGalleryData': videoGalleryData.toMap(),
        'photoGalleryData': photoGalleryData.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('cms').doc('homepage').set(data, SetOptions(merge: true));
    } catch (e) {
      AppLogger.error("Save error", e);
    }
  }

  Future<void> translateAndPublish() async {
    isLoading = true;
    notifyListeners();
    try {
      // Logic for mass translation would go here
      await publish();
    } catch (e) {
      AppLogger.error("Translation error", e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
