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

  HomePageController() {
    _initCMSStream();
    _initPhotosStream();
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

    // One-time load for inquiries remains
    _firestore.collection('inquiries').get().then((inqSnap) {
      inquiries = inqSnap.docs.map((doc) => ContactInquiry.fromMap(doc.id, doc.data())).toList();
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
        ]);
        final r0 = results[0] as Map<String, String>;
        final r1 = results[1] as Map<String, String>;
        final r2 = results[2] as Map<String, String>;
        final r3 = results[3] as Map<String, String>;
        
        s.badgeHi = r0['hi']!; s.badgeGu = r0['gu']!;
        s.headingHi = r1['hi']!; s.headingGu = r1['gu']!;
        s.subtitleHi = r2['hi']!; s.subtitleGu = r2['gu']!;
        s.descriptionHi = r3['hi']!; s.descriptionGu = r3['gu']!;
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
          ]);
          final r0 = results[0] as Map<String, String>;
          final r1 = results[1] as Map<String, String>;
          ni.titleHi = r0['hi']!; ni.titleGu = r0['gu']!;
          ni.categoryHi = r1['hi']!; ni.categoryGu = r1['gu']!;
        }),
      ]);

      // 6. Featured Quote & Ram Katha
      final qTasks = await Future.wait([
        TranslationService.translateToAll(homepageData.featuredQuote.quote),
        TranslationService.translateToAll(homepageData.featuredQuote.author),
        TranslationService.translateToAll(ramKatha.description1),
        TranslationService.translateToAll(ramKatha.description2),
      ]);
      final q0 = qTasks[0] as Map<String, String>;
      final q1 = qTasks[1] as Map<String, String>;
      final q2 = qTasks[2] as Map<String, String>;
      final q3 = qTasks[3] as Map<String, String>;

      homepageData.featuredQuote.quoteHi = q0['hi']!; homepageData.featuredQuote.quoteGu = q0['gu']!;
      homepageData.featuredQuote.authorHi = q1['hi']!; homepageData.featuredQuote.authorGu = q1['gu']!;
      ramKatha.description1Hi = q2['hi']!; ramKatha.description1Gu = q2['gu']!;
      ramKatha.description2Hi = q3['hi']!; ramKatha.description2Gu = q3['gu']!;

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
      ]);
      final m0 = miscTasks[0] as Map<String, String>;
      final m1 = miscTasks[1] as Map<String, String>;
      final m2 = miscTasks[2] as Map<String, String>;

      stotraSection.pageTitleHi = m0['hi']!; stotraSection.pageTitleGu = m0['gu']!;
      contactPageData.addressHi = m1['hi']!; contactPageData.addressGu = m1['gu']!;
      footer.descriptionHi = m2['hi']!; footer.descriptionGu = m2['gu']!;
      
      await Future.wait(stotraSection.items.map((si) async {
        final sit = await TranslationService.translateToAll(si.title);
        si.titleHi = sit['hi']!; si.titleGu = sit['gu']!;
      }));

      // 10. Katha Pages
      final kPages = [bhagvatKathaPage, deviKathaPage, shivKathaPage];
      await Future.wait(kPages.map((kp) async {
        final results = await Future.wait([
          TranslationService.translateToAll(kp.heroBadge),
          TranslationService.translateToAll(kp.heroTitle),
          TranslationService.translateToAll(kp.heroDesc1),
          TranslationService.translateToAll(kp.heroDesc2),
          TranslationService.translateToAll(kp.bioText),
          TranslationService.translateToAll(kp.quoteText),
          TranslationService.translateToAll(kp.quoteAuthor),
          TranslationService.translateToAll(kp.highlight1Title),
          TranslationService.translateToAll(kp.highlight1Desc),
          TranslationService.translateToAll(kp.highlight2Title),
          TranslationService.translateToAll(kp.highlight2Desc),
          TranslationService.translateToAll(kp.highlight3Title),
          TranslationService.translateToAll(kp.highlight3Desc),
          TranslationService.translateToAll(kp.ctaTitle),
          TranslationService.translateToAll(kp.ctaSubtitle),
          TranslationService.translateToAll(kp.ctaButtonText),
        ]);
        final r0 = results[0] as Map<String, String>;
        final r1 = results[1] as Map<String, String>;
        final r2 = results[2] as Map<String, String>;
        final r3 = results[3] as Map<String, String>;
        final r4 = results[4] as Map<String, String>;
        final r5 = results[5] as Map<String, String>;
        final r6 = results[6] as Map<String, String>;
        final r7 = results[7] as Map<String, String>;
        final r8 = results[8] as Map<String, String>;
        final r9 = results[9] as Map<String, String>;
        final r10 = results[10] as Map<String, String>;
        final r11 = results[11] as Map<String, String>;
        final r12 = results[12] as Map<String, String>;
        final r13 = results[13] as Map<String, String>;
        final r14 = results[14] as Map<String, String>;
        final r15 = results[15] as Map<String, String>;

        kp.heroBadgeHi = r0['hi']!; kp.heroBadgeGu = r0['gu']!;
        kp.heroTitleHi = r1['hi']!; kp.heroTitleGu = r1['gu']!;
        kp.heroDesc1Hi = r2['hi']!; kp.heroDesc1Gu = r2['gu']!;
        kp.heroDesc2Hi = r3['hi']!; kp.heroDesc2Gu = r3['gu']!;
        kp.bioTextHi = r4['hi']!; kp.bioTextGu = r4['gu']!;
        kp.quoteTextHi = r5['hi']!; kp.quoteTextGu = r5['gu']!;
        kp.quoteAuthorHi = r6['hi']!; kp.quoteAuthorGu = r6['gu']!;
        kp.highlight1TitleHi = r7['hi']!; kp.highlight1TitleGu = r7['gu']!;
        kp.highlight1DescHi = r8['hi']!; kp.highlight1DescGu = r8['gu']!;
        kp.highlight2TitleHi = r9['hi']!; kp.highlight2TitleGu = r9['gu']!;
        kp.highlight2DescHi = r10['hi']!; kp.highlight2DescGu = r10['gu']!;
        kp.highlight3TitleHi = r11['hi']!; kp.highlight3TitleGu = r11['gu']!;
        kp.highlight3DescHi = r12['hi']!; kp.highlight3DescGu = r12['gu']!;
        kp.ctaTitleHi = r13['hi']!; kp.ctaTitleGu = r13['gu']!;
        kp.ctaSubtitleHi = r14['hi']!; kp.ctaSubtitleGu = r14['gu']!;
        kp.ctaButtonTextHi = r15['hi']!; kp.ctaButtonTextGu = r15['gu']!;
      }));

      await publish();
    } catch (e) {
      AppLogger.error("Translation error", e);
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
}
