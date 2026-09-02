import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/homepage_model.dart';
import '../models/contact_model.dart';
import '../services/translation_service.dart';
import '../utils/app_logger.dart';

class HomePageController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isDisposed = false;

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

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
  StreamSubscription<DocumentSnapshot>? _cmsSubscription;
  StreamSubscription<QuerySnapshot>? _inquiriesSubscription;

  HomePageController() {
    _initCMSStream();
    _initPhotosStream();
    _initInquiriesStream();
  }

  void _initInquiriesStream() {
    _inquiriesSubscription?.cancel();
    _inquiriesSubscription = _firestore
        .collection('inquiries')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      inquiries = snapshot.docs.map((doc) => ContactInquiry.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      _safeNotifyListeners();
    }, onError: (e) {
      AppLogger.error("Inquiries stream error", e);
    });
  }

  void _initCMSStream() {
    _cmsSubscription?.cancel();
    isLoading = true;
    _safeNotifyListeners();

    _cmsSubscription = _firestore
        .collection('cms')
        .doc('homepage')
        .snapshots()
        .listen((doc) {
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
      isLoading = false;
      _safeNotifyListeners();
    }, onError: (e) {
      AppLogger.error("CMS stream error", e);
      isLoading = false;
      _safeNotifyListeners();
    });
  }

  void _initPhotosStream() {
    _photosSubscription?.cancel();
    _photosSubscription = _firestore
        .collection('photos')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      realTimePhotos = snapshot.docs.map((doc) => doc.data()).toList();
      _safeNotifyListeners();
    }, onError: (err) {
      AppLogger.error("Photos stream error", err);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _photosSubscription?.cancel();
    _cmsSubscription?.cancel();
    _inquiriesSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    _initCMSStream();
  }

  // Management functions
  void addHeroSlide() { heroSection.slides.add(HeroSlide()); _safeNotifyListeners(); }
  void removeHeroSlide(int i) { heroSection.slides.removeAt(i); _safeNotifyListeners(); }
  void addKatha() { upcomingKathas.add(UpcomingKatha()); _safeNotifyListeners(); }
  void removeKatha(int i) { upcomingKathas.removeAt(i); _safeNotifyListeners(); }
  void addVideo() { videos.add(VideoItem(title: 'New Video', youtubeUrl: '')); _safeNotifyListeners(); }
  void removeVideo(int i) { videos.removeAt(i); _safeNotifyListeners(); }
  void addTeaching() { homepageData.teachings.add(TeachingCard()); _safeNotifyListeners(); }
  void removeTeaching(int i) { homepageData.teachings.removeAt(i); _safeNotifyListeners(); }
  void addTestimonial() { homepageData.testimonials.add(Testimonial()); _safeNotifyListeners(); }
  void removeTestimonial(int i) { homepageData.testimonials.removeAt(i); _safeNotifyListeners(); }
  void addKathaRecord() { allKathas.add(KathaRecord()); _safeNotifyListeners(); }
  void removeKathaRecord(int i) { allKathas.removeAt(i); _safeNotifyListeners(); }
  void addStotraItem() { stotraSection.items.add(StotraItem()); _safeNotifyListeners(); }
  void removeStotraItem(int i) { stotraSection.items.removeAt(i); _safeNotifyListeners(); }

  void addPhotoCategory() { photoGalleryData.sections.add(PhotoGallerySection()); _safeNotifyListeners(); }
  void removePhotoCategory(int i) { photoGalleryData.sections.removeAt(i); _safeNotifyListeners(); }
  
  void addVideoCategory() { videoGalleryData.categories.add(VideoCategory()); _safeNotifyListeners(); }
  void removeVideoCategory(int i) { videoGalleryData.categories.removeAt(i); _safeNotifyListeners(); }
  void addVideoToCategory(int catIndex) { videoGalleryData.categories[catIndex].videos.add(VideoGalleryEntry()); _safeNotifyListeners(); }
  void removeVideoFromCategory(int catIndex, int vidIndex) { videoGalleryData.categories[catIndex].videos.removeAt(vidIndex); _safeNotifyListeners(); }

  void addFooterLinkSection() { footer.linkSections.add(FooterLinkSection(title: 'New Section')); _safeNotifyListeners(); }
  void removeFooterLinkSection(int i) { footer.linkSections.removeAt(i); _safeNotifyListeners(); }
  void addFooterLink(int sectionIndex) { footer.linkSections[sectionIndex].links.add(FooterLink(label: 'New Link', route: '/')); _safeNotifyListeners(); }
  void removeFooterLink(int sectionIndex, int linkIndex) { footer.linkSections[sectionIndex].links.removeAt(linkIndex); _safeNotifyListeners(); }

  void toggleHomeVisibility(String section) {
    switch (section) {
      case 'hero': homepageData.showHeroSlider = !homepageData.showHeroSlider; break;
      case 'quote': homepageData.showFeaturedQuote = !homepageData.showFeaturedQuote; break;
      case 'about': homepageData.showAboutPreview = !homepageData.showAboutPreview; break;
      case 'katha': homepageData.showUpcomingKathas = !homepageData.showUpcomingKathas; break;
      case 'videos': homepageData.showLatestVideos = !homepageData.showLatestVideos; break;
      case 'gallery': homepageData.showPhotoGallery = !homepageData.showPhotoGallery; break;
      case 'suvichar': homepageData.showDailySuvichar = !homepageData.showDailySuvichar; break;
      case 'ramkatha': homepageData.showRamKathaSection = !homepageData.showRamKathaSection; break;
      case 'news': homepageData.showNewsSection = !homepageData.showNewsSection; break;
      case 'teachings': homepageData.showTeachings = !homepageData.showTeachings; break;
    }
    _safeNotifyListeners();
  }

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
      _safeNotifyListeners();
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
      _safeNotifyListeners();
    }
    return null;
  }

  Future<void> translateKathas() async {
    isLoading = true;
    _safeNotifyListeners();
    try {
      // 1. Translate Upcoming Kathas
      for (var k in upcomingKathas) {
        final results = await TranslationService.translateToAll(k.name);
        k.nameHi = results['hi']!; k.nameGu = results['gu']!;
        
        final locResults = await TranslationService.translateToAll(k.location);
        k.locationHi = locResults['hi']!; k.locationGu = locResults['gu']!;
        
        final dateResults = await TranslationService.translateToAll(k.dateString);
        k.dateStringHi = dateResults['hi']!; k.dateStringGu = dateResults['gu']!;
        
        final descResults = await TranslationService.translateToAll(k.description);
        k.descriptionHi = descResults['hi']!; k.descriptionGu = descResults['gu']!;
        
        final timeResults = await TranslationService.translateToAll(k.timing);
        k.timingHi = timeResults['hi']!; k.timingGu = timeResults['gu']!;
        
        final hostResults = await TranslationService.translateToAll(k.hosting);
        k.hostingHi = hostResults['hi']!; k.hostingGu = hostResults['gu']!;
      }

      // 2. Translate All Kathas (Full List)
      for (var kr in allKathas) {
        final topicResults = await TranslationService.translateToAll(kr.topic);
        kr.topicHi = topicResults['hi']!; kr.topicGu = topicResults['gu']!;
        
        final locResults = await TranslationService.translateToAll(kr.location);
        kr.locationHi = locResults['hi']!; kr.locationGu = locResults['gu']!;
        
        final descResults = await TranslationService.translateToAll(kr.description);
        kr.descriptionHi = descResults['hi']!; kr.descriptionGu = descResults['gu']!;
        
        final yearResults = await TranslationService.translateToAll(kr.year);
        kr.yearHi = yearResults['hi']!; kr.yearGu = yearResults['gu']!;
        
        final datesResults = await TranslationService.translateToAll(kr.dates);
        kr.datesHi = datesResults['hi']!; kr.datesGu = datesResults['gu']!;
        
        final countryResults = await TranslationService.translateToAll(kr.country);
        kr.countryHi = countryResults['hi']!; kr.countryGu = countryResults['gu']!;
        
        final langResults = await TranslationService.translateToAll(kr.language);
        kr.languageHi = langResults['hi']!; kr.languageGu = langResults['gu']!;
      }

      // 3. Auto-publish after translation
      await publish();
    } catch (e) {
      AppLogger.error("Katha translation error", e);
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
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
    _safeNotifyListeners();
    try {
      // 1. General Settings
      final gTasks = await Future.wait([
        TranslationService.translateToAll(websiteSettings.name),
        TranslationService.translateToAll(websiteSettings.catalogueHeading),
        TranslationService.translateToAll(websiteSettings.headerSettings.donateButtonText),
        TranslationService.translateToAll(websiteSettings.headerSettings.announcementBarText),
      ]);
      
      final g0 = gTasks[0] as Map<String, String>;
      final g1 = gTasks[1] as Map<String, String>;
      final g2 = gTasks[2] as Map<String, String>;
      final g3 = gTasks[3] as Map<String, String>;

      websiteSettings.nameHi = g0['hi']!; websiteSettings.nameGu = g0['gu']!;
      websiteSettings.catalogueHeadingHi = g1['hi']!; websiteSettings.catalogueHeadingGu = g1['gu']!;
      websiteSettings.headerSettings.donateButtonTextHi = g2['hi']!; websiteSettings.headerSettings.donateButtonTextGu = g2['gu']!;
      websiteSettings.headerSettings.announcementBarTextHi = g3['hi']!; websiteSettings.headerSettings.announcementBarTextGu = g3['gu']!;

      // 2. Hero Slider
      await Future.wait(heroSection.slides.map((s) async {
        final results = await Future.wait([
          TranslationService.translateToAll(s.badge),
          TranslationService.translateToAll(s.heading),
          TranslationService.translateToAll(s.subtitle),
          TranslationService.translateToAll(s.description),
          TranslationService.translateToAll(s.primaryCtaText),
          TranslationService.translateToAll(s.secondaryCtaText),
        ]);
        final r0 = results[0] as Map<String, String>;
        final r1 = results[1] as Map<String, String>;
        final r2 = results[2] as Map<String, String>;
        final r3 = results[3] as Map<String, String>;
        final r4 = results[4] as Map<String, String>;
        final r5 = results[5] as Map<String, String>;
        
        s.badgeHi = r0['hi']!; s.badgeGu = r0['gu']!;
        s.headingHi = r1['hi']!; s.headingGu = r1['gu']!;
        s.subtitleHi = r2['hi']!; s.subtitleGu = r2['gu']!;
        s.descriptionHi = r3['hi']!; s.descriptionGu = r3['gu']!;
        s.primaryCtaTextHi = r4['hi']!; s.primaryCtaTextGu = r4['gu']!;
        s.secondaryCtaTextHi = r5['hi']!; s.secondaryCtaTextGu = r5['gu']!;
      }));

      // 3. Upcoming Kathas
      await Future.wait(upcomingKathas.map((k) async {
        final results = await Future.wait([
          TranslationService.translateToAll(k.name),
          TranslationService.translateToAll(k.location),
          TranslationService.translateToAll(k.dateString),
          TranslationService.translateToAll(k.description),
          TranslationService.translateToAll(k.timing),
          TranslationService.translateToAll(k.hosting),
        ]);
        final r0 = results[0] as Map<String, String>;
        final r1 = results[1] as Map<String, String>;
        final r2 = results[2] as Map<String, String>;
        final r3 = results[3] as Map<String, String>;
        final r4 = results[4] as Map<String, String>;
        final r5 = results[5] as Map<String, String>;

        k.nameHi = r0['hi']!; k.nameGu = r0['gu']!;
        k.locationHi = r1['hi']!; k.locationGu = r1['gu']!;
        k.dateStringHi = r2['hi']!; k.dateStringGu = r2['gu']!;
        k.descriptionHi = r3['hi']!; k.descriptionGu = r3['gu']!;
        k.timingHi = r4['hi']!; k.timingGu = r4['gu']!;
        k.hostingHi = r5['hi']!; k.hostingGu = r5['gu']!;
      }));

      // 4. About Section
      final abTasks = await Future.wait([
        TranslationService.translateToAll(aboutSection.title),
        TranslationService.translateToAll(aboutSection.tagline),
        TranslationService.translateToAll(aboutSection.description),
        TranslationService.translateBatch(aboutSection.paragraphs, 'hi'),
        TranslationService.translateBatch(aboutSection.paragraphs, 'gu'),
      ]);
      final ab0 = abTasks[0] as Map<String, String>;
      final ab1 = abTasks[1] as Map<String, String>;
      final ab2 = abTasks[2] as Map<String, String>;

      aboutSection.titleHi = ab0['hi']!; aboutSection.titleGu = ab0['gu']!;
      aboutSection.taglineHi = ab1['hi']!; aboutSection.taglineGu = ab1['gu']!;
      aboutSection.descriptionHi = ab2['hi']!; aboutSection.descriptionGu = ab2['gu']!;
      aboutSection.paragraphsHi = abTasks[3] as List<String>;
      aboutSection.paragraphsGu = abTasks[4] as List<String>;

      // 5. Homepage Data
      await Future.wait([
        ...homepageData.teachings.map((t) async {
          final results = await Future.wait([
            TranslationService.translateToAll(t.title),
            TranslationService.translateToAll(t.subtitle),
            TranslationService.translateToAll(t.description),
          ]);
          final r0 = results[0] as Map<String, String>;
          final r1 = results[1] as Map<String, String>;
          final r2 = results[2] as Map<String, String>;
          t.titleHi = r0['hi']!; t.titleGu = r0['gu']!;
          t.subtitleHi = r1['hi']!; t.subtitleGu = r1['gu']!;
          t.descriptionHi = r2['hi']!; t.descriptionGu = r2['gu']!;
        }),
        ...homepageData.testimonials.map((te) async {
          final results = await Future.wait([
            TranslationService.translateToAll(te.feedback),
            TranslationService.translateToAll(te.name),
          ]);
          final r0 = results[0] as Map<String, String>;
          final r1 = results[1] as Map<String, String>;
          te.feedbackHi = r0['hi']!; te.feedbackGu = r0['gu']!;
          te.nameHi = r1['hi']!; te.nameGu = r1['gu']!;
        }),
        ...homepageData.news.map((ni) async {
          final results = await Future.wait([
            TranslationService.translateToAll(ni.title),
            TranslationService.translateToAll(ni.category),
            TranslationService.translateToAll(ni.date),
          ]);
          final r0 = results[0] as Map<String, String>;
          final r1 = results[1] as Map<String, String>;
          final r2 = results[2] as Map<String, String>;
          ni.titleHi = r0['hi']!; ni.titleGu = r0['gu']!;
          ni.categoryHi = r1['hi']!; ni.categoryGu = r1['gu']!;
          ni.dateHi = r2['hi']!; ni.dateGu = r2['gu']!;
        }),
      ]);

      // 6. Featured Quote & Ram Katha
      final qTasks = await Future.wait([
        TranslationService.translateToAll(homepageData.featuredQuote.quote),
        TranslationService.translateToAll(homepageData.featuredQuote.author),
        TranslationService.translateToAll(ramKatha.description1),
        TranslationService.translateToAll(ramKatha.description2),
        TranslationService.translateToAll(dailySuvichar.date),
      ]);
      final q0 = qTasks[0] as Map<String, String>;
      final q1 = qTasks[1] as Map<String, String>;
      final q2 = qTasks[2] as Map<String, String>;
      final q3 = qTasks[3] as Map<String, String>;
      final q4 = qTasks[4] as Map<String, String>;

      homepageData.featuredQuote.quoteHi = q0['hi']!; homepageData.featuredQuote.quoteGu = q0['gu']!;
      homepageData.featuredQuote.authorHi = q1['hi']!; homepageData.featuredQuote.authorGu = q1['gu']!;
      ramKatha.description1Hi = q2['hi']!; ramKatha.description1Gu = q2['gu']!;
      ramKatha.description2Hi = q3['hi']!; ramKatha.description2Gu = q3['gu']!;
      dailySuvichar.dateHi = q4['hi']!; dailySuvichar.dateGu = q4['gu']!;

      // 7. Full Katha List
      await Future.wait(allKathas.map((kr) async {
        final results = await Future.wait([
          TranslationService.translateToAll(kr.topic),
          TranslationService.translateToAll(kr.location),
          TranslationService.translateToAll(kr.description),
        ]);
        final r0 = results[0] as Map<String, String>;
        final r1 = results[1] as Map<String, String>;
        final r2 = results[2] as Map<String, String>;
        kr.topicHi = r0['hi']!; kr.topicGu = r0['gu']!;
        kr.locationHi = r1['hi']!; kr.locationGu = r1['gu']!;
        kr.descriptionHi = r2['hi']!; kr.descriptionGu = r2['gu']!;
      }));

      // 8. Gallery
      await Future.wait([
        ...photoGalleryData.sections.map((ps) async {
          final h = await TranslationService.translateToAll(ps.heading);
          ps.headingHi = h['hi']!; ps.headingGu = h['gu']!;
        }),
        TranslationService.translateToAll(photoGalleryData.title).then((t) {
          photoGalleryData.titleHi = t['hi']!; photoGalleryData.titleGu = t['gu']!;
        }),
        ...videoGalleryData.categories.map((vc) async {
          final vt = await TranslationService.translateToAll(vc.categoryTitle);
          vc.categoryTitleHi = vt['hi']!; vc.categoryTitleGu = vt['gu']!;
          await Future.wait(vc.videos.map((vge) async {
            final vgt = await TranslationService.translateToAll(vge.title);
            vge.titleHi = vgt['hi']!; vge.titleGu = vgt['gu']!;
          }));
        }),
      ]);

      // 9. Stotra & Contact & Footer
      final miscTasks = await Future.wait([
        TranslationService.translateToAll(stotraSection.pageTitle),
        TranslationService.translateToAll(contactPageData.address),
        TranslationService.translateToAll(footer.description),
        TranslationService.translateToAll(footer.copyright),
        TranslationService.translateToAll(footer.privacyLabel),
        TranslationService.translateToAll(footer.termsLabel),
        TranslationService.translateToAll(footer.cookieLabel),
      ]);
      final m0 = miscTasks[0] as Map<String, String>;
      final m1 = miscTasks[1] as Map<String, String>;
      final m2 = miscTasks[2] as Map<String, String>;
      final m3 = miscTasks[3] as Map<String, String>;
      final m4 = miscTasks[4] as Map<String, String>;
      final m5 = miscTasks[5] as Map<String, String>;
      final m6 = miscTasks[6] as Map<String, String>;

      stotraSection.pageTitleHi = m0['hi']!; stotraSection.pageTitleGu = m0['gu']!;
      contactPageData.addressHi = m1['hi']!; contactPageData.addressGu = m1['gu']!;
      footer.descriptionHi = m2['hi']!; footer.descriptionGu = m2['gu']!;
      footer.copyrightHi = m3['hi']!; footer.copyrightGu = m3['gu']!;
      footer.privacyLabelHi = m4['hi']!; footer.privacyLabelGu = m4['gu']!;
      footer.termsLabelHi = m5['hi']!; footer.termsLabelGu = m5['gu']!;
      footer.cookieLabelHi = m6['hi']!; footer.cookieLabelGu = m6['gu']!;
      
      await Future.wait(stotraSection.items.map((si) async {
        final sit = await TranslationService.translateToAll(si.title);
        si.titleHi = sit['hi']!; si.titleGu = sit['gu']!;
      }));

      await Future.wait(footer.linkSections.map((sec) async {
        final st = await TranslationService.translateToAll(sec.title);
        sec.titleHi = st['hi']!; sec.titleGu = st['gu']!;
        await Future.wait(sec.links.map((link) async {
          final lt = await TranslationService.translateToAll(link.label);
          link.labelHi = lt['hi']!; link.labelGu = lt['gu']!;
        }));
      }));

      // 10. Home Portal Data
      final hp = homepageData.homePortal;
      final hpTasks = await Future.wait([
        TranslationService.translateToAll(hp.heroHeading),
        TranslationService.translateToAll(hp.heroSubtitle),
        TranslationService.translateToAll(hp.heroCta1Text),
        TranslationService.translateToAll(hp.heroCta2Text),
        TranslationService.translateToAll(hp.heroCardTitle),
        TranslationService.translateToAll(hp.heroCardSubtitle),
        TranslationService.translateToAll(hp.collectionsHeading),
        TranslationService.translateToAll(hp.featuredHeading),
        TranslationService.translateToAll(hp.testimonialsHeading),
        TranslationService.translateToAll(hp.wisdomHeading),
        TranslationService.translateToAll(hp.whatsappTitle),
        TranslationService.translateToAll(hp.whatsappSubtitle),
        TranslationService.translateToAll(hp.whatsappBtnText),
      ]);
      hp.heroHeadingHi = (hpTasks[0] as Map<String, String>)['hi']!; hp.heroHeadingGu = (hpTasks[0] as Map<String, String>)['gu']!;
      hp.heroSubtitleHi = (hpTasks[1] as Map<String, String>)['hi']!; hp.heroSubtitleGu = (hpTasks[1] as Map<String, String>)['gu']!;
      hp.heroCta1TextHi = (hpTasks[2] as Map<String, String>)['hi']!; hp.heroCta1TextGu = (hpTasks[2] as Map<String, String>)['gu']!;
      hp.heroCta2TextHi = (hpTasks[3] as Map<String, String>)['hi']!; hp.heroCta2TextGu = (hpTasks[3] as Map<String, String>)['gu']!;
      hp.heroCardTitleHi = (hpTasks[4] as Map<String, String>)['hi']!; hp.heroCardTitleGu = (hpTasks[4] as Map<String, String>)['gu']!;
      hp.heroCardSubtitleHi = (hpTasks[5] as Map<String, String>)['hi']!; hp.heroCardSubtitleGu = (hpTasks[5] as Map<String, String>)['gu']!;
      hp.collectionsHeadingHi = (hpTasks[6] as Map<String, String>)['hi']!; hp.collectionsHeadingGu = (hpTasks[6] as Map<String, String>)['gu']!;
      hp.featuredHeadingHi = (hpTasks[7] as Map<String, String>)['hi']!; hp.featuredHeadingGu = (hpTasks[7] as Map<String, String>)['gu']!;
      hp.testimonialsHeadingHi = (hpTasks[8] as Map<String, String>)['hi']!; hp.testimonialsHeadingGu = (hpTasks[8] as Map<String, String>)['gu']!;
      hp.wisdomHeadingHi = (hpTasks[9] as Map<String, String>)['hi']!; hp.wisdomHeadingGu = (hpTasks[9] as Map<String, String>)['gu']!;
      hp.whatsappTitleHi = (hpTasks[10] as Map<String, String>)['hi']!; hp.whatsappTitleGu = (hpTasks[10] as Map<String, String>)['gu']!;
      hp.whatsappSubtitleHi = (hpTasks[11] as Map<String, String>)['hi']!; hp.whatsappSubtitleGu = (hpTasks[11] as Map<String, String>)['gu']!;
      hp.whatsappBtnTextHi = (hpTasks[12] as Map<String, String>)['hi']!; hp.whatsappBtnTextGu = (hpTasks[12] as Map<String, String>)['gu']!;

      // 11. Teachings Page
      final tp = homepageData.teachingsPage;
      final tpTasks = await Future.wait([
        TranslationService.translateToAll(tp.heroTitle),
        TranslationService.translateToAll(tp.heroSubtitle),
        TranslationService.translateToAll(tp.divinePurposeTitle),
        TranslationService.translateToAll(tp.divinePurposeDesc1),
        TranslationService.translateToAll(tp.divinePurposeDesc2),
      ]);
      tp.heroTitleHi = (tpTasks[0] as Map<String, String>)['hi']!; tp.heroTitleGu = (tpTasks[0] as Map<String, String>)['gu']!;
      tp.heroSubtitleHi = (tpTasks[1] as Map<String, String>)['hi']!; tp.heroSubtitleGu = (tpTasks[1] as Map<String, String>)['gu']!;
      tp.divinePurposeTitleHi = (tpTasks[2] as Map<String, String>)['hi']!; tp.divinePurposeTitleGu = (tpTasks[2] as Map<String, String>)['gu']!;
      tp.divinePurposeDesc1Hi = (tpTasks[3] as Map<String, String>)['hi']!; tp.divinePurposeDesc1Gu = (tpTasks[3] as Map<String, String>)['gu']!;
      tp.divinePurposeDesc2Hi = (tpTasks[4] as Map<String, String>)['hi']!; tp.divinePurposeDesc2Gu = (tpTasks[4] as Map<String, String>)['gu']!;

      await Future.wait(tp.pillars.map((p) async {
        final results = await Future.wait([
          TranslationService.translateToAll(p.title),
          TranslationService.translateToAll(p.subtitle),
          TranslationService.translateToAll(p.description),
        ]);
        p.titleHi = (results[0] as Map<String, String>)['hi']!; p.titleGu = (results[0] as Map<String, String>)['gu']!;
        p.subtitleHi = (results[1] as Map<String, String>)['hi']!; p.subtitleGu = (results[1] as Map<String, String>)['gu']!;
        p.descriptionHi = (results[2] as Map<String, String>)['hi']!; p.descriptionGu = (results[2] as Map<String, String>)['gu']!;
      }));

      // 12. About Dada Page Phases
      await Future.wait(aboutDadaPage.phases.map((ph) async {
        final results = await Future.wait([
          TranslationService.translateToAll(ph.title),
          TranslationService.translateToAll(ph.subtitle),
          TranslationService.translateToAll(ph.content),
        ]);
        ph.titleHi = (results[0] as Map<String, String>)['hi']!; ph.titleGu = (results[0] as Map<String, String>)['gu']!;
        ph.subtitleHi = (results[1] as Map<String, String>)['hi']!; ph.subtitleGu = (results[1] as Map<String, String>)['gu']!;
        ph.contentHi = (results[2] as Map<String, String>)['hi']!; ph.contentGu = (results[2] as Map<String, String>)['gu']!;
      }));

      // 13. Katha Pages Additional Fields (Year/Dates)
      await Future.wait(allKathas.map((kr) async {
        final results = await Future.wait([
          TranslationService.translateToAll(kr.year),
          TranslationService.translateToAll(kr.dates),
        ]);
        final r0 = results[0] as Map<String, String>;
        final r1 = results[1] as Map<String, String>;
        kr.yearHi = r0['hi']!; kr.yearGu = r0['gu']!;
        kr.datesHi = r1['hi']!; kr.datesGu = r1['gu']!;
      }));

      // 14. Final Publish
      await publish();
    } catch (e) {
      AppLogger.error("Translation error", e);
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
}
