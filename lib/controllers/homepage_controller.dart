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
      final nameT = await TranslationService.translateToAll(websiteSettings.name);
      websiteSettings.nameHi = nameT['hi']!; websiteSettings.nameGu = nameT['gu']!;
      
      final catT = await TranslationService.translateToAll(websiteSettings.catalogueHeading);
      websiteSettings.catalogueHeadingHi = catT['hi']!; websiteSettings.catalogueHeadingGu = catT['gu']!;

      final headDonT = await TranslationService.translateToAll(websiteSettings.headerSettings.donateButtonText);
      websiteSettings.headerSettings.donateButtonTextHi = headDonT['hi']!; websiteSettings.headerSettings.donateButtonTextGu = headDonT['gu']!;

      final headAnnT = await TranslationService.translateToAll(websiteSettings.headerSettings.announcementBarText);
      websiteSettings.headerSettings.announcementBarTextHi = headAnnT['hi']!; websiteSettings.headerSettings.announcementBarTextGu = headAnnT['gu']!;

      // 2. Hero Slider
      for (var s in heroSection.slides) {
        final b = await TranslationService.translateToAll(s.badge);
        s.badgeHi = b['hi']!; s.badgeGu = b['gu']!;
        final h = await TranslationService.translateToAll(s.heading);
        s.headingHi = h['hi']!; s.headingGu = h['gu']!;
        final sub = await TranslationService.translateToAll(s.subtitle);
        s.subtitleHi = sub['hi']!; s.subtitleGu = sub['gu']!;
        final d = await TranslationService.translateToAll(s.description);
        s.descriptionHi = d['hi']!; s.descriptionGu = d['gu']!;
      }

      // 3. Upcoming Kathas
      for (var k in upcomingKathas) {
        final n = await TranslationService.translateToAll(k.name);
        k.nameHi = n['hi']!; k.nameGu = n['gu']!;
        final l = await TranslationService.translateToAll(k.location);
        k.locationHi = l['hi']!; k.locationGu = l['gu']!;
        final ds = await TranslationService.translateToAll(k.dateString);
        k.dateStringHi = ds['hi']!; k.dateStringGu = ds['gu']!;
        final desc = await TranslationService.translateToAll(k.description);
        k.descriptionHi = desc['hi']!; k.descriptionGu = desc['gu']!;
        final tim = await TranslationService.translateToAll(k.timing);
        k.timingHi = tim['hi']!; k.timingGu = tim['gu']!;
        final host = await TranslationService.translateToAll(k.hosting);
        k.hostingHi = host['hi']!; k.hostingGu = host['gu']!;
      }

      // 4. About Section
      final abT = await TranslationService.translateToAll(aboutSection.title);
      aboutSection.titleHi = abT['hi']!; aboutSection.titleGu = abT['gu']!;
      final abTag = await TranslationService.translateToAll(aboutSection.tagline);
      aboutSection.taglineHi = abTag['hi']!; aboutSection.taglineGu = abTag['gu']!;
      final abDesc = await TranslationService.translateToAll(aboutSection.description);
      aboutSection.descriptionHi = abDesc['hi']!; aboutSection.descriptionGu = abDesc['gu']!;
      aboutSection.paragraphsHi = await TranslationService.translateBatch(aboutSection.paragraphs, 'hi');
      aboutSection.paragraphsGu = await TranslationService.translateBatch(aboutSection.paragraphs, 'gu');

      // 5. Homepage Data (Teachings & Testimonials in model)
      for (var t in homepageData.teachings) {
        final tT = await TranslationService.translateToAll(t.title);
        t.titleHi = tT['hi']!; t.titleGu = tT['gu']!;
        final tS = await TranslationService.translateToAll(t.subtitle);
        t.subtitleHi = tS['hi']!; t.subtitleGu = tS['gu']!;
        final tD = await TranslationService.translateToAll(t.description);
        t.descriptionHi = tD['hi']!; t.descriptionGu = tD['gu']!;
      }
      for (var te in homepageData.testimonials) {
        final teF = await TranslationService.translateToAll(te.feedback);
        te.feedbackHi = teF['hi']!; te.feedbackGu = teF['gu']!;
        final teN = await TranslationService.translateToAll(te.name);
        te.nameHi = teN['hi']!; te.nameGu = teN['gu']!;
      }
      for (var ni in homepageData.news) {
        final niT = await TranslationService.translateToAll(ni.title);
        ni.titleHi = niT['hi']!; ni.titleGu = niT['gu']!;
        final niC = await TranslationService.translateToAll(ni.category);
        ni.categoryHi = niC['hi']!; ni.categoryGu = niC['gu']!;
      }

      // 6. Featured Quote & Ram Katha
      final qT = await TranslationService.translateToAll(homepageData.featuredQuote.quote);
      homepageData.featuredQuote.quoteHi = qT['hi']!; homepageData.featuredQuote.quoteGu = qT['gu']!;
      final qA = await TranslationService.translateToAll(homepageData.featuredQuote.author);
      homepageData.featuredQuote.authorHi = qA['hi']!; homepageData.featuredQuote.authorGu = qA['gu']!;

      final rkT = await TranslationService.translateToAll(ramKatha.description1);
      ramKatha.description1Hi = rkT['hi']!; ramKatha.description1Gu = rkT['gu']!;
      final rkD2 = await TranslationService.translateToAll(ramKatha.description2);
      ramKatha.description2Hi = rkD2['hi']!; ramKatha.description2Gu = rkD2['gu']!;

      // 7. Full Katha List
      for (var kr in allKathas) {
        final krT = await TranslationService.translateToAll(kr.topic);
        kr.topicHi = krT['hi']!; kr.topicGu = krT['gu']!;
        final krL = await TranslationService.translateToAll(kr.location);
        kr.locationHi = krL['hi']!; kr.locationGu = krL['gu']!;
        final krD = await TranslationService.translateToAll(kr.description);
        kr.descriptionHi = krD['hi']!; kr.descriptionGu = krD['gu']!;
      }

      // 8. Gallery
      for (var ps in photoGalleryData.sections) {
        final psH = await TranslationService.translateToAll(ps.heading);
        ps.headingHi = psH['hi']!; ps.headingGu = psH['gu']!;
      }
      final pgT = await TranslationService.translateToAll(photoGalleryData.title);
      photoGalleryData.titleHi = pgT['hi']!; photoGalleryData.titleGu = pgT['gu']!;

      for (var vc in videoGalleryData.categories) {
        final vcT = await TranslationService.translateToAll(vc.categoryTitle);
        vc.categoryTitleHi = vcT['hi']!; vc.categoryTitleGu = vcT['gu']!;
        for (var vge in vc.videos) {
          final vgeT = await TranslationService.translateToAll(vge.title);
          vge.titleHi = vgeT['hi']!; vge.titleGu = vgeT['gu']!;
        }
      }

      // 9. Stotra & Contact & Footer
      final stST = await TranslationService.translateToAll(stotraSection.pageTitle);
      stotraSection.pageTitleHi = stST['hi']!; stotraSection.pageTitleGu = stST['gu']!;
      for (var si in stotraSection.items) {
        final siT = await TranslationService.translateToAll(si.title);
        si.titleHi = siT['hi']!; si.titleGu = siT['gu']!;
      }

      final conA = await TranslationService.translateToAll(contactPageData.address);
      contactPageData.addressHi = conA['hi']!; contactPageData.addressGu = conA['gu']!;

      final fooD = await TranslationService.translateToAll(footer.description);
      footer.descriptionHi = fooD['hi']!; footer.descriptionGu = fooD['gu']!;

      // 10. Katha Pages (Bhagvat, Devi, Shiv)
      final kPages = [bhagvatKathaPage, deviKathaPage, shivKathaPage];
      for (var kp in kPages) {
        final b = await TranslationService.translateToAll(kp.heroBadge); kp.heroBadgeHi = b['hi']!; kp.heroBadgeGu = b['gu']!;
        final t = await TranslationService.translateToAll(kp.heroTitle); kp.heroTitleHi = t['hi']!; kp.heroTitleGu = t['gu']!;
        final d1 = await TranslationService.translateToAll(kp.heroDesc1); kp.heroDesc1Hi = d1['hi']!; kp.heroDesc1Gu = d1['gu']!;
        final d2 = await TranslationService.translateToAll(kp.heroDesc2); kp.heroDesc2Hi = d2['hi']!; kp.heroDesc2Gu = d2['gu']!;
        final bio = await TranslationService.translateToAll(kp.bioText); kp.bioTextHi = bio['hi']!; kp.bioTextGu = bio['gu']!;
        final q = await TranslationService.translateToAll(kp.quoteText); kp.quoteTextHi = q['hi']!; kp.quoteTextGu = q['gu']!;
        final qa = await TranslationService.translateToAll(kp.quoteAuthor); kp.quoteAuthorHi = qa['hi']!; kp.quoteAuthorGu = qa['gu']!;
        final h1t = await TranslationService.translateToAll(kp.highlight1Title); kp.highlight1TitleHi = h1t['hi']!; kp.highlight1TitleGu = h1t['gu']!;
        final h1d = await TranslationService.translateToAll(kp.highlight1Desc); kp.highlight1DescHi = h1d['hi']!; kp.highlight1DescGu = h1d['gu']!;
        final h2t = await TranslationService.translateToAll(kp.highlight2Title); kp.highlight2TitleHi = h2t['hi']!; kp.highlight2TitleGu = h2t['gu']!;
        final h2d = await TranslationService.translateToAll(kp.highlight2Desc); kp.highlight2DescHi = h2d['hi']!; kp.highlight2DescGu = h2d['gu']!;
        final h3t = await TranslationService.translateToAll(kp.highlight3Title); kp.highlight3TitleHi = h3t['hi']!; kp.highlight3TitleGu = h3t['gu']!;
        final h3d = await TranslationService.translateToAll(kp.highlight3Desc); kp.highlight3DescHi = h3d['hi']!; kp.highlight3DescGu = h3d['gu']!;
        final ct = await TranslationService.translateToAll(kp.ctaTitle); kp.ctaTitleHi = ct['hi']!; kp.ctaTitleGu = ct['gu']!;
        final cs = await TranslationService.translateToAll(kp.ctaSubtitle); kp.ctaSubtitleHi = cs['hi']!; kp.ctaSubtitleGu = cs['gu']!;
        final cb = await TranslationService.translateToAll(kp.ctaButtonText); kp.ctaButtonTextHi = cb['hi']!; kp.ctaButtonTextGu = cb['gu']!;
      }

      await publish();
    } catch (e) {
      AppLogger.error("Translation error", e);
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }
}
