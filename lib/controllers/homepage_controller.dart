import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path_helper;
import '../models/homepage_model.dart';
import '../models/contact_model.dart';
import '../services/translation_service.dart';

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
  
  AboutDadaPageData aboutDadaPage = AboutDadaPageData();
  HomepageData homepageData = HomepageData();

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
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          websiteSettings = WebsiteSettings.fromMap(data['websiteSettings'] ?? {});
          heroSection = HeroSection.fromMap(data['heroSection'] ?? {});
          
          upcomingKathas = (data['upcomingKathas'] as List? ?? []).map((e) => UpcomingKatha.fromMap(e)).toList();
          aboutSection = AboutSection.fromMap(data['aboutSection'] ?? {});
          dailySuvichar = DailySuvichar.fromMap(data['dailySuvichar'] ?? {});
          videos = (data['videos'] as List? ?? []).map((e) => VideoItem.fromMap(e)).toList();
          ramKatha = RamKathaSection.fromMap(data['ramKatha'] ?? {});
          stotraSection = StotraSection.fromMap(data['stotraSection'] ?? {});
          footer = FooterData.fromMap(data['footer'] ?? {});
          
          aboutDadaPage = AboutDadaPageData.fromMap(data['aboutDadaPage'] ?? {});
          homepageData = HomepageData.fromMap(data['homepageData'] ?? {});
          
          bhagvatKathaPage = KathaAboutPageData.fromMap(data['bhagvatKathaPage'] ?? {});
          deviKathaPage = KathaAboutPageData.fromMap(data['deviKathaPage'] ?? {});
          shivKathaPage = KathaAboutPageData.fromMap(data['shivKathaPage'] ?? {});

          allKathas = (data['allKathas'] as List? ?? []).map((e) => KathaRecord.fromMap(e)).toList();
          kathaListPageData = KathaListPageData.fromMap(data['kathaListPageData'] ?? {});
          contactPageData = ContactPageData.fromMap(data['contactPageData'] ?? {});
          videoGalleryData = VideoGalleryPageData.fromMap(data['videoGalleryData'] ?? {});
          photoGalleryData = PhotoGalleryPageData.fromMap(data['photoGalleryData'] ?? {});
        }
      }
      
      final inquirySnapshot = await _firestore.collection('inquiries').orderBy('timestamp', descending: true).get();
      inquiries = inquirySnapshot.docs.map((doc) => ContactInquiry.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      debugPrint("Load error: $e");
    }
    
    isLoading = false;
    notifyListeners();
  }

  // Management functions
  void addHeroSlide() { heroSection.slides.add(HeroSlide()); notifyListeners(); }
  void removeHeroSlide(int i) { heroSection.slides.removeAt(i); notifyListeners(); }
  void addKatha() { upcomingKathas.add(UpcomingKatha()); notifyListeners(); }
  void removeKatha(int i) { upcomingKathas.removeAt(i); notifyListeners(); }
  void addVideo() { videos.add(VideoItem()); notifyListeners(); }
  void removeVideo(int i) { videos.removeAt(i); notifyListeners(); }
  void addTeaching() { homepageData.teachings.add(TeachingCard()); notifyListeners(); }
  void removeTeaching(int i) { homepageData.teachings.removeAt(i); notifyListeners(); }
  void addTestimonial() { homepageData.testimonials.add(Testimonial()); notifyListeners(); }
  void removeTestimonial(int i) { homepageData.testimonials.removeAt(i); notifyListeners(); }
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

  Future<String?> uploadPhotoFromFile() async {
    try {
      isUploading = true;
      notifyListeners();
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, withData: kIsWeb);
      if (result == null || result.files.isEmpty) { isUploading = false; notifyListeners(); return null; }
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
    } catch (e) { isUploading = false; notifyListeners(); return null; }
  }

  void addBiographyPhase() { aboutDadaPage.phases.add(BiographyPhase()); notifyListeners(); }
  void removeBiographyPhase(int i) { aboutDadaPage.phases.removeAt(i); notifyListeners(); }
  void addImageToPhase(int phaseIdx, String url) { aboutDadaPage.phases[phaseIdx].images.add(url); notifyListeners(); }
  void removeImageFromPhase(int phaseIdx, int imgIdx) { aboutDadaPage.phases[phaseIdx].images.removeAt(imgIdx); notifyListeners(); }

  void addVideoCategory() { videoGalleryData.categories.add(VideoCategory()); notifyListeners(); }
  void removeVideoCategory(int i) { videoGalleryData.categories.removeAt(i); notifyListeners(); }
  void addVideoToCategory(int catIdx) { videoGalleryData.categories[catIdx].videos.add(VideoGalleryEntry()); notifyListeners(); }
  void removeVideoFromCategory(int catIdx, int vidIdx) { videoGalleryData.categories[catIdx].videos.removeAt(vidIdx); notifyListeners(); }

  void addPhotoCategory() { photoGalleryData.sections.add(PhotoGallerySection(heading: 'New Heading')); notifyListeners(); }
  void removePhotoCategory(int i) { photoGalleryData.sections.removeAt(i); notifyListeners(); }
  void removePhotoFromCategory(int catIdx, int photoIdx) { photoGalleryData.sections[catIdx].photoUrls.removeAt(photoIdx); notifyListeners(); }
  void addPhotoUrlToSection(int sectionIndex) { photoGalleryData.sections[sectionIndex].photoUrls.add(''); notifyListeners(); }

  Future<void> addPhotoToCategoryFromPicker(int catIdx) async {
    final url = await uploadPhotoFromFile();
    if (url != null && catIdx >= 0 && catIdx < photoGalleryData.sections.length) {
      photoGalleryData.sections[catIdx].photoUrls.add(url);
      notifyListeners();
    }
  }

  /// Translates ALL content fields to Hindi and Gujarati, then publishes to Firestore.
  /// Call this from the admin "Translate & Publish" button.
  Future<void> translateAndPublish() async {
    isLoading = true;
    notifyListeners();
    try {
      // ── Hero Slides ──────────────────────────────────────────────────────────
      for (final s in heroSection.slides) {
        if (s.badge.isNotEmpty) { s.badgeHi = await TranslationService.translateText(s.badge, 'hi'); s.badgeGu = await TranslationService.translateText(s.badge, 'gu'); }
        if (s.heading.isNotEmpty) { s.headingHi = await TranslationService.translateText(s.heading, 'hi'); s.headingGu = await TranslationService.translateText(s.heading, 'gu'); }
        if (s.subtitle.isNotEmpty) { s.subtitleHi = await TranslationService.translateText(s.subtitle, 'hi'); s.subtitleGu = await TranslationService.translateText(s.subtitle, 'gu'); }
        if (s.description.isNotEmpty) { s.descriptionHi = await TranslationService.translateText(s.description, 'hi'); s.descriptionGu = await TranslationService.translateText(s.description, 'gu'); }
      }
      // ── About Section ────────────────────────────────────────────────────────
      if (aboutSection.title.isNotEmpty) { aboutSection.titleHi = await TranslationService.translateText(aboutSection.title, 'hi'); aboutSection.titleGu = await TranslationService.translateText(aboutSection.title, 'gu'); }
      if (aboutSection.tagline.isNotEmpty) { aboutSection.taglineHi = await TranslationService.translateText(aboutSection.tagline, 'hi'); aboutSection.taglineGu = await TranslationService.translateText(aboutSection.tagline, 'gu'); }
      if (aboutSection.description.isNotEmpty) { aboutSection.descriptionHi = await TranslationService.translateText(aboutSection.description, 'hi'); aboutSection.descriptionGu = await TranslationService.translateText(aboutSection.description, 'gu'); }
      if (aboutSection.paragraphs.isNotEmpty) {
        aboutSection.paragraphsHi = await TranslationService.translateBatch(aboutSection.paragraphs, 'hi');
        aboutSection.paragraphsGu = await TranslationService.translateBatch(aboutSection.paragraphs, 'gu');
      }
      // ── Ram Katha ────────────────────────────────────────────────────────────
      if (ramKatha.description1.isNotEmpty) { ramKatha.description1Hi = await TranslationService.translateText(ramKatha.description1, 'hi'); ramKatha.description1Gu = await TranslationService.translateText(ramKatha.description1, 'gu'); }
      if (ramKatha.description2.isNotEmpty) { ramKatha.description2Hi = await TranslationService.translateText(ramKatha.description2, 'hi'); ramKatha.description2Gu = await TranslationService.translateText(ramKatha.description2, 'gu'); }
      // ── Upcoming Kathas ──────────────────────────────────────────────────────
      for (final k in upcomingKathas) {
        if (k.name.isNotEmpty) { k.nameHi = await TranslationService.translateText(k.name, 'hi'); k.nameGu = await TranslationService.translateText(k.name, 'gu'); }
        if (k.location.isNotEmpty) { k.locationHi = await TranslationService.translateText(k.location, 'hi'); k.locationGu = await TranslationService.translateText(k.location, 'gu'); }
        if (k.dateString.isNotEmpty) { k.dateStringHi = await TranslationService.translateText(k.dateString, 'hi'); k.dateStringGu = await TranslationService.translateText(k.dateString, 'gu'); }
      }
      // ── Featured Quote ───────────────────────────────────────────────────────
      if (homepageData.featuredQuote.quote.isNotEmpty) { homepageData.featuredQuote.quoteHi = await TranslationService.translateText(homepageData.featuredQuote.quote, 'hi'); homepageData.featuredQuote.quoteGu = await TranslationService.translateText(homepageData.featuredQuote.quote, 'gu'); }
      if (homepageData.featuredQuote.author.isNotEmpty) { homepageData.featuredQuote.authorHi = await TranslationService.translateText(homepageData.featuredQuote.author, 'hi'); homepageData.featuredQuote.authorGu = await TranslationService.translateText(homepageData.featuredQuote.author, 'gu'); }
      // ── Teaching Cards ───────────────────────────────────────────────────────
      for (final t in homepageData.teachings) {
        if (t.title.isNotEmpty) { t.titleHi = await TranslationService.translateText(t.title, 'hi'); t.titleGu = await TranslationService.translateText(t.title, 'gu'); }
        if (t.subtitle.isNotEmpty) { t.subtitleHi = await TranslationService.translateText(t.subtitle, 'hi'); t.subtitleGu = await TranslationService.translateText(t.subtitle, 'gu'); }
        if (t.description.isNotEmpty) { t.descriptionHi = await TranslationService.translateText(t.description, 'hi'); t.descriptionGu = await TranslationService.translateText(t.description, 'gu'); }
      }
      // ── Testimonials ─────────────────────────────────────────────────────────
      for (final t in homepageData.testimonials) {
        if (t.name.isNotEmpty) { t.nameHi = await TranslationService.translateText(t.name, 'hi'); t.nameGu = await TranslationService.translateText(t.name, 'gu'); }
        if (t.feedback.isNotEmpty) { t.feedbackHi = await TranslationService.translateText(t.feedback, 'hi'); t.feedbackGu = await TranslationService.translateText(t.feedback, 'gu'); }
      }
      // ── Biography Phases ─────────────────────────────────────────────────────
      for (final p in aboutDadaPage.phases) {
        if (p.title.isNotEmpty) { p.titleHi = await TranslationService.translateText(p.title, 'hi'); p.titleGu = await TranslationService.translateText(p.title, 'gu'); }
        if (p.subtitle.isNotEmpty) { p.subtitleHi = await TranslationService.translateText(p.subtitle, 'hi'); p.subtitleGu = await TranslationService.translateText(p.subtitle, 'gu'); }
        if (p.content.isNotEmpty) { p.contentHi = await TranslationService.translateText(p.content, 'hi'); p.contentGu = await TranslationService.translateText(p.content, 'gu'); }
      }
      
      // ── Generic Katha Pages ──────────────────────────────────────────────────
      Future<void> translateKathaPage(KathaAboutPageData kPage) async {
        if (kPage.heroBadge.isNotEmpty) { kPage.heroBadgeHi = await TranslationService.translateText(kPage.heroBadge, 'hi'); kPage.heroBadgeGu = await TranslationService.translateText(kPage.heroBadge, 'gu'); }
        if (kPage.heroTitle.isNotEmpty) { kPage.heroTitleHi = await TranslationService.translateText(kPage.heroTitle, 'hi'); kPage.heroTitleGu = await TranslationService.translateText(kPage.heroTitle, 'gu'); }
        if (kPage.heroDesc1.isNotEmpty) { kPage.heroDesc1Hi = await TranslationService.translateText(kPage.heroDesc1, 'hi'); kPage.heroDesc1Gu = await TranslationService.translateText(kPage.heroDesc1, 'gu'); }
        if (kPage.heroDesc2.isNotEmpty) { kPage.heroDesc2Hi = await TranslationService.translateText(kPage.heroDesc2, 'hi'); kPage.heroDesc2Gu = await TranslationService.translateText(kPage.heroDesc2, 'gu'); }
        if (kPage.bioText.isNotEmpty) { kPage.bioTextHi = await TranslationService.translateText(kPage.bioText, 'hi'); kPage.bioTextGu = await TranslationService.translateText(kPage.bioText, 'gu'); }
        if (kPage.quoteText.isNotEmpty) { kPage.quoteTextHi = await TranslationService.translateText(kPage.quoteText, 'hi'); kPage.quoteTextGu = await TranslationService.translateText(kPage.quoteText, 'gu'); }
        if (kPage.quoteAuthor.isNotEmpty) { kPage.quoteAuthorHi = await TranslationService.translateText(kPage.quoteAuthor, 'hi'); kPage.quoteAuthorGu = await TranslationService.translateText(kPage.quoteAuthor, 'gu'); }
        if (kPage.highlight1Title.isNotEmpty) { kPage.highlight1TitleHi = await TranslationService.translateText(kPage.highlight1Title, 'hi'); kPage.highlight1TitleGu = await TranslationService.translateText(kPage.highlight1Title, 'gu'); }
        if (kPage.highlight1Desc.isNotEmpty) { kPage.highlight1DescHi = await TranslationService.translateText(kPage.highlight1Desc, 'hi'); kPage.highlight1DescGu = await TranslationService.translateText(kPage.highlight1Desc, 'gu'); }
        if (kPage.highlight2Title.isNotEmpty) { kPage.highlight2TitleHi = await TranslationService.translateText(kPage.highlight2Title, 'hi'); kPage.highlight2TitleGu = await TranslationService.translateText(kPage.highlight2Title, 'gu'); }
        if (kPage.highlight2Desc.isNotEmpty) { kPage.highlight2DescHi = await TranslationService.translateText(kPage.highlight2Desc, 'hi'); kPage.highlight2DescGu = await TranslationService.translateText(kPage.highlight2Desc, 'gu'); }
        if (kPage.highlight3Title.isNotEmpty) { kPage.highlight3TitleHi = await TranslationService.translateText(kPage.highlight3Title, 'hi'); kPage.highlight3TitleGu = await TranslationService.translateText(kPage.highlight3Title, 'gu'); }
        if (kPage.highlight3Desc.isNotEmpty) { kPage.highlight3DescHi = await TranslationService.translateText(kPage.highlight3Desc, 'hi'); kPage.highlight3DescGu = await TranslationService.translateText(kPage.highlight3Desc, 'gu'); }
        if (kPage.ctaTitle.isNotEmpty) { kPage.ctaTitleHi = await TranslationService.translateText(kPage.ctaTitle, 'hi'); kPage.ctaTitleGu = await TranslationService.translateText(kPage.ctaTitle, 'gu'); }
        if (kPage.ctaSubtitle.isNotEmpty) { kPage.ctaSubtitleHi = await TranslationService.translateText(kPage.ctaSubtitle, 'hi'); kPage.ctaSubtitleGu = await TranslationService.translateText(kPage.ctaSubtitle, 'gu'); }
        if (kPage.ctaButtonText.isNotEmpty) { kPage.ctaButtonTextHi = await TranslationService.translateText(kPage.ctaButtonText, 'hi'); kPage.ctaButtonTextGu = await TranslationService.translateText(kPage.ctaButtonText, 'gu'); }
      }
      await translateKathaPage(bhagvatKathaPage);
      await translateKathaPage(deviKathaPage);
      await translateKathaPage(shivKathaPage);

      // ── News Items ───────────────────────────────────────────────────────────
      for (final n in homepageData.news) {
        if (n.title.isNotEmpty) { n.titleHi = await TranslationService.translateText(n.title, 'hi'); n.titleGu = await TranslationService.translateText(n.title, 'gu'); }
        if (n.category.isNotEmpty) { n.categoryHi = await TranslationService.translateText(n.category, 'hi'); n.categoryGu = await TranslationService.translateText(n.category, 'gu'); }
      }

      // ── Full Katha List ──────────────────────────────────────────────────────
      for (final k in allKathas) {
        if (k.topic.isNotEmpty) { k.topicHi = await TranslationService.translateText(k.topic, 'hi'); k.topicGu = await TranslationService.translateText(k.topic, 'gu'); }
        if (k.location.isNotEmpty) { k.locationHi = await TranslationService.translateText(k.location, 'hi'); k.locationGu = await TranslationService.translateText(k.location, 'gu'); }
        if (k.description.isNotEmpty) { k.descriptionHi = await TranslationService.translateText(k.description, 'hi'); k.descriptionGu = await TranslationService.translateText(k.description, 'gu'); }
      }

      // ── Footer ───────────────────────────────────────────────────────────────
      if (footer.description.isNotEmpty) {
        footer.descriptionHi = await TranslationService.translateText(footer.description, 'hi');
        footer.descriptionGu = await TranslationService.translateText(footer.description, 'gu');
      }

      // ── Videos (Homepage Latest) ─────────────────────────────────────────────
      for (final v in videos) {
        if (v.title.isNotEmpty) { v.titleHi = await TranslationService.translateText(v.title, 'hi'); v.titleGu = await TranslationService.translateText(v.title, 'gu'); }
      }

      // ── Stotra Section ───────────────────────────────────────────────────────
      if (stotraSection.pageTitle.isNotEmpty) {
        stotraSection.pageTitleHi = await TranslationService.translateText(stotraSection.pageTitle, 'hi');
        stotraSection.pageTitleGu = await TranslationService.translateText(stotraSection.pageTitle, 'gu');
      }
      for (final s in stotraSection.items) {
        if (s.title.isNotEmpty) { s.titleHi = await TranslationService.translateText(s.title, 'hi'); s.titleGu = await TranslationService.translateText(s.title, 'gu'); }
      }

      // ── Galleries ────────────────────────────────────────────────────────────
      if (photoGalleryData.title.isNotEmpty) {
        photoGalleryData.titleHi = await TranslationService.translateText(photoGalleryData.title, 'hi');
        photoGalleryData.titleGu = await TranslationService.translateText(photoGalleryData.title, 'gu');
      }
      for (final sec in photoGalleryData.sections) {
        if (sec.heading.isNotEmpty) { sec.headingHi = await TranslationService.translateText(sec.heading, 'hi'); sec.headingGu = await TranslationService.translateText(sec.heading, 'gu'); }
      }
      
      for (final cat in videoGalleryData.categories) {
        if (cat.categoryTitle.isNotEmpty) { cat.categoryTitleHi = await TranslationService.translateText(cat.categoryTitle, 'hi'); cat.categoryTitleGu = await TranslationService.translateText(cat.categoryTitle, 'gu'); }
        for (final v in cat.videos) {
           if (v.title.isNotEmpty) { v.titleHi = await TranslationService.translateText(v.title, 'hi'); v.titleGu = await TranslationService.translateText(v.title, 'gu'); }
        }
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    // After translating, publish
    await publish();
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
        'aboutDadaPage': aboutDadaPage.toMap(),
        'homepageData': homepageData.toMap(),
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
