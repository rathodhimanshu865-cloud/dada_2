import 'package:flutter/material.dart';

class HeaderSettings {
  bool stickyHeaderEnabled;
  bool searchVisibility;
  bool donateButtonEnabled;
  String donateButtonText;
  String donateButtonUrl;
  String announcementBarText;
  String headerBackgroundColor;
  List<String> languageOptions;

  HeaderSettings({
    this.stickyHeaderEnabled = true,
    this.searchVisibility = true,
    this.donateButtonEnabled = true,
    this.donateButtonText = 'DONATE',
    this.donateButtonUrl = '',
    this.announcementBarText = '',
    this.headerBackgroundColor = '#FAF8F4',
    this.languageOptions = const ['English', 'Gujarati', 'Hindi'],
  });

  Map<String, dynamic> toMap() => {
    'stickyHeaderEnabled': stickyHeaderEnabled,
    'searchVisibility': searchVisibility,
    'donateButtonEnabled': donateButtonEnabled,
    'donateButtonText': donateButtonText,
    'donateButtonUrl': donateButtonUrl,
    'announcementBarText': announcementBarText,
    'headerBackgroundColor': headerBackgroundColor,
    'languageOptions': languageOptions,
  };

  factory HeaderSettings.fromMap(Map<String, dynamic> map) => HeaderSettings(
    stickyHeaderEnabled: map['stickyHeaderEnabled'] ?? true,
    searchVisibility: map['searchVisibility'] ?? true,
    donateButtonEnabled: map['donateButtonEnabled'] ?? true,
    donateButtonText: map['donateButtonText'] ?? 'DONATE',
    donateButtonUrl: map['donateButtonUrl'] ?? '',
    announcementBarText: map['announcementBarText'] ?? '',
    headerBackgroundColor: map['headerBackgroundColor'] ?? '#FAF8F4',
    languageOptions: List<String>.from(map['languageOptions'] ?? ['English', 'Gujarati', 'Hindi']),
  );
}

class WebsiteSettings {
  String name;
  String logoUrl;
  HeaderSettings headerSettings;

  WebsiteSettings({
    this.name = '',
    this.logoUrl = '',
    HeaderSettings? headerSettings,
  }) : headerSettings = headerSettings ?? HeaderSettings();

  Map<String, dynamic> toMap() => {
        'name': name,
        'logoUrl': logoUrl,
        'headerSettings': headerSettings.toMap(),
      };

  factory WebsiteSettings.fromMap(Map<String, dynamic> map) => WebsiteSettings(
        name: map['name'] ?? '',
        logoUrl: map['logoUrl'] ?? '',
        headerSettings: map['headerSettings'] != null 
          ? HeaderSettings.fromMap(map['headerSettings']) 
          : HeaderSettings(),
      );
}

class HeroSlide {
  String image;
  String badge;
  String heading;
  String subtitle;
  String description;
  String primaryCtaText;
  String primaryCtaUrl;
  String secondaryCtaText;
  String secondaryCtaUrl;
  // Translations
  String badgeHi; String badgeGu;
  String headingHi; String headingGu;
  String subtitleHi; String subtitleGu;
  String descriptionHi; String descriptionGu;

  HeroSlide({
    this.image = '',
    this.badge = '',
    this.heading = '',
    this.subtitle = '',
    this.description = '',
    this.primaryCtaText = '',
    this.primaryCtaUrl = '',
    this.secondaryCtaText = '',
    this.secondaryCtaUrl = '',
    this.badgeHi = '', this.badgeGu = '',
    this.headingHi = '', this.headingGu = '',
    this.subtitleHi = '', this.subtitleGu = '',
    this.descriptionHi = '', this.descriptionGu = '',
  });

  String localizedBadge(String lang) => lang == 'hi' && badgeHi.isNotEmpty ? badgeHi : lang == 'gu' && badgeGu.isNotEmpty ? badgeGu : badge;
  String localizedHeading(String lang) => lang == 'hi' && headingHi.isNotEmpty ? headingHi : lang == 'gu' && headingGu.isNotEmpty ? headingGu : heading;
  String localizedSubtitle(String lang) => lang == 'hi' && subtitleHi.isNotEmpty ? subtitleHi : lang == 'gu' && subtitleGu.isNotEmpty ? subtitleGu : subtitle;
  String localizedDescription(String lang) => lang == 'hi' && descriptionHi.isNotEmpty ? descriptionHi : lang == 'gu' && descriptionGu.isNotEmpty ? descriptionGu : description;

  Map<String, dynamic> toMap() => {
    'image': image, 'badge': badge, 'heading': heading, 'subtitle': subtitle,
    'description': description, 'primaryCtaText': primaryCtaText, 'primaryCtaUrl': primaryCtaUrl,
    'secondaryCtaText': secondaryCtaText, 'secondaryCtaUrl': secondaryCtaUrl,
    'badge_hi': badgeHi, 'badge_gu': badgeGu,
    'heading_hi': headingHi, 'heading_gu': headingGu,
    'subtitle_hi': subtitleHi, 'subtitle_gu': subtitleGu,
    'description_hi': descriptionHi, 'description_gu': descriptionGu,
  };

  factory HeroSlide.fromMap(Map<String, dynamic> map) => HeroSlide(
    image: map['image'] ?? '',
    badge: map['badge'] ?? '',
    heading: map['heading'] ?? '',
    subtitle: map['subtitle'] ?? '',
    description: map['description'] ?? '',
    primaryCtaText: map['primaryCtaText'] ?? '',
    primaryCtaUrl: map['primaryCtaUrl'] ?? '',
    secondaryCtaText: map['secondaryCtaText'] ?? '',
    secondaryCtaUrl: map['secondaryCtaUrl'] ?? '',
    badgeHi: map['badge_hi'] ?? '', badgeGu: map['badge_gu'] ?? '',
    headingHi: map['heading_hi'] ?? '', headingGu: map['heading_gu'] ?? '',
    subtitleHi: map['subtitle_hi'] ?? '', subtitleGu: map['subtitle_gu'] ?? '',
    descriptionHi: map['description_hi'] ?? '', descriptionGu: map['description_gu'] ?? '',
  );
}

class HeroSection {
  List<HeroSlide> slides;
  HeroSection({List<HeroSlide>? slides}) : slides = slides ?? [];
  
  Map<String, dynamic> toMap() => {'slides': slides.map((e) => e.toMap()).toList()};
  
  factory HeroSection.fromMap(Map<String, dynamic> map) {
    // Migration logic: Check for 'slides' first, then fallback to 'bannerUrls'
    if (map['slides'] != null) {
      return HeroSection(
        slides: (map['slides'] as List).map((e) => HeroSlide.fromMap(e)).toList(),
      );
    } else if (map['bannerUrls'] != null) {
      return HeroSection(
        slides: (map['bannerUrls'] as List)
            .map((url) => HeroSlide(image: url.toString()))
            .toList(),
      );
    }
    return HeroSection();
  }
      
  List<String> get bannerUrls => slides.map((e) => e.image).toList();
}

class FeaturedQuote {
  String quote;
  String author;
  String portrait;
  String background;
  // Translations
  String quoteHi; String quoteGu;
  String authorHi; String authorGu;

  FeaturedQuote({this.quote = '', this.author = '', this.portrait = '', this.background = '',
    this.quoteHi = '', this.quoteGu = '', this.authorHi = '', this.authorGu = ''});

  String localizedQuote(String lang) => lang == 'hi' && quoteHi.isNotEmpty ? quoteHi : lang == 'gu' && quoteGu.isNotEmpty ? quoteGu : quote;
  String localizedAuthor(String lang) => lang == 'hi' && authorHi.isNotEmpty ? authorHi : lang == 'gu' && authorGu.isNotEmpty ? authorGu : author;

  Map<String, dynamic> toMap() => {'quote': quote, 'author': author, 'portrait': portrait, 'background': background,
    'quote_hi': quoteHi, 'quote_gu': quoteGu, 'author_hi': authorHi, 'author_gu': authorGu};
  factory FeaturedQuote.fromMap(Map<String, dynamic> map) => FeaturedQuote(
    quote: map['quote'] ?? '',
    author: map['author'] ?? '',
    portrait: map['portrait'] ?? '',
    background: map['background'] ?? '',
    quoteHi: map['quote_hi'] ?? '', quoteGu: map['quote_gu'] ?? '',
    authorHi: map['author_hi'] ?? '', authorGu: map['author_gu'] ?? '',
  );
}

class TeachingCard {
  String title;
  String subtitle;
  String description;
  String image;
  String icon;
  // Translations
  String titleHi; String titleGu;
  String subtitleHi; String subtitleGu;
  String descriptionHi; String descriptionGu;

  TeachingCard({this.title = '', this.subtitle = '', this.description = '', this.image = '', this.icon = '',
    this.titleHi = '', this.titleGu = '', this.subtitleHi = '', this.subtitleGu = '',
    this.descriptionHi = '', this.descriptionGu = ''});

  String localizedTitle(String lang) => lang == 'hi' && titleHi.isNotEmpty ? titleHi : lang == 'gu' && titleGu.isNotEmpty ? titleGu : title;
  String localizedSubtitle(String lang) => lang == 'hi' && subtitleHi.isNotEmpty ? subtitleHi : lang == 'gu' && subtitleGu.isNotEmpty ? subtitleGu : subtitle;
  String localizedDescription(String lang) => lang == 'hi' && descriptionHi.isNotEmpty ? descriptionHi : lang == 'gu' && descriptionGu.isNotEmpty ? descriptionGu : description;

  Map<String, dynamic> toMap() => {'title': title, 'subtitle': subtitle, 'description': description, 'image': image, 'icon': icon,
    'title_hi': titleHi, 'title_gu': titleGu, 'subtitle_hi': subtitleHi, 'subtitle_gu': subtitleGu,
    'description_hi': descriptionHi, 'description_gu': descriptionGu};
  factory TeachingCard.fromMap(Map<String, dynamic> map) => TeachingCard(
    title: map['title'] ?? '', subtitle: map['subtitle'] ?? '', description: map['description'] ?? '',
    image: map['image'] ?? '', icon: map['icon'] ?? '',
    titleHi: map['title_hi'] ?? '', titleGu: map['title_gu'] ?? '',
    subtitleHi: map['subtitle_hi'] ?? '', subtitleGu: map['subtitle_gu'] ?? '',
    descriptionHi: map['description_hi'] ?? '', descriptionGu: map['description_gu'] ?? '',
  );
}

class Testimonial {
  String name;
  String location;
  String feedback;
  String photo;
  // Translations
  String feedbackHi; String feedbackGu;
  String nameHi; String nameGu;

  Testimonial({this.name = '', this.location = '', this.feedback = '', this.photo = '',
    this.feedbackHi = '', this.feedbackGu = '', this.nameHi = '', this.nameGu = ''});

  String localizedName(String lang) => lang == 'hi' && nameHi.isNotEmpty ? nameHi : lang == 'gu' && nameGu.isNotEmpty ? nameGu : name;
  String localizedFeedback(String lang) => lang == 'hi' && feedbackHi.isNotEmpty ? feedbackHi : lang == 'gu' && feedbackGu.isNotEmpty ? feedbackGu : feedback;

  Map<String, dynamic> toMap() => {'name': name, 'location': location, 'feedback': feedback, 'photo': photo,
    'feedback_hi': feedbackHi, 'feedback_gu': feedbackGu, 'name_hi': nameHi, 'name_gu': nameGu};
  factory Testimonial.fromMap(Map<String, dynamic> map) => Testimonial(
    name: map['name'] ?? '', location: map['location'] ?? '', feedback: map['feedback'] ?? '', photo: map['photo'] ?? '',
    feedbackHi: map['feedback_hi'] ?? '', feedbackGu: map['feedback_gu'] ?? '',
    nameHi: map['name_hi'] ?? '', nameGu: map['name_gu'] ?? '',
  );
}

class NewsItem {
  String title;
  String category;
  String date;
  String image;
  String url;

  NewsItem({this.title = '', this.category = '', this.date = '', this.image = '', this.url = ''});

  Map<String, dynamic> toMap() => {'title': title, 'category': category, 'date': date, 'image': image, 'url': url};
  factory NewsItem.fromMap(Map<String, dynamic> map) => NewsItem(
    title: map['title'] ?? '',
    category: map['category'] ?? '',
    date: map['date'] ?? '',
    image: map['image'] ?? '',
    url: map['url'] ?? '',
  );
}

class HomepageData {
  FeaturedQuote featuredQuote;
  List<TeachingCard> teachings;
  List<Testimonial> testimonials;
  List<NewsItem> news;

  HomepageData({
    FeaturedQuote? featuredQuote,
    List<TeachingCard>? teachings,
    List<Testimonial>? testimonials,
    List<NewsItem>? news,
  }) : featuredQuote = featuredQuote ?? FeaturedQuote(),
       teachings = teachings ?? [],
       testimonials = testimonials ?? [],
       news = news ?? [];

  Map<String, dynamic> toMap() => {
    'featuredQuote': featuredQuote.toMap(),
    'teachings': teachings.map((e) => e.toMap()).toList(),
    'testimonials': testimonials.map((e) => e.toMap()).toList(),
    'news': news.map((e) => e.toMap()).toList(),
  };

  factory HomepageData.fromMap(Map<String, dynamic> map) => HomepageData(
    featuredQuote: FeaturedQuote.fromMap(map['featuredQuote'] ?? {}),
    teachings: (map['teachings'] as List? ?? []).map((e) => TeachingCard.fromMap(e)).toList(),
    testimonials: (map['testimonials'] as List? ?? []).map((e) => Testimonial.fromMap(e)).toList(),
    news: (map['news'] as List? ?? []).map((e) => NewsItem.fromMap(e)).toList(),
  );
}

// ... Rest of existing models enhanced ...

class UpcomingKatha {
  String kathaNumber;
  String name;
  String dateString;
  String timing;
  String location;
  String hosting;
  DateTime? startDate;
  DateTime? endDate;
  // Translations
  String nameHi; String nameGu;
  String locationHi; String locationGu;
  String dateStringHi; String dateStringGu;

  UpcomingKatha({
    this.kathaNumber = '', this.name = '', this.dateString = '', this.timing = '',
    this.location = '', this.hosting = '', this.startDate, this.endDate,
    this.nameHi = '', this.nameGu = '',
    this.locationHi = '', this.locationGu = '',
    this.dateStringHi = '', this.dateStringGu = '',
  });

  String localizedName(String lang) => lang == 'hi' && nameHi.isNotEmpty ? nameHi : lang == 'gu' && nameGu.isNotEmpty ? nameGu : name;
  String localizedLocation(String lang) => lang == 'hi' && locationHi.isNotEmpty ? locationHi : lang == 'gu' && locationGu.isNotEmpty ? locationGu : location;
  String localizedDateString(String lang) => lang == 'hi' && dateStringHi.isNotEmpty ? dateStringHi : lang == 'gu' && dateStringGu.isNotEmpty ? dateStringGu : dateString;

  Map<String, dynamic> toMap() => {
    'kathaNumber': kathaNumber, 'name': name, 'dateString': dateString, 'timing': timing,
    'location': location, 'hosting': hosting,
    'startDate': startDate?.toIso8601String(), 'endDate': endDate?.toIso8601String(),
    'name_hi': nameHi, 'name_gu': nameGu,
    'location_hi': locationHi, 'location_gu': locationGu,
    'dateString_hi': dateStringHi, 'dateString_gu': dateStringGu,
  };

  factory UpcomingKatha.fromMap(Map<String, dynamic> map) => UpcomingKatha(
    kathaNumber: map['kathaNumber'] ?? '', name: map['name'] ?? '', dateString: map['dateString'] ?? '',
    timing: map['timing'] ?? '', location: map['location'] ?? '', hosting: map['hosting'] ?? '',
    startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
    endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
    nameHi: map['name_hi'] ?? '', nameGu: map['name_gu'] ?? '',
    locationHi: map['location_hi'] ?? '', locationGu: map['location_gu'] ?? '',
    dateStringHi: map['dateString_hi'] ?? '', dateStringGu: map['dateString_gu'] ?? '',
  );
}

class AboutSection {
  String photoUrl;
  String description;
  String title;
  String tagline;
  String quote;
  List<String> paragraphs;
  List<String> galleryImages;
  // Translations
  String titleHi; String titleGu;
  String taglineHi; String taglineGu;
  String descriptionHi; String descriptionGu;
  List<String> paragraphsHi; List<String> paragraphsGu;

  AboutSection({
    this.photoUrl = '', this.description = '',
    this.title = 'Pu. Jignesh Dada',
    this.tagline = 'A divine voice of compassion, wisdom, and service',
    this.quote = 'Radhe Radhe is not just a greeting; it is a resonance of the soul.',
    List<String>? paragraphs, List<String>? galleryImages,
    this.titleHi = '', this.titleGu = '',
    this.taglineHi = '', this.taglineGu = '',
    this.descriptionHi = '', this.descriptionGu = '',
    List<String>? paragraphsHi, List<String>? paragraphsGu,
  })  : paragraphs = paragraphs ?? [],
        galleryImages = galleryImages ?? [],
        paragraphsHi = paragraphsHi ?? [],
        paragraphsGu = paragraphsGu ?? [];

  String localizedTitle(String lang) => lang == 'hi' && titleHi.isNotEmpty ? titleHi : lang == 'gu' && titleGu.isNotEmpty ? titleGu : title;
  String localizedTagline(String lang) => lang == 'hi' && taglineHi.isNotEmpty ? taglineHi : lang == 'gu' && taglineGu.isNotEmpty ? taglineGu : tagline;
  String localizedDescription(String lang) => lang == 'hi' && descriptionHi.isNotEmpty ? descriptionHi : lang == 'gu' && descriptionGu.isNotEmpty ? descriptionGu : description;
  List<String> localizedParagraphs(String lang) {
    if (lang == 'hi' && paragraphsHi.isNotEmpty) return paragraphsHi;
    if (lang == 'gu' && paragraphsGu.isNotEmpty) return paragraphsGu;
    return paragraphs;
  }

  Map<String, dynamic> toMap() => {
    'photoUrl': photoUrl, 'description': description, 'title': title,
    'tagline': tagline, 'quote': quote, 'paragraphs': paragraphs, 'galleryImages': galleryImages,
    'title_hi': titleHi, 'title_gu': titleGu,
    'tagline_hi': taglineHi, 'tagline_gu': taglineGu,
    'description_hi': descriptionHi, 'description_gu': descriptionGu,
    'paragraphs_hi': paragraphsHi, 'paragraphs_gu': paragraphsGu,
  };

  factory AboutSection.fromMap(Map<String, dynamic> map) {
    final storedParagraphs = map['paragraphs'];
    final parsedParagraphs = storedParagraphs is List ? storedParagraphs.map((item) => item.toString()).toList() : <String>[];
    final storedGalleryImages = map['galleryImages'];
    final parsedGalleryImages = storedGalleryImages is List ? storedGalleryImages.map((item) => item.toString()).toList() : <String>[];
    final parsedParaHi = (map['paragraphs_hi'] as List? ?? []).map((e) => e.toString()).toList();
    final parsedParaGu = (map['paragraphs_gu'] as List? ?? []).map((e) => e.toString()).toList();

    return AboutSection(
      photoUrl: map['photoUrl'] ?? '',
      description: map['description'] ?? '',
      title: map['title'] ?? 'Pu. Jignesh Dada',
      tagline: map['tagline'] ?? 'A divine voice of compassion, wisdom, and service',
      quote: map['quote'] ?? 'Radhe Radhe is not just a greeting; it is a resonance of the soul.',
      paragraphs: parsedParagraphs.isNotEmpty ? parsedParagraphs : (map['description']?.toString().trim().isNotEmpty ?? false) ? [map['description'].toString()] : <String>[],
      galleryImages: parsedGalleryImages,
      titleHi: map['title_hi'] ?? '', titleGu: map['title_gu'] ?? '',
      taglineHi: map['tagline_hi'] ?? '', taglineGu: map['tagline_gu'] ?? '',
      descriptionHi: map['description_hi'] ?? '', descriptionGu: map['description_gu'] ?? '',
      paragraphsHi: parsedParaHi, paragraphsGu: parsedParaGu,
    );
  }

  List<String> get visibleParagraphs {
    final cleanParagraphs = paragraphs.where((item) => item.trim().isNotEmpty).toList();
    if (cleanParagraphs.isNotEmpty) return cleanParagraphs;
    if (description.trim().isEmpty) return [];
    return description.split(RegExp(r'\n\s*\n')).map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }

  List<String> get visibleGalleryImages {
    final cleanImages = galleryImages.where((item) => item.trim().isNotEmpty).toList();
    if (cleanImages.isNotEmpty) return cleanImages;
    if (photoUrl.trim().isNotEmpty) return [photoUrl];
    return [];
  }
}

class DailySuvichar {
  String imageUrl;
  String date;

  DailySuvichar({this.imageUrl = '', this.date = ''});

  Map<String, dynamic> toMap() => {'imageUrl': imageUrl, 'date': date};

  factory DailySuvichar.fromMap(Map<String, dynamic> map) =>
      DailySuvichar(imageUrl: map['imageUrl'] ?? '', date: map['date'] ?? '');
}

class VideoItem {
  String title;
  String youtubeUrl;

  VideoItem({this.title = '', this.youtubeUrl = ''});

  Map<String, dynamic> toMap() => {'title': title, 'youtubeUrl': youtubeUrl};

  factory VideoItem.fromMap(Map<String, dynamic> map) =>
      VideoItem(title: map['title'] ?? '', youtubeUrl: map['youtubeUrl'] ?? '');

  String get thumbnail {
    if (youtubeUrl.isEmpty) return 'https://via.placeholder.com/300x500';
    String videoId = '';
    if (youtubeUrl.contains('/shorts/')) {
      videoId = youtubeUrl.split('/shorts/')[1].split('?')[0];
    } else if (youtubeUrl.contains('v=')) {
      videoId = youtubeUrl.split('v=')[1].split('&')[0];
    } else if (youtubeUrl.contains('youtu.be/')) {
      videoId = youtubeUrl.split('youtu.be/')[1].split('?')[0];
    }
    return videoId.isNotEmpty
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : 'https://via.placeholder.com/300x500';
  }
}

class RamKathaSection {
  String title;
  String description1;
  String description2;
  String photoUrl;
  // Translations
  String description1Hi; String description1Gu;
  String description2Hi; String description2Gu;

  RamKathaSection({
    this.title = 'Ram Katha', this.description1 = '', this.description2 = '', this.photoUrl = '',
    this.description1Hi = '', this.description1Gu = '',
    this.description2Hi = '', this.description2Gu = '',
  });

  String localizedDescription1(String lang) => lang == 'hi' && description1Hi.isNotEmpty ? description1Hi : lang == 'gu' && description1Gu.isNotEmpty ? description1Gu : description1;
  String localizedDescription2(String lang) => lang == 'hi' && description2Hi.isNotEmpty ? description2Hi : lang == 'gu' && description2Gu.isNotEmpty ? description2Gu : description2;

  Map<String, dynamic> toMap() => {
    'title': title, 'description1': description1, 'description2': description2, 'photoUrl': photoUrl,
    'description1_hi': description1Hi, 'description1_gu': description1Gu,
    'description2_hi': description2Hi, 'description2_gu': description2Gu,
  };
  factory RamKathaSection.fromMap(Map<String, dynamic> map) => RamKathaSection(
    title: map['title'] ?? 'Ram Katha',
    description1: map['description1'] ?? '',
    description2: map['description2'] ?? '',
    photoUrl: map['photoUrl'] ?? '',
    description1Hi: map['description1_hi'] ?? '', description1Gu: map['description1_gu'] ?? '',
    description2Hi: map['description2_hi'] ?? '', description2Gu: map['description2_gu'] ?? '',
  );
}

class FooterData {
  String description;
  String copyright;
  String youtubeUrl;
  String instagramUrl;
  String facebookUrl;
  String whatsappUrl;

  FooterData({
    this.description = '', 
    this.copyright = '',
    this.youtubeUrl = '',
    this.instagramUrl = '',
    this.facebookUrl = '',
    this.whatsappUrl = '',
  });

  Map<String, dynamic> toMap() => {
    'description': description,
    'copyright': copyright,
    'youtubeUrl': youtubeUrl,
    'instagramUrl': instagramUrl,
    'facebookUrl': facebookUrl,
    'whatsappUrl': whatsappUrl,
  };

  factory FooterData.fromMap(Map<String, dynamic> map) => FooterData(
    description: map['description'] ?? '',
    copyright: map['copyright'] ?? '',
    youtubeUrl: map['youtubeUrl'] ?? '',
    instagramUrl: map['instagramUrl'] ?? '',
    facebookUrl: map['facebookUrl'] ?? '',
    whatsappUrl: map['whatsappUrl'] ?? '',
  );
}

class KathaRecord {
  String kathaNumber;
  String year;
  String dates;
  String topic;
  String location;
  String country;
  String language;
  String youtubePlaylistUrl;
  String description;
  String imageUrl;

  KathaRecord({
    this.kathaNumber = '',
    this.year = '',
    this.dates = '',
    this.topic = '',
    this.location = '',
    this.country = 'India',
    this.language = 'Hindi',
    this.youtubePlaylistUrl = '',
    this.description = '',
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() => {
    'kathaNumber': kathaNumber,
    'year': year,
    'dates': dates,
    'topic': topic,
    'location': location,
    'country': country,
    'language': language,
    'youtubePlaylistUrl': youtubePlaylistUrl,
    'description': description,
    'imageUrl': imageUrl,
  };

  factory KathaRecord.fromMap(Map<String, dynamic> map) => KathaRecord(
    kathaNumber: map['kathaNumber'] ?? '',
    year: map['year'] ?? '',
    dates: map['dates'] ?? '',
    topic: map['topic'] ?? '',
    location: map['location'] ?? '',
    country: map['country'] ?? 'India',
    language: map['language'] ?? 'Hindi',
    youtubePlaylistUrl: map['youtubePlaylistUrl'] ?? '',
    description: map['description'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
  );
}

class BiographyPhase {
  String title;
  String subtitle;
  String content;
  List<String> images;
  String layoutType;
  // Translations
  String titleHi; String titleGu;
  String subtitleHi; String subtitleGu;
  String contentHi; String contentGu;

  BiographyPhase({
    this.title = '', this.subtitle = '', this.content = '',
    List<String>? images, this.layoutType = 'standard',
    this.titleHi = '', this.titleGu = '',
    this.subtitleHi = '', this.subtitleGu = '',
    this.contentHi = '', this.contentGu = '',
  }) : images = images ?? [];

  String localizedTitle(String lang) => lang == 'hi' && titleHi.isNotEmpty ? titleHi : lang == 'gu' && titleGu.isNotEmpty ? titleGu : title;
  String localizedSubtitle(String lang) => lang == 'hi' && subtitleHi.isNotEmpty ? subtitleHi : lang == 'gu' && subtitleGu.isNotEmpty ? subtitleGu : subtitle;
  String localizedContent(String lang) => lang == 'hi' && contentHi.isNotEmpty ? contentHi : lang == 'gu' && contentGu.isNotEmpty ? contentGu : content;

  Map<String, dynamic> toMap() => {
    'title': title, 'subtitle': subtitle, 'content': content, 'images': images, 'layoutType': layoutType,
    'title_hi': titleHi, 'title_gu': titleGu,
    'subtitle_hi': subtitleHi, 'subtitle_gu': subtitleGu,
    'content_hi': contentHi, 'content_gu': contentGu,
  };

  factory BiographyPhase.fromMap(Map<String, dynamic> map) => BiographyPhase(
    title: map['title'] ?? '', subtitle: map['subtitle'] ?? '', content: map['content'] ?? '',
    images: List<String>.from(map['images'] ?? []), layoutType: map['layoutType'] ?? 'standard',
    titleHi: map['title_hi'] ?? '', titleGu: map['title_gu'] ?? '',
    subtitleHi: map['subtitle_hi'] ?? '', subtitleGu: map['subtitle_gu'] ?? '',
    contentHi: map['content_hi'] ?? '', contentGu: map['content_gu'] ?? '',
  );
}

class AboutDadaPageData {
  String heroTitle;
  String heroSubtitle;
  String heroImage;
  List<BiographyPhase> phases;

  AboutDadaPageData({
    this.heroTitle = '',
    this.heroSubtitle = '',
    this.heroImage = '',
    List<BiographyPhase>? phases,
  }) : phases = phases ?? [];

  Map<String, dynamic> toMap() => {
        'heroTitle': heroTitle,
        'heroSubtitle': heroSubtitle,
        'heroImage': heroImage,
        'phases': phases.map((p) => p.toMap()).toList(),
      };

  factory AboutDadaPageData.fromMap(Map<String, dynamic> map) => AboutDadaPageData(
        heroTitle: map['heroTitle'] ?? '',
        heroSubtitle: map['heroSubtitle'] ?? '',
        heroImage: map['heroImage'] ?? '',
        phases: (map['phases'] as List? ?? []).map((p) => BiographyPhase.fromMap(p)).toList(),
      );
}

class StotraItem {
  String title;
  String englishPdfUrl;
  String hindiPdfUrl;
  String gujaratiPdfUrl;

  StotraItem({
    this.title = '',
    this.englishPdfUrl = '',
    this.hindiPdfUrl = '',
    this.gujaratiPdfUrl = '',
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'englishPdfUrl': englishPdfUrl,
    'hindiPdfUrl': hindiPdfUrl,
    'gujaratiPdfUrl': gujaratiPdfUrl,
  };

  factory StotraItem.fromMap(Map<String, dynamic> map) => StotraItem(
    title: map['title'] ?? '',
    englishPdfUrl: map['englishPdfUrl'] ?? '',
    hindiPdfUrl: map['hindiPdfUrl'] ?? '',
    gujaratiPdfUrl: map['gujaratiPdfUrl'] ?? '',
  );
}

class StotraSection {
  String pageTitle;
  String topHeaderImage;
  List<StotraItem> items;

  StotraSection({
    this.pageTitle = 'Stotra / Bhajan / Aarti',
    this.topHeaderImage = '',
    List<StotraItem>? items,
  }) : items = items ?? [];

  Map<String, dynamic> toMap() => {
    'pageTitle': pageTitle,
    'topHeaderImage': topHeaderImage,
    'items': items.map((e) => e.toMap()).toList(),
  };

  factory StotraSection.fromMap(Map<String, dynamic> map) => StotraSection(
    pageTitle: map['pageTitle'] ?? 'Stotra / Bhajan / Aarti',
    topHeaderImage: map['topHeaderImage'] ?? '',
    items: (map['items'] as List? ?? []).map((e) => StotraItem.fromMap(e)).toList(),
  );
}

class KathaAboutPageData {
  String heroBadge;
  String heroTitle;
  String heroDesc1;
  String heroDesc2;
  String heroImage;
  String bioText;
  String quoteText;
  String quoteAuthor;
  String quoteImage;
  String highlight1Title;
  String highlight1Desc;
  String highlight2Title;
  String highlight2Desc;
  String highlight3Title;
  String highlight3Desc;
  String ctaTitle;
  String ctaSubtitle;
  String ctaButtonText;

  KathaAboutPageData({
    this.heroBadge = 'ABOUT KATHA &',
    this.heroTitle = 'PU. JIGNESH DADA (RADHE RADHE)',
    this.heroDesc1 = 'A divine journey of knowledge, devotion and self-realization through Shrimad Bhagwat Katha.',
    this.heroDesc2 = '',
    this.heroImage = '',
    this.bioText = '',
    this.quoteText = 'Bhagwat Katha is not just a narration, it is a life transformation. It connects the soul with the supreme through the path of devotion.',
    this.quoteAuthor = 'Jignesh Dada',
    this.quoteImage = '',
    this.highlight1Title = 'OUR KATHA',
    this.highlight1Desc = 'Shrimad Bhagwat Katha is a timeless treasure that enlightens the heart, removes darkness and shows us the path of truth, devotion and righteous living.',
    this.highlight2Title = 'OUR MISSION',
    this.highlight2Desc = 'To spread the divine wisdom of Bhagwat through Katha, inspire devotion, nurture values and bring positive change in society.',
    this.highlight3Title = 'OUR VISION',
    this.highlight3Desc = 'A world filled with love, peace, compassion and righteousness where every soul walks the path of spirituality and service.',
    this.ctaTitle = 'Join us in this Divine Journey',
    this.ctaSubtitle = 'Listen, reflect and experience the nectar of Bhagwat Katha. Let devotion lead your life towards peace and purpose.',
    this.ctaButtonText = 'EXPLORE KATHA',
  });

  Map<String, dynamic> toMap() => {
    'heroBadge': heroBadge,
    'heroTitle': heroTitle,
    'heroDesc1': heroDesc1,
    'heroDesc2': heroDesc2,
    'heroImage': heroImage,
    'bioText': bioText,
    'quoteText': quoteText,
    'quoteAuthor': quoteAuthor,
    'quoteImage': quoteImage,
    'highlight1Title': highlight1Title,
    'highlight1Desc': highlight1Desc,
    'highlight2Title': highlight2Title,
    'highlight2Desc': highlight2Desc,
    'highlight3Title': highlight3Title,
    'highlight3Desc': highlight3Desc,
    'ctaTitle': ctaTitle,
    'ctaSubtitle': ctaSubtitle,
    'ctaButtonText': ctaButtonText,
  };

  factory KathaAboutPageData.fromMap(Map<String, dynamic> map) => KathaAboutPageData(
    heroBadge: map['heroBadge'] ?? '',
    heroTitle: map['heroTitle'] ?? '',
    heroDesc1: map['heroDesc1'] ?? '',
    heroDesc2: map['heroDesc2'] ?? '',
    heroImage: map['heroImage'] ?? '',
    bioText: map['bioText'] ?? '',
    quoteText: map['quoteText'] ?? '',
    quoteAuthor: map['quoteAuthor'] ?? '',
    quoteImage: map['quoteImage'] ?? '',
    highlight1Title: map['highlight1Title'] ?? '',
    highlight1Desc: map['highlight1Desc'] ?? '',
    highlight2Title: map['highlight2Title'] ?? '',
    highlight2Desc: map['highlight2Desc'] ?? '',
    highlight3Title: map['highlight3Title'] ?? '',
    highlight3Desc: map['highlight3Desc'] ?? '',
    ctaTitle: map['ctaTitle'] ?? '',
    ctaSubtitle: map['ctaSubtitle'] ?? '',
    ctaButtonText: map['ctaButtonText'] ?? '',
  );
}

class KathaListPageData {
  String bannerImageUrl;
  KathaListPageData({this.bannerImageUrl = ''});
  Map<String, dynamic> toMap() => {'bannerImageUrl': bannerImageUrl};
  factory KathaListPageData.fromMap(Map<String, dynamic> map) =>
      KathaListPageData(bannerImageUrl: map['bannerImageUrl'] ?? '');
}

class ContactPageData {
  String bannerImageUrl;
  ContactPageData({this.bannerImageUrl = ''});
  Map<String, dynamic> toMap() => {'bannerImageUrl': bannerImageUrl};
  factory ContactPageData.fromMap(Map<String, dynamic> map) =>
      ContactPageData(bannerImageUrl: map['bannerImageUrl'] ?? '');
}

class VideoCategory {
  String categoryTitle;
  List<VideoGalleryEntry> videos;
  VideoCategory({this.categoryTitle = '', List<VideoGalleryEntry>? videos}) : videos = videos ?? [];
  Map<String, dynamic> toMap() => {'categoryTitle': categoryTitle, 'videos': videos.map((v) => v.toMap()).toList()};
  factory VideoCategory.fromMap(Map<String, dynamic> map) => VideoCategory(
    categoryTitle: map['categoryTitle'] ?? '',
    videos: (map['videos'] as List? ?? []).map((v) => VideoGalleryEntry.fromMap(v)).toList(),
  );
}

class VideoGalleryEntry {
  String title;
  String youtubeUrl;
  VideoGalleryEntry({this.title = '', this.youtubeUrl = ''});
  Map<String, dynamic> toMap() => {'title': title, 'youtubeUrl': youtubeUrl};
  factory VideoGalleryEntry.fromMap(Map<String, dynamic> map) => VideoGalleryEntry(title: map['title'] ?? '', youtubeUrl: map['youtubeUrl'] ?? '');
  String get thumbnail {
    if (youtubeUrl.isEmpty) return 'https://via.placeholder.com/300x200';
    String videoId = '';
    if (youtubeUrl.contains('/shorts/')) {
      videoId = youtubeUrl.split('/shorts/')[1].split('?')[0];
    } else if (youtubeUrl.contains('v=')) {
      videoId = youtubeUrl.split('v=')[1].split('&')[0];
    } else if (youtubeUrl.contains('youtu.be/')) {
      videoId = youtubeUrl.split('youtu.be/')[1].split('?')[0];
    }
    return videoId.isNotEmpty ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg' : 'https://via.placeholder.com/300x200';
  }
}

class VideoGalleryPageData {
  String headerImageUrl;
  List<VideoCategory> categories;
  VideoGalleryPageData({this.headerImageUrl = '', List<VideoCategory>? categories}) : categories = categories ?? [];
  Map<String, dynamic> toMap() => {'headerImageUrl': headerImageUrl, 'categories': categories.map((c) => c.toMap()).toList()};
  factory VideoGalleryPageData.fromMap(Map<String, dynamic> map) =>
      VideoGalleryPageData(headerImageUrl: map['headerImageUrl'] ?? '', categories: (map['categories'] as List? ?? []).map((c) => VideoCategory.fromMap(c)).toList());
}

class PhotoGallerySection {
  String heading;
  List<String> photoUrls;
  PhotoGallerySection({this.heading = '', List<String>? photoUrls}) : photoUrls = photoUrls ?? [];
  Map<String, dynamic> toMap() => {'heading': heading, 'photoUrls': photoUrls};
  factory PhotoGallerySection.fromMap(Map<String, dynamic> map) => PhotoGallerySection(heading: map['heading'] ?? '', photoUrls: List<String>.from(map['photoUrls'] ?? []));
}

class PhotoGalleryPageData {
  String title;
  String headerImageUrl;
  List<PhotoGallerySection> sections;
  PhotoGalleryPageData({this.title = 'Gallery', this.headerImageUrl = '', List<PhotoGallerySection>? sections}) : sections = sections ?? [];
  Map<String, dynamic> toMap() => {'title': title, 'headerImageUrl': headerImageUrl, 'sections': sections.map((c) => c.toMap()).toList()};
  factory PhotoGalleryPageData.fromMap(Map<String, dynamic> map) =>
      PhotoGalleryPageData(title: map['title'] ?? 'Gallery', headerImageUrl: map['headerImageUrl'] ?? '', sections: (map['sections'] as List? ?? []).map((c) => PhotoGallerySection.fromMap(c)).toList());
}
