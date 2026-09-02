import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/notification_model.dart';
import '../models/coupon_model.dart';
import '../models/review_model.dart';
import '../models/homepage_model.dart';
import '../models/profile_model.dart';
import '../models/store_config_model.dart';

abstract class TranslationProvider {
  Future<String> translate(String text, String targetLang);
}

class MyMemoryProvider implements TranslationProvider {
  @override
  Future<String> translate(String text, String targetLang) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|$targetLang'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String translated = data['responseData']['translatedText'] ?? text;
        if (translated.toUpperCase().contains("QUERY LENGTH LIMIT EXCEEDED")) return text;
        return translated;
      }
    } catch (_) {}
    return text;
  }
}

class GoogleTranslationProvider implements TranslationProvider {
  final String apiKey;
  GoogleTranslationProvider(this.apiKey);

  @override
  Future<String> translate(String text, String targetLang) async {
    if (apiKey.isEmpty) return MyMemoryProvider().translate(text, targetLang);
    
    try {
      final response = await http.post(
        Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey'),
        body: jsonEncode({
          'q': text,
          'target': targetLang,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'] ?? text;
      }
    } catch (_) {}
    return MyMemoryProvider().translate(text, targetLang);
  }
}

class TranslationService {
  static TranslationProvider _provider = MyMemoryProvider();
  static final Map<String, String> _cache = {};
  
  // Set your Google Cloud Translation API Key here
  static String? googleApiKey;

  static void init({String? apiKey}) {
    googleApiKey = apiKey;
    if (googleApiKey != null && googleApiKey!.isNotEmpty) {
      _provider = GoogleTranslationProvider(googleApiKey!);
    }
  }

  // --- Translation Core ---

  static Future<Map<String, String>> translateToAll(String text) async {
    if (text.trim().isEmpty) return {'hi': '', 'gu': ''};
    final hi = await translate(text, 'hi');
    final gu = await translate(text, 'gu');
    return {'hi': hi, 'gu': gu};
  }

  static Future<String> translate(String text, String targetLang) async {
    if (text.trim().isEmpty) return '';
    final cacheKey = '${targetLang}_$text';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    String result;
    if (text.length <= 400) {
      result = await _provider.translate(text, targetLang);
    } else {
      List<String> chunks = _splitText(text, 400);
      List<String> translatedChunks = [];
      for (var chunk in chunks) {
        translatedChunks.add(await _provider.translate(chunk, targetLang));
      }
      result = translatedChunks.join(' ');
    }

    _cache[cacheKey] = result;
    return result;
  }

  static List<String> _splitText(String text, int maxSize) {
    List<String> chunks = [];
    int start = 0;
    while (start < text.length) {
      int end = start + maxSize;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }
      int lastSpace = text.lastIndexOf(' ', end);
      if (lastSpace > start) end = lastSpace;
      chunks.add(text.substring(start, end));
      start = end + 1;
    }
    return chunks;
  }

  static Future<List<String>> translateBatch(List<String> texts, String targetLang) async {
    if (texts.isEmpty) return [];
    return Future.wait(texts.map((t) => translate(t, targetLang)));
  }

  // --- Progress Tracking ---

  static final ValueNotifier<TranslationProgress> progress = ValueNotifier(TranslationProgress());

  static void _updateProgress({
    String? section,
    int? completed,
    int? total,
    int? failed,
    String? status,
  }) {
    progress.value = progress.value.copyWith(
      currentSection: section,
      completedRecords: completed,
      totalRecords: total,
      failedRecords: failed,
      status: status,
    );
  }

  // --- Collection Translation Handlers ---

  static Future<void> translateAll(FirebaseFirestore firestore) async {
    _updateProgress(status: 'Starting Deep Translation...', completed: 0, total: 0, failed: 0);
    
    // 1. CMS Homepage Document
    await _translateHomepageCMS(firestore);

    // 2. Profile Document
    await _translateProfileCMS(firestore);

    // 3. Store Config
    await _translateStoreConfig(firestore);

    // 4. Products Collection
    await _translateCollection(
      firestore, 'products', 
      (doc) => ProductModel.fromFirestore(doc),
      (model) => translateProduct(model as ProductModel),
      (model) => (model as ProductModel).toFirestore()
    );

    // 5. Categories Collection
    await _translateCollection(
      firestore, 'categories',
      (doc) => CategoryModel.fromFirestore(doc),
      (model) => translateCategory(model as CategoryModel),
      (model) => (model as CategoryModel).toFirestore()
    );

    // 6. Notifications Collection
    await _translateCollection(
      firestore, 'notifications',
      (doc) => NotificationModel.fromFirestore(doc),
      (model) => translateNotification(model as NotificationModel),
      (model) => (model as NotificationModel).toFirestore()
    );

    // 7. Coupons Collection
    await _translateCollection(
      firestore, 'coupons',
      (doc) => CouponModel.fromFirestore(doc),
      (model) => translateCoupon(model as CouponModel),
      (model) => (model as CouponModel).toFirestore()
    );

    // 8. Reviews Collection
    await _translateCollection(
      firestore, 'reviews',
      (doc) => ReviewModel.fromFirestore(doc),
      (model) => translateReview(model as ReviewModel),
      (model) => (model as ReviewModel).toFirestore()
    );

    _updateProgress(status: 'Deep Translation Complete!', section: 'Done');
  }

  static Future<void> _translateStoreConfig(FirebaseFirestore firestore) async {
    _updateProgress(section: 'Store Config', status: 'Translating Store Settings...');
    try {
      final docRef = firestore.collection('storeConfig').doc('settings');
      final doc = await docRef.get();
      if (!doc.exists) return;
      
      final translated = await translateStoreConfig(StoreConfigModel.fromFirestore(doc));
      await docRef.update(translated.toFirestore());
      _updateProgress(completed: progress.value.completedRecords + 1);
    } catch (e) {
      _updateProgress(failed: progress.value.failedRecords + 1);
    }
  }

  static Future<void> _translateHomepageCMS(FirebaseFirestore firestore) async {
    _updateProgress(section: 'CMS Homepage', status: 'Translating Homepage...');
    try {
      final docRef = firestore.collection('cms').doc('homepage');
      final doc = await docRef.get();
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final Map<String, dynamic> updatedData = {};

      if (data['websiteSettings'] != null) {
        updatedData['websiteSettings'] = (await translateWebsiteSettings(WebsiteSettings.fromMap(data['websiteSettings']))).toMap();
      }
      if (data['heroSection'] != null) {
        updatedData['heroSection'] = (await translateHeroSection(HeroSection.fromMap(data['heroSection']))).toMap();
      }
      if (data['upcomingKathas'] != null) {
        updatedData['upcomingKathas'] = await Future.wait((data['upcomingKathas'] as List).map((e) async => (await translateUpcomingKatha(UpcomingKatha.fromMap(e))).toMap()));
      }
      if (data['aboutSection'] != null) {
        updatedData['aboutSection'] = (await translateAboutSection(AboutSection.fromMap(data['aboutSection']))).toMap();
      }
      if (data['dailySuvichar'] != null) {
        updatedData['dailySuvichar'] = (await translateDailySuvichar(DailySuvichar.fromMap(data['dailySuvichar']))).toMap();
      }
      if (data['videos'] != null) {
        updatedData['videos'] = await Future.wait((data['videos'] as List).map((e) async => (await translateVideoItem(VideoItem.fromMap(e))).toMap()));
      }
      if (data['ramKatha'] != null) {
        updatedData['ramKatha'] = (await translateRamKathaSection(RamKathaSection.fromMap(data['ramKatha']))).toMap();
      }
      if (data['stotraSection'] != null) {
        updatedData['stotraSection'] = (await translateStotraSection(StotraSection.fromMap(data['stotraSection']))).toMap();
      }
      if (data['footer'] != null) {
        updatedData['footer'] = (await translateFooterData(FooterData.fromMap(data['footer']))).toMap();
      }
      if (data['bhagvatKathaPage'] != null) {
        updatedData['bhagvatKathaPage'] = (await translateKathaAboutPageData(KathaAboutPageData.fromMap(data['bhagvatKathaPage']))).toMap();
      }
      if (data['deviKathaPage'] != null) {
        updatedData['deviKathaPage'] = (await translateKathaAboutPageData(KathaAboutPageData.fromMap(data['deviKathaPage']))).toMap();
      }
      if (data['shivKathaPage'] != null) {
        updatedData['shivKathaPage'] = (await translateKathaAboutPageData(KathaAboutPageData.fromMap(data['shivKathaPage']))).toMap();
      }
      if (data['aboutDadaPage'] != null) {
        updatedData['aboutDadaPage'] = (await translateAboutDadaPageData(AboutDadaPageData.fromMap(data['aboutDadaPage']))).toMap();
      }
      if (data['homepageData'] != null) {
        updatedData['homepageData'] = (await translateHomepageData(HomepageData.fromMap(data['homepageData']))).toMap();
      }
      if (data['allKathas'] != null) {
        updatedData['allKathas'] = await Future.wait((data['allKathas'] as List).map((e) async => (await translateKathaRecord(KathaRecord.fromMap(e))).toMap()));
      }
      if (data['contactPageData'] != null) {
        updatedData['contactPageData'] = (await translateContactPageData(ContactPageData.fromMap(data['contactPageData']))).toMap();
      }
      if (data['videoGalleryData'] != null) {
        updatedData['videoGalleryData'] = (await translateVideoGalleryPageData(VideoGalleryPageData.fromMap(data['videoGalleryData']))).toMap();
      }
      if (data['photoGalleryData'] != null) {
        updatedData['photoGalleryData'] = (await translatePhotoGalleryPageData(PhotoGalleryPageData.fromMap(data['photoGalleryData']))).toMap();
      }

      await docRef.update(updatedData);
      _updateProgress(completed: progress.value.completedRecords + 1);
    } catch (e) {
      _updateProgress(failed: progress.value.failedRecords + 1);
    }
  }

  static Future<void> _translateProfileCMS(FirebaseFirestore firestore) async {
    _updateProgress(section: 'Profile CMS', status: 'Translating Profile Data...');
    try {
      final docRef = firestore.collection('profile').doc('aboutPage');
      final doc = await docRef.get();
      if (!doc.exists) return;
      
      final translated = await translateProfileData(ProfileData.fromMap(doc.data()!));
      await docRef.update(translated.toMap());
      _updateProgress(completed: progress.value.completedRecords + 1);
    } catch (e) {
      _updateProgress(failed: progress.value.failedRecords + 1);
    }
  }

  static Future<void> _translateCollection(
    FirebaseFirestore firestore, 
    String collectionPath,
    dynamic Function(DocumentSnapshot) fromFirestore,
    Future<dynamic> Function(dynamic) translator,
    Map<String, dynamic> Function(dynamic) toFirestore,
  ) async {
    _updateProgress(section: collectionPath, status: 'Fetching $collectionPath...');
    final snapshot = await firestore.collection(collectionPath).get();
    final docs = snapshot.docs;
    _updateProgress(total: docs.length, completed: 0, failed: 0);

    const int batchSize = 10;
    for (int i = 0; i < docs.length; i += batchSize) {
      final end = (i + batchSize < docs.length) ? i + batchSize : docs.length;
      final batchDocs = docs.sublist(i, end);

      await Future.wait(batchDocs.map((doc) async {
        try {
          final model = fromFirestore(doc);
          final translatedModel = await translator(model);
          await doc.reference.update(toFirestore(translatedModel));
          _updateProgress(completed: progress.value.completedRecords + 1);
        } catch (e) {
          _updateProgress(failed: progress.value.failedRecords + 1);
        }
      }));
    }
  }

  // --- Model Specific Translations (Refined) ---

  static Future<ProductModel> translateProduct(ProductModel product) async {
    final name = await translateToAll(product.name);
    final desc = await translateToAll(product.description);
    final summary = await translateToAll(product.shortSummary);
    final badge = await translateToAll(product.consecrationBadge);
    
    final hiHighlights = await translateBatch(product.highlights, 'hi');
    final guHighlights = await translateBatch(product.highlights, 'gu');
    
    final hiFinishes = await translateBatch(product.finishes, 'hi');
    final guFinishes = await translateBatch(product.finishes, 'gu');
    
    final hiSizes = await translateBatch(product.sizes, 'hi');
    final guSizes = await translateBatch(product.sizes, 'gu');

    return product.copyWith(
      nameHi: name['hi'], nameGu: name['gu'],
      descriptionHi: desc['hi'], descriptionGu: desc['gu'],
      shortSummaryHi: summary['hi'], shortSummaryGu: summary['gu'],
      consecrationBadgeHi: badge['hi'], consecrationBadgeGu: badge['gu'],
      highlightsHi: hiHighlights, highlightsGu: guHighlights,
      finishesHi: hiFinishes, finishesGu: guFinishes,
      sizesHi: hiSizes, sizesGu: guSizes,
    );
  }

  static Future<CategoryModel> translateCategory(CategoryModel category) async {
    final name = await translateToAll(category.name);
    final desc = await translateToAll(category.description);
    return category.copyWith(
      nameHi: name['hi'], nameGu: name['gu'],
      descriptionHi: desc['hi'], descriptionGu: desc['gu'],
    );
  }

  static Future<NotificationModel> translateNotification(NotificationModel n) async {
    final title = await translateToAll(n.title);
    final message = await translateToAll(n.message);
    return NotificationModel(
      id: n.id,
      title: n.title, titleHi: title['hi']!, titleGu: title['gu']!,
      message: n.message, messageHi: message['hi']!, messageGu: message['gu']!,
      type: n.type, isRead: n.isRead, createdAt: n.createdAt,
    );
  }

  static Future<CouponModel> translateCoupon(CouponModel c) async {
    final terms = await translateToAll(c.terms);
    return CouponModel(
      id: c.id, code: c.code, discountType: c.discountType,
      discountValue: c.discountValue, minOrderValue: c.minOrderValue,
      usageLimitPerUser: c.usageLimitPerUser,
      terms: c.terms, termsHi: terms['hi']!, termsGu: terms['gu']!,
      isActive: c.isActive, createdAt: c.createdAt,
    );
  }

  static Future<WebsiteSettings> translateWebsiteSettings(WebsiteSettings s) async {
    final name = await translateToAll(s.name);
    final catHead = await translateToAll(s.catalogueHeading);
    final catSub = await translateToAll(s.catalogueSubtitle);
    
    final donateBtn = await translateToAll(s.headerSettings.donateButtonText);
    final announce = await translateToAll(s.headerSettings.announcementBarText);
    
    s.nameHi = name['hi']!; s.nameGu = name['gu']!;
    s.catalogueHeadingHi = catHead['hi']!; s.catalogueHeadingGu = catHead['gu']!;
    s.catalogueSubtitleHi = catSub['hi']!; s.catalogueSubtitleGu = catSub['gu']!;
    
    s.headerSettings.donateButtonTextHi = donateBtn['hi']!; s.headerSettings.donateButtonTextGu = donateBtn['gu']!;
    s.headerSettings.announcementBarTextHi = announce['hi']!; s.headerSettings.announcementBarTextGu = announce['gu']!;
    
    return s;
  }

  static Future<HeroSection> translateHeroSection(HeroSection section) async {
    await Future.wait(section.slides.map((s) async {
      final results = await Future.wait([
        translateToAll(s.badge), translateToAll(s.heading),
        translateToAll(s.subtitle), translateToAll(s.description),
        translateToAll(s.primaryCtaText), translateToAll(s.secondaryCtaText),
      ]);
      s.badgeHi = results[0]['hi']!; s.badgeGu = results[0]['gu']!;
      s.headingHi = results[1]['hi']!; s.headingGu = results[1]['gu']!;
      s.subtitleHi = results[2]['hi']!; s.subtitleGu = results[2]['gu']!;
      s.descriptionHi = results[3]['hi']!; s.descriptionGu = results[3]['gu']!;
      s.primaryCtaTextHi = results[4]['hi']!; s.primaryCtaTextGu = results[4]['gu']!;
      s.secondaryCtaTextHi = results[5]['hi']!; s.secondaryCtaTextGu = results[5]['gu']!;
    }));
    return section;
  }

  static Future<UpcomingKatha> translateUpcomingKatha(UpcomingKatha k) async {
    final results = await Future.wait([
      translateToAll(k.name), translateToAll(k.location),
      translateToAll(k.dateString), translateToAll(k.description),
      translateToAll(k.timing), translateToAll(k.hosting),
    ]);
    k.nameHi = results[0]['hi']!; k.nameGu = results[0]['gu']!;
    k.locationHi = results[1]['hi']!; k.locationGu = results[1]['gu']!;
    k.dateStringHi = results[2]['hi']!; k.dateStringGu = results[2]['gu']!;
    k.descriptionHi = results[3]['hi']!; k.descriptionGu = results[3]['gu']!;
    k.timingHi = results[4]['hi']!; k.timingGu = results[4]['gu']!;
    k.hostingHi = results[5]['hi']!; k.hostingGu = results[5]['gu']!;
    return k;
  }

  static Future<AboutSection> translateAboutSection(AboutSection s) async {
    final res = await Future.wait([
      translateToAll(s.title), translateToAll(s.tagline), translateToAll(s.description),
    ]);
    s.titleHi = res[0]['hi']!; s.titleGu = res[0]['gu']!;
    s.taglineHi = res[1]['hi']!; s.taglineGu = res[1]['gu']!;
    s.descriptionHi = res[2]['hi']!; s.descriptionGu = res[2]['gu']!;
    s.paragraphsHi = await translateBatch(s.paragraphs, 'hi');
    s.paragraphsGu = await translateBatch(s.paragraphs, 'gu');
    return s;
  }

  static Future<DailySuvichar> translateDailySuvichar(DailySuvichar s) async {
    final res = await translateToAll(s.date);
    s.dateHi = res['hi']!; s.dateGu = res['gu']!;
    return s;
  }

  static Future<VideoItem> translateVideoItem(VideoItem v) async {
    final res = await translateToAll(v.title);
    v.titleHi = res['hi']!; v.titleGu = res['gu']!;
    return v;
  }

  static Future<RamKathaSection> translateRamKathaSection(RamKathaSection s) async {
    final res = await Future.wait([translateToAll(s.description1), translateToAll(s.description2)]);
    s.description1Hi = res[0]['hi']!; s.description1Gu = res[0]['gu']!;
    s.description2Hi = res[1]['hi']!; s.description2Gu = res[1]['gu']!;
    return s;
  }

  static Future<StotraSection> translateStotraSection(StotraSection s) async {
    final t = await translateToAll(s.pageTitle);
    s.pageTitleHi = t['hi']!; s.pageTitleGu = t['gu']!;
    await Future.wait(s.items.map((i) async {
      final res = await translateToAll(i.title);
      i.titleHi = res['hi']!; i.titleGu = res['gu']!;
    }));
    return s;
  }

  static Future<FooterData> translateFooterData(FooterData f) async {
    final res = await Future.wait([
      translateToAll(f.description), translateToAll(f.copyright),
      translateToAll(f.privacyLabel), translateToAll(f.termsLabel), translateToAll(f.cookieLabel),
    ]);
    f.descriptionHi = res[0]['hi']!; f.descriptionGu = res[0]['gu']!;
    f.copyrightHi = res[1]['hi']!; f.copyrightGu = res[1]['gu']!;
    f.privacyLabelHi = res[2]['hi']!; f.privacyLabelGu = res[2]['gu']!;
    f.termsLabelHi = res[3]['hi']!; f.termsLabelGu = res[3]['gu']!;
    f.cookieLabelHi = res[4]['hi']!; f.cookieLabelGu = res[4]['gu']!;
    
    await Future.wait(f.linkSections.map((sec) async {
      final st = await translateToAll(sec.title);
      sec.titleHi = st['hi']!; sec.titleGu = st['gu']!;
      await Future.wait(sec.links.map((link) async {
        final lt = await translateToAll(link.label);
        link.labelHi = lt['hi']!; link.labelGu = lt['gu']!;
      }));
    }));
    return f;
  }

  static Future<KathaAboutPageData> translateKathaAboutPageData(KathaAboutPageData d) async {
    final res = await Future.wait([
      translateToAll(d.heroBadge), translateToAll(d.heroTitle),
      translateToAll(d.heroDesc1), translateToAll(d.heroDesc2),
      translateToAll(d.bioText), translateToAll(d.quoteText), translateToAll(d.quoteAuthor),
      translateToAll(d.highlight1Title), translateToAll(d.highlight1Desc),
      translateToAll(d.highlight2Title), translateToAll(d.highlight2Desc),
      translateToAll(d.highlight3Title), translateToAll(d.highlight3Desc),
      translateToAll(d.ctaTitle), translateToAll(d.ctaSubtitle), translateToAll(d.ctaButtonText),
    ]);
    d.heroBadgeHi = res[0]['hi']!; d.heroBadgeGu = res[0]['gu']!;
    d.heroTitleHi = res[1]['hi']!; d.heroTitleGu = res[1]['gu']!;
    d.heroDesc1Hi = res[2]['hi']!; d.heroDesc1Gu = res[2]['gu']!;
    d.heroDesc2Hi = res[3]['hi']!; d.heroDesc2Gu = res[3]['gu']!;
    d.bioTextHi = res[4]['hi']!; d.bioTextGu = res[4]['gu']!;
    d.quoteTextHi = res[5]['hi']!; d.quoteTextGu = res[5]['gu']!;
    d.quoteAuthorHi = res[6]['hi']!; d.quoteAuthorGu = res[6]['gu']!;
    d.highlight1TitleHi = res[7]['hi']!; d.highlight1TitleGu = res[7]['gu']!;
    d.highlight1DescHi = res[8]['hi']!; d.highlight1DescGu = res[8]['gu']!;
    d.highlight2TitleHi = res[9]['hi']!; d.highlight2TitleGu = res[9]['gu']!;
    d.highlight2DescHi = res[10]['hi']!; d.highlight2DescGu = res[10]['gu']!;
    d.highlight3TitleHi = res[11]['hi']!; d.highlight3TitleGu = res[11]['gu']!;
    d.highlight3DescHi = res[12]['hi']!; d.highlight3DescGu = res[12]['gu']!;
    d.ctaTitleHi = res[13]['hi']!; d.ctaTitleGu = res[13]['gu']!;
    d.ctaSubtitleHi = res[14]['hi']!; d.ctaSubtitleGu = res[14]['gu']!;
    d.ctaButtonTextHi = res[15]['hi']!; d.ctaButtonTextGu = res[15]['gu']!;
    return d;
  }

  static Future<AboutDadaPageData> translateAboutDadaPageData(AboutDadaPageData d) async {
    final t = await Future.wait([translateToAll(d.heroTitle), translateToAll(d.heroSubtitle)]);
    d.heroTitleHi = t[0]['hi']!; d.heroTitleGu = t[0]['gu']!;
    d.heroSubtitleHi = t[1]['hi']!; d.heroSubtitleGu = t[1]['gu']!;
    await Future.wait(d.phases.map((ph) async {
      final res = await Future.wait([translateToAll(ph.title), translateToAll(ph.subtitle), translateToAll(ph.content)]);
      ph.titleHi = res[0]['hi']!; ph.titleGu = res[0]['gu']!;
      ph.subtitleHi = res[1]['hi']!; ph.subtitleGu = res[1]['gu']!;
      ph.contentHi = res[2]['hi']!; ph.contentGu = res[2]['gu']!;
    }));
    return d;
  }

  static Future<HomepageData> translateHomepageData(HomepageData d) async {
    final q = await Future.wait([translateToAll(d.featuredQuote.quote), translateToAll(d.featuredQuote.author)]);
    d.featuredQuote.quoteHi = q[0]['hi']!; d.featuredQuote.quoteGu = q[0]['gu']!;
    d.featuredQuote.authorHi = q[1]['hi']!; d.featuredQuote.authorGu = q[1]['gu']!;
    
    await Future.wait(d.teachings.map((t) async {
      final res = await Future.wait([translateToAll(t.title), translateToAll(t.subtitle), translateToAll(t.description)]);
      t.titleHi = res[0]['hi']!; t.titleGu = res[0]['gu']!;
      t.subtitleHi = res[1]['hi']!; t.subtitleGu = res[1]['gu']!;
      t.descriptionHi = res[2]['hi']!; t.descriptionGu = res[2]['gu']!;
    }));
    await Future.wait(d.testimonials.map((t) async {
      final res = await Future.wait([translateToAll(t.feedback), translateToAll(t.name)]);
      t.feedbackHi = res[0]['hi']!; t.feedbackGu = res[0]['gu']!;
      t.nameHi = res[1]['hi']!; t.nameGu = res[1]['gu']!;
    }));
    await Future.wait(d.news.map((n) async {
      final res = await Future.wait([translateToAll(n.title), translateToAll(n.category), translateToAll(n.date)]);
      n.titleHi = res[0]['hi']!; n.titleGu = res[0]['gu']!;
      n.categoryHi = res[1]['hi']!; n.categoryGu = res[1]['gu']!;
      n.dateHi = res[2]['hi']!; n.dateGu = res[2]['gu']!;
    }));
    d.teachingsPage = await translateTeachingsPageData(d.teachingsPage);
    d.homePortal = await translateHomePortalData(d.homePortal);
    return d;
  }

  static Future<TeachingsPageData> translateTeachingsPageData(TeachingsPageData d) async {
    final res = await Future.wait([
      translateToAll(d.heroTitle), translateToAll(d.heroSubtitle),
      translateToAll(d.divinePurposeTitle), translateToAll(d.divinePurposeDesc1), translateToAll(d.divinePurposeDesc2),
    ]);
    d.heroTitleHi = res[0]['hi']!; d.heroTitleGu = res[0]['gu']!;
    d.heroSubtitleHi = res[1]['hi']!; d.heroSubtitleGu = res[1]['gu']!;
    d.divinePurposeTitleHi = res[2]['hi']!; d.divinePurposeTitleGu = res[2]['gu']!;
    d.divinePurposeDesc1Hi = res[3]['hi']!; d.divinePurposeDesc1Gu = res[3]['gu']!;
    d.divinePurposeDesc2Hi = res[4]['hi']!; d.divinePurposeDesc2Gu = res[4]['gu']!;
    await Future.wait(d.pillars.map((p) async {
      final r = await Future.wait([translateToAll(p.title), translateToAll(p.subtitle), translateToAll(p.description)]);
      p.titleHi = r[0]['hi']!; p.titleGu = r[0]['gu']!;
      p.subtitleHi = r[1]['hi']!; p.subtitleGu = r[1]['gu']!;
      p.descriptionHi = r[2]['hi']!; p.descriptionGu = r[2]['gu']!;
    }));
    return d;
  }

  static Future<HomePortalData> translateHomePortalData(HomePortalData d) async {
    final res = await Future.wait([
      translateToAll(d.heroHeading), translateToAll(d.heroSubtitle),
      translateToAll(d.heroCta1Text), translateToAll(d.heroCta2Text),
      translateToAll(d.heroCardTitle), translateToAll(d.heroCardSubtitle),
      translateToAll(d.collectionsHeading), translateToAll(d.featuredHeading),
      translateToAll(d.testimonialsHeading), translateToAll(d.wisdomHeading),
      translateToAll(d.whatsappTitle), translateToAll(d.whatsappSubtitle), translateToAll(d.whatsappBtnText),
    ]);
    d.heroHeadingHi = res[0]['hi']!; d.heroHeadingGu = res[0]['gu']!;
    d.heroSubtitleHi = res[1]['hi']!; d.heroSubtitleGu = res[1]['gu']!;
    d.heroCta1TextHi = res[2]['hi']!; d.heroCta1TextGu = res[2]['gu']!;
    d.heroCta2TextHi = res[3]['hi']!; d.heroCta2TextGu = res[3]['gu']!;
    d.heroCardTitleHi = res[4]['hi']!; d.heroCardTitleGu = res[4]['gu']!;
    d.heroCardSubtitleHi = res[5]['hi']!; d.heroCardSubtitleGu = res[5]['gu']!;
    d.collectionsHeadingHi = res[6]['hi']!; d.collectionsHeadingGu = res[6]['gu']!;
    d.featuredHeadingHi = res[7]['hi']!; d.featuredHeadingGu = res[7]['gu']!;
    d.testimonialsHeadingHi = res[8]['hi']!; d.testimonialsHeadingGu = res[8]['gu']!;
    d.wisdomHeadingHi = res[9]['hi']!; d.wisdomHeadingGu = res[9]['gu']!;
    d.whatsappTitleHi = res[10]['hi']!; d.whatsappTitleGu = res[10]['gu']!;
    d.whatsappSubtitleHi = res[11]['hi']!; d.whatsappSubtitleGu = res[11]['gu']!;
    d.whatsappBtnTextHi = res[12]['hi']!; d.whatsappBtnTextGu = res[12]['gu']!;
    return d;
  }

  static Future<KathaRecord> translateKathaRecord(KathaRecord k) async {
    final res = await Future.wait([
      translateToAll(k.topic), translateToAll(k.location), translateToAll(k.description),
      translateToAll(k.year), translateToAll(k.dates), translateToAll(k.country), translateToAll(k.language),
    ]);
    k.topicHi = res[0]['hi']!; k.topicGu = res[0]['gu']!;
    k.locationHi = res[1]['hi']!; k.locationGu = res[1]['gu']!;
    k.descriptionHi = res[2]['hi']!; k.descriptionGu = res[2]['gu']!;
    k.yearHi = res[3]['hi']!; k.yearGu = res[3]['gu']!;
    k.datesHi = res[4]['hi']!; k.datesGu = res[4]['gu']!;
    k.countryHi = res[5]['hi']!; k.countryGu = res[5]['gu']!;
    k.languageHi = res[6]['hi']!; k.languageGu = res[6]['gu']!;
    return k;
  }

  static Future<ContactPageData> translateContactPageData(ContactPageData d) async {
    final res = await translateToAll(d.address);
    d.addressHi = res['hi']!; d.addressGu = res['gu']!;
    return d;
  }

  static Future<VideoGalleryPageData> translateVideoGalleryPageData(VideoGalleryPageData d) async {
    await Future.wait(d.categories.map((c) async {
      final res = await translateToAll(c.categoryTitle);
      c.categoryTitleHi = res['hi']!; c.categoryTitleGu = res['gu']!;
      await Future.wait(c.videos.map((v) async {
        final r = await translateToAll(v.title);
        v.titleHi = r['hi']!; v.titleGu = r['gu']!;
      }));
    }));
    return d;
  }

  static Future<PhotoGalleryPageData> translatePhotoGalleryPageData(PhotoGalleryPageData d) async {
    final res = await translateToAll(d.title);
    d.titleHi = res['hi']!; d.titleGu = res['gu']!;
    await Future.wait(d.sections.map((s) async {
      final r = await translateToAll(s.heading);
      s.headingHi = r['hi']!; s.headingGu = r['gu']!;
    }));
    return d;
  }

  static Future<ProfileData> translateProfileData(ProfileData d) async {
    final res = await Future.wait([
      translateToAll(d.contentHTML), translateToAll(d.socialInitiativeTitle),
      translateToAll(d.socialVision), translateToAll(d.socialMission), translateToAll(d.socialObjective),
      translateToAll(d.philosophyOfLife), translateToAll(d.signatureIdentityTitle), translateToAll(d.signatureIdentitySubtitle),
    ]);
    d.contentHTMLHi = res[0]['hi']!; d.contentHTMLGu = res[0]['gu']!;
    d.socialInitiativeTitleHi = res[1]['hi']!; d.socialInitiativeTitleGu = res[1]['gu']!;
    d.socialVisionHi = res[2]['hi']!; d.socialVisionGu = res[2]['gu']!;
    d.socialMissionHi = res[3]['hi']!; d.socialMissionGu = res[3]['gu']!;
    d.socialObjectiveHi = res[4]['hi']!; d.socialObjectiveGu = res[4]['gu']!;
    d.philosophyOfLifeHi = res[5]['hi']!; d.philosophyOfLifeGu = res[5]['gu']!;
    d.signatureIdentityTitleHi = res[6]['hi']!; d.signatureIdentityTitleGu = res[6]['gu']!;
    d.signatureIdentitySubtitleHi = res[7]['hi']!; d.signatureIdentitySubtitleGu = res[7]['gu']!;
    
    d.coreCompetenciesHi = await translateBatch(d.coreCompetencies, 'hi');
    d.coreCompetenciesGu = await translateBatch(d.coreCompetencies, 'gu');
    d.professionalHighlightsHi = await translateBatch(d.professionalHighlights, 'hi');
    d.professionalHighlightsGu = await translateBatch(d.professionalHighlights, 'gu');
    d.personalAttributesHi = await translateBatch(d.personalAttributes, 'hi');
    d.personalAttributesGu = await translateBatch(d.personalAttributes, 'gu');
    
    return d;
  }

  static Future<StoreConfigModel> translateStoreConfig(StoreConfigModel c) async {
    final res = await Future.wait([
      translateToAll(c.storeName),
      translateToAll(c.storeDescription),
      translateToAll(c.address),
    ]);
    return StoreConfigModel(
      logoUrl: c.logoUrl, bannerUrl: c.bannerUrl,
      storeName: c.storeName, storeNameHi: res[0]['hi']!, storeNameGu: res[0]['gu']!,
      storeDescription: c.storeDescription, storeDescriptionHi: res[1]['hi']!, storeDescriptionGu: res[1]['gu']!,
      contactEmail: c.contactEmail, contactPhone: c.contactPhone,
      address: c.address, addressHi: res[2]['hi']!, addressGu: res[2]['gu']!,
      facebookUrl: c.facebookUrl, instagramUrl: c.instagramUrl, twitterUrl: c.twitterUrl,
      deliveryCharge: c.deliveryCharge, freeDeliveryThreshold: c.freeDeliveryThreshold,
      enableCOD: c.enableCOD,
    );
  }

  static Future<ReviewModel> translateReview(ReviewModel r) async {
    final res = await translateToAll(r.comment);
    return ReviewModel(
      id: r.id, productId: r.productId, productName: r.productName,
      userId: r.userId, userName: r.userName, userPhone: r.userPhone,
      rating: r.rating,
      comment: r.comment, commentHi: res['hi']!, commentGu: res['gu']!,
      createdAt: r.createdAt,
    );
  }
}

class TranslationProgress {
  final String currentSection;
  final int completedRecords;
  final int totalRecords;
  final int failedRecords;
  final String status;

  TranslationProgress({
    this.currentSection = '',
    this.completedRecords = 0,
    this.totalRecords = 0,
    this.failedRecords = 0,
    this.status = 'Idle',
  });

  TranslationProgress copyWith({
    String? currentSection,
    int? completedRecords,
    int? totalRecords,
    int? failedRecords,
    String? status,
  }) {
    return TranslationProgress(
      currentSection: currentSection ?? this.currentSection,
      completedRecords: completedRecords ?? this.completedRecords,
      totalRecords: totalRecords ?? this.totalRecords,
      failedRecords: failedRecords ?? this.failedRecords,
      status: status ?? this.status,
    );
  }

  double get percentage => totalRecords == 0 ? 0 : (completedRecords + failedRecords) / totalRecords;
}
