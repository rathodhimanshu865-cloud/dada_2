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
      final futures = <Future<void>>[];

      // ── Hero Slides ──────────────────────────────────────────────────────────
      for (final s in heroSection.slides) {
        if (s.badge.isNotEmpty) futures.add(TranslationService.translateToAll(s.badge).then((res) { s.badgeHi = res['hi'] ?? ''; s.badgeGu = res['gu'] ?? ''; }));
        if (s.heading.isNotEmpty) futures.add(TranslationService.translateToAll(s.heading).then((res) { s.headingHi = res['hi'] ?? ''; s.headingGu = res['gu'] ?? ''; }));
        if (s.subtitle.isNotEmpty) futures.add(TranslationService.translateToAll(s.subtitle).then((res) { s.subtitleHi = res['hi'] ?? ''; s.subtitleGu = res['gu'] ?? ''; }));
        if (s.description.isNotEmpty) futures.add(TranslationService.translateToAll(s.description).then((res) { s.descriptionHi = res['hi'] ?? ''; s.descriptionGu = res['gu'] ?? ''; }));
      }
      // ── About Section ────────────────────────────────────────────────────────
      if (aboutSection.title.isNotEmpty) futures.add(TranslationService.translateToAll(aboutSection.title).then((res) { aboutSection.titleHi = res['hi'] ?? ''; aboutSection.titleGu = res['gu'] ?? ''; }));
      if (aboutSection.tagline.isNotEmpty) futures.add(TranslationService.translateToAll(aboutSection.tagline).then((res) { aboutSection.taglineHi = res['hi'] ?? ''; aboutSection.taglineGu = res['gu'] ?? ''; }));
      if (aboutSection.description.isNotEmpty) futures.add(TranslationService.translateToAll(aboutSection.description).then((res) { aboutSection.descriptionHi = res['hi'] ?? ''; aboutSection.descriptionGu = res['gu'] ?? ''; }));
      if (aboutSection.paragraphs.isNotEmpty) {
        futures.add(TranslationService.translateBatch(aboutSection.paragraphs, 'hi').then((res) => aboutSection.paragraphsHi = res));
        futures.add(TranslationService.translateBatch(aboutSection.paragraphs, 'gu').then((res) => aboutSection.paragraphsGu = res));
      }
      // ── Ram Katha ────────────────────────────────────────────────────────────
      if (ramKatha.description1.isNotEmpty) futures.add(TranslationService.translateToAll(ramKatha.description1).then((res) { ramKatha.description1Hi = res['hi'] ?? ''; ramKatha.description1Gu = res['gu'] ?? ''; }));
      if (ramKatha.description2.isNotEmpty) futures.add(TranslationService.translateToAll(ramKatha.description2).then((res) { ramKatha.description2Hi = res['hi'] ?? ''; ramKatha.description2Gu = res['gu'] ?? ''; }));
      
      // ── Upcoming Kathas ──────────────────────────────────────────────────────
      for (final k in upcomingKathas) {
        if (k.name.isNotEmpty) futures.add(TranslationService.translateToAll(k.name).then((res) { k.nameHi = res['hi'] ?? ''; k.nameGu = res['gu'] ?? ''; }));
        if (k.location.isNotEmpty) futures.add(TranslationService.translateToAll(k.location).then((res) { k.locationHi = res['hi'] ?? ''; k.locationGu = res['gu'] ?? ''; }));
        if (k.dateString.isNotEmpty) futures.add(TranslationService.translateToAll(k.dateString).then((res) { k.dateStringHi = res['hi'] ?? ''; k.dateStringGu = res['gu'] ?? ''; }));
      }
      // ── Featured Quote ───────────────────────────────────────────────────────
      if (homepageData.featuredQuote.quote.isNotEmpty) futures.add(TranslationService.translateToAll(homepageData.featuredQuote.quote).then((res) { homepageData.featuredQuote.quoteHi = res['hi'] ?? ''; homepageData.featuredQuote.quoteGu = res['gu'] ?? ''; }));
      if (homepageData.featuredQuote.author.isNotEmpty) futures.add(TranslationService.translateToAll(homepageData.featuredQuote.author).then((res) { homepageData.featuredQuote.authorHi = res['hi'] ?? ''; homepageData.featuredQuote.authorGu = res['gu'] ?? ''; }));
      
      // ── Teaching Cards ───────────────────────────────────────────────────────
      for (final t in homepageData.teachings) {
        if (t.title.isNotEmpty) futures.add(TranslationService.translateToAll(t.title).then((res) { t.titleHi = res['hi'] ?? ''; t.titleGu = res['gu'] ?? ''; }));
        if (t.subtitle.isNotEmpty) futures.add(TranslationService.translateToAll(t.subtitle).then((res) { t.subtitleHi = res['hi'] ?? ''; t.subtitleGu = res['gu'] ?? ''; }));
        if (t.description.isNotEmpty) futures.add(TranslationService.translateToAll(t.description).then((res) { t.descriptionHi = res['hi'] ?? ''; t.descriptionGu = res['gu'] ?? ''; }));
      }
      // ── Testimonials ─────────────────────────────────────────────────────────
      for (final t in homepageData.testimonials) {
        if (t.name.isNotEmpty) futures.add(TranslationService.translateToAll(t.name).then((res) { t.nameHi = res['hi'] ?? ''; t.nameGu = res['gu'] ?? ''; }));
        if (t.feedback.isNotEmpty) futures.add(TranslationService.translateToAll(t.feedback).then((res) { t.feedbackHi = res['hi'] ?? ''; t.feedbackGu = res['gu'] ?? ''; }));
      }
      // ── Biography Hero & Phases ──────────────────────────────────────────────
      if (aboutDadaPage.heroTitle.isNotEmpty) futures.add(TranslationService.translateToAll(aboutDadaPage.heroTitle).then((res) { aboutDadaPage.heroTitleHi = res['hi'] ?? ''; aboutDadaPage.heroTitleGu = res['gu'] ?? ''; }));
      if (aboutDadaPage.heroSubtitle.isNotEmpty) futures.add(TranslationService.translateToAll(aboutDadaPage.heroSubtitle).then((res) { aboutDadaPage.heroSubtitleHi = res['hi'] ?? ''; aboutDadaPage.heroSubtitleGu = res['gu'] ?? ''; }));
      for (final p in aboutDadaPage.phases) {
        if (p.title.isNotEmpty) futures.add(TranslationService.translateToAll(p.title).then((res) { p.titleHi = res['hi'] ?? ''; p.titleGu = res['gu'] ?? ''; }));
        if (p.subtitle.isNotEmpty) futures.add(TranslationService.translateToAll(p.subtitle).then((res) { p.subtitleHi = res['hi'] ?? ''; p.subtitleGu = res['gu'] ?? ''; }));
        if (p.content.isNotEmpty) futures.add(TranslationService.translateToAll(p.content).then((res) { p.contentHi = res['hi'] ?? ''; p.contentGu = res['gu'] ?? ''; }));
      }
      
      // ── Generic Katha Pages ──────────────────────────────────────────────────
      void translateKathaPage(KathaAboutPageData kPage) {
        if (kPage.heroBadge.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.heroBadge).then((res) { kPage.heroBadgeHi = res['hi'] ?? ''; kPage.heroBadgeGu = res['gu'] ?? ''; }));
        if (kPage.heroTitle.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.heroTitle).then((res) { kPage.heroTitleHi = res['hi'] ?? ''; kPage.heroTitleGu = res['gu'] ?? ''; }));
        if (kPage.heroDesc1.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.heroDesc1).then((res) { kPage.heroDesc1Hi = res['hi'] ?? ''; kPage.heroDesc1Gu = res['gu'] ?? ''; }));
        if (kPage.heroDesc2.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.heroDesc2).then((res) { kPage.heroDesc2Hi = res['hi'] ?? ''; kPage.heroDesc2Gu = res['gu'] ?? ''; }));
        if (kPage.bioText.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.bioText).then((res) { kPage.bioTextHi = res['hi'] ?? ''; kPage.bioTextGu = res['gu'] ?? ''; }));
        if (kPage.quoteText.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.quoteText).then((res) { kPage.quoteTextHi = res['hi'] ?? ''; kPage.quoteTextGu = res['gu'] ?? ''; }));
        if (kPage.quoteAuthor.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.quoteAuthor).then((res) { kPage.quoteAuthorHi = res['hi'] ?? ''; kPage.quoteAuthorGu = res['gu'] ?? ''; }));
        if (kPage.highlight1Title.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.highlight1Title).then((res) { kPage.highlight1TitleHi = res['hi'] ?? ''; kPage.highlight1TitleGu = res['gu'] ?? ''; }));
        if (kPage.highlight1Desc.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.highlight1Desc).then((res) { kPage.highlight1DescHi = res['hi'] ?? ''; kPage.highlight1DescGu = res['gu'] ?? ''; }));
        if (kPage.highlight2Title.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.highlight2Title).then((res) { kPage.highlight2TitleHi = res['hi'] ?? ''; kPage.highlight2TitleGu = res['gu'] ?? ''; }));
        if (kPage.highlight2Desc.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.highlight2Desc).then((res) { kPage.highlight2DescHi = res['hi'] ?? ''; kPage.highlight2DescGu = res['gu'] ?? ''; }));
        if (kPage.highlight3Title.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.highlight3Title).then((res) { kPage.highlight3TitleHi = res['hi'] ?? ''; kPage.highlight3TitleGu = res['gu'] ?? ''; }));
        if (kPage.highlight3Desc.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.highlight3Desc).then((res) { kPage.highlight3DescHi = res['hi'] ?? ''; kPage.highlight3DescGu = res['gu'] ?? ''; }));
        if (kPage.ctaTitle.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.ctaTitle).then((res) { kPage.ctaTitleHi = res['hi'] ?? ''; kPage.ctaTitleGu = res['gu'] ?? ''; }));
        if (kPage.ctaSubtitle.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.ctaSubtitle).then((res) { kPage.ctaSubtitleHi = res['hi'] ?? ''; kPage.ctaSubtitleGu = res['gu'] ?? ''; }));
        if (kPage.ctaButtonText.isNotEmpty) futures.add(TranslationService.translateToAll(kPage.ctaButtonText).then((res) { kPage.ctaButtonTextHi = res['hi'] ?? ''; kPage.ctaButtonTextGu = res['gu'] ?? ''; }));
      }
      translateKathaPage(bhagvatKathaPage);
      translateKathaPage(deviKathaPage);
      translateKathaPage(shivKathaPage);

      // ── News Items ───────────────────────────────────────────────────────────
      for (final n in homepageData.news) {
        if (n.title.isNotEmpty) futures.add(TranslationService.translateToAll(n.title).then((res) { n.titleHi = res['hi'] ?? ''; n.titleGu = res['gu'] ?? ''; }));
        if (n.category.isNotEmpty) futures.add(TranslationService.translateToAll(n.category).then((res) { n.categoryHi = res['hi'] ?? ''; n.categoryGu = res['gu'] ?? ''; }));
      }

      // ── Full Katha List ──────────────────────────────────────────────────────
      for (final k in allKathas) {
        if (k.topic.isNotEmpty) futures.add(TranslationService.translateToAll(k.topic).then((res) { k.topicHi = res['hi'] ?? ''; k.topicGu = res['gu'] ?? ''; }));
        if (k.location.isNotEmpty) futures.add(TranslationService.translateToAll(k.location).then((res) { k.locationHi = res['hi'] ?? ''; k.locationGu = res['gu'] ?? ''; }));
        if (k.description.isNotEmpty) futures.add(TranslationService.translateToAll(k.description).then((res) { k.descriptionHi = res['hi'] ?? ''; k.descriptionGu = res['gu'] ?? ''; }));
      }

      // ── Footer ───────────────────────────────────────────────────────────────
      if (footer.description.isNotEmpty) futures.add(TranslationService.translateToAll(footer.description).then((res) { footer.descriptionHi = res['hi'] ?? ''; footer.descriptionGu = res['gu'] ?? ''; }));

      // ── Videos (Homepage Latest) ─────────────────────────────────────────────
      for (final v in videos) {
        if (v.title.isNotEmpty) futures.add(TranslationService.translateToAll(v.title).then((res) { v.titleHi = res['hi'] ?? ''; v.titleGu = res['gu'] ?? ''; }));
      }

      // ── Stotra Section ───────────────────────────────────────────────────────
      if (stotraSection.pageTitle.isNotEmpty) futures.add(TranslationService.translateToAll(stotraSection.pageTitle).then((res) { stotraSection.pageTitleHi = res['hi'] ?? ''; stotraSection.pageTitleGu = res['gu'] ?? ''; }));
      for (final s in stotraSection.items) {
        if (s.title.isNotEmpty) futures.add(TranslationService.translateToAll(s.title).then((res) { s.titleHi = res['hi'] ?? ''; s.titleGu = res['gu'] ?? ''; }));
      }

      // ── Galleries ────────────────────────────────────────────────────────────
      if (photoGalleryData.title.isNotEmpty) futures.add(TranslationService.translateToAll(photoGalleryData.title).then((res) { photoGalleryData.titleHi = res['hi'] ?? ''; photoGalleryData.titleGu = res['gu'] ?? ''; }));
      for (final sec in photoGalleryData.sections) {
        if (sec.heading.isNotEmpty) futures.add(TranslationService.translateToAll(sec.heading).then((res) { sec.headingHi = res['hi'] ?? ''; sec.headingGu = res['gu'] ?? ''; }));
      }
      
      for (final cat in videoGalleryData.categories) {
        if (cat.categoryTitle.isNotEmpty) futures.add(TranslationService.translateToAll(cat.categoryTitle).then((res) { cat.categoryTitleHi = res['hi'] ?? ''; cat.categoryTitleGu = res['gu'] ?? ''; }));
        for (final v in cat.videos) {
           if (v.title.isNotEmpty) futures.add(TranslationService.translateToAll(v.title).then((res) { v.titleHi = res['hi'] ?? ''; v.titleGu = res['gu'] ?? ''; }));
        }
      }

      await Future.wait(futures);
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    // After translating, publish to Firestore database
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
