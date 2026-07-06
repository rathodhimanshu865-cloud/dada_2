class WebsiteSettings {
  String name;
  String logoUrl;

  WebsiteSettings({
    this.name = '',
    this.logoUrl = '',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'logoUrl': logoUrl,
      };

  factory WebsiteSettings.fromMap(Map<String, dynamic> map) => WebsiteSettings(
        name: map['name'] ?? '',
        logoUrl: map['logoUrl'] ?? '',
      );
}

class HeroSection {
  List<String> bannerUrls;
  HeroSection({List<String>? bannerUrls})
    : bannerUrls = bannerUrls ?? List.filled(8, '');
  Map<String, dynamic> toMap() => {'bannerUrls': bannerUrls};
  factory HeroSection.fromMap(Map<String, dynamic> map) =>
      HeroSection(bannerUrls: List<String>.from(map['bannerUrls'] ?? []));
}

class UpcomingKatha {
  String kathaNumber;
  String name;
  String dateString;
  String timing;
  String location;
  String hosting;
  DateTime? startDate;
  DateTime? endDate;

  UpcomingKatha({
    this.kathaNumber = '',
    this.name = '',
    this.dateString = '',
    this.timing = '',
    this.location = '',
    this.hosting = '',
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'kathaNumber': kathaNumber,
    'name': name,
    'dateString': dateString,
    'timing': timing,
    'location': location,
    'hosting': hosting,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory UpcomingKatha.fromMap(Map<String, dynamic> map) => UpcomingKatha(
    kathaNumber: map['kathaNumber'] ?? '',
    name: map['name'] ?? '',
    dateString: map['dateString'] ?? '',
    timing: map['timing'] ?? '',
    location: map['location'] ?? '',
    hosting: map['hosting'] ?? '',
    startDate: map['startDate'] != null
        ? DateTime.tryParse(map['startDate'])
        : null,
    endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
  );
}

class AboutSection {
  String photoUrl;
  String description;
  AboutSection({this.photoUrl = '', this.description = ''});
  Map<String, dynamic> toMap() => {
    'photoUrl': photoUrl,
    'description': description,
  };
  factory AboutSection.fromMap(Map<String, dynamic> map) => AboutSection(
    photoUrl: map['photoUrl'] ?? '',
    description: map['description'] ?? '',
  );
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
  RamKathaSection({
    this.title = 'Ram Katha',
    this.description1 = '',
    this.description2 = '',
    this.photoUrl = '',
  });
  Map<String, dynamic> toMap() => {
    'title': title,
    'description1': description1,
    'description2': description2,
    'photoUrl': photoUrl,
  };
  factory RamKathaSection.fromMap(Map<String, dynamic> map) => RamKathaSection(
    title: map['title'] ?? 'Ram Katha',
    description1: map['description1'] ?? '',
    description2: map['description2'] ?? '',
    photoUrl: map['photoUrl'] ?? '',
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
    items: (map['items'] as List? ?? [])
        .map((e) => StotraItem.fromMap(e))
        .toList(),
  );
}

class AboutKathaPageData {
  String heroBadge;
  String heroTitle;
  String heroSubtitle;
  String heroImage;
  
  String bioText;
  
  String quoteText;
  String quoteAuthor;
  String quoteImage;
  
  String pillar1Title;
  String pillar1Desc;
  String pillar2Title;
  String pillar2Desc;
  String pillar3Title;
  String pillar3Desc;
  
  String ctaTitle;
  String ctaSubtitle;
  String ctaButtonText;

  AboutKathaPageData({
    this.heroBadge = 'ABOUT KATHA &',
    this.heroTitle = 'PU. JIGNESH DADA (RADHE RADHE)',
    this.heroSubtitle = 'A divine journey of knowledge, devotion and self-realization through Shrimad Bhagwat Katha.',
    this.heroImage = '',
    this.bioText = '',
    this.quoteText = 'Bhagwat Katha is not just a narration, it is a life transformation. It connects the soul with the supreme through the path of devotion.',
    this.quoteAuthor = 'Jignesh Dada',
    this.quoteImage = '',
    this.pillar1Title = 'OUR KATHA',
    this.pillar1Desc = 'Shrimad Bhagwat Katha is a timeless treasure that enlightens the heart, removes darkness and shows us the path of truth, devotion and righteous living.',
    this.pillar2Title = 'OUR MISSION',
    this.pillar2Desc = 'To spread the divine wisdom of Bhagwat through Katha, inspire devotion, nurture values and bring positive change in society.',
    this.pillar3Title = 'OUR VISION',
    this.pillar3Desc = 'A world filled with love, peace, compassion and righteousness where every soul walks the path of spirituality and service.',
    this.ctaTitle = 'Join us in this Divine Journey',
    this.ctaSubtitle = 'Listen, reflect and experience the nectar of Bhagwat Katha. Let devotion lead your life towards peace and purpose.',
    this.ctaButtonText = 'EXPLORE KATHA',
  });

  Map<String, dynamic> toMap() => {
    'heroBadge': heroBadge,
    'heroTitle': heroTitle,
    'heroSubtitle': heroSubtitle,
    'heroImage': heroImage,
    'bioText': bioText,
    'quoteText': quoteText,
    'quoteAuthor': quoteAuthor,
    'quoteImage': quoteImage,
    'pillar1Title': pillar1Title,
    'pillar1Desc': pillar1Desc,
    'pillar2Title': pillar2Title,
    'pillar2Desc': pillar2Desc,
    'pillar3Title': pillar3Title,
    'pillar3Desc': pillar3Desc,
    'ctaTitle': ctaTitle,
    'ctaSubtitle': ctaSubtitle,
    'ctaButtonText': ctaButtonText,
  };

  factory AboutKathaPageData.fromMap(Map<String, dynamic> map) => AboutKathaPageData(
    heroBadge: map['heroBadge'] ?? 'ABOUT KATHA &',
    heroTitle: map['heroTitle'] ?? 'PU. JIGNESH DADA (RADHE RADHE)',
    heroSubtitle: map['heroSubtitle'] ?? 'A divine journey of knowledge, devotion and self-realization through Shrimad Bhagwat Katha.',
    heroImage: map['heroImage'] ?? map['topHeaderImage'] ?? '',
    bioText: map['bioText'] ?? map['midSectionPara1'] ?? '',
    quoteText: map['quoteText'] ?? 'Bhagwat Katha is not just a narration, it is a life transformation. It connects the soul with the supreme through the path of devotion.',
    quoteAuthor: map['quoteAuthor'] ?? 'Jignesh Dada',
    quoteImage: map['quoteImage'] ?? map['midSectionImage'] ?? '',
    pillar1Title: map['pillar1Title'] ?? 'OUR KATHA',
    pillar1Desc: map['pillar1Desc'] ?? 'Shrimad Bhagwat Katha is a timeless treasure that enlightens the heart, removes darkness and shows us the path of truth, devotion and righteous living.',
    pillar2Title: map['pillar2Title'] ?? 'OUR MISSION',
    pillar2Desc: map['pillar2Desc'] ?? 'To spread the divine wisdom of Bhagwat through Katha, inspire devotion, nurture values and bring positive change in society.',
    pillar3Title: map['pillar3Title'] ?? 'OUR VISION',
    pillar3Desc: map['pillar3Desc'] ?? 'A world filled with love, peace, compassion and righteousness where every soul walks the path of spirituality and service.',
    ctaTitle: map['ctaTitle'] ?? 'Join us in this Divine Journey',
    ctaSubtitle: map['ctaSubtitle'] ?? 'Listen, reflect and experience the nectar of Bhagwat Katha. Let devotion lead your life towards peace and purpose.',
    ctaButtonText: map['ctaButtonText'] ?? 'EXPLORE KATHA',
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

class VideoGalleryEntry {
  String title;
  String youtubeUrl;
  VideoGalleryEntry({this.title = '', this.youtubeUrl = ''});
  Map<String, dynamic> toMap() => {'title': title, 'youtubeUrl': youtubeUrl};
  factory VideoGalleryEntry.fromMap(Map<String, dynamic> map) =>
      VideoGalleryEntry(
        title: map['title'] ?? '',
        youtubeUrl: map['youtubeUrl'] ?? '',
      );

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
    return videoId.isNotEmpty
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : 'https://via.placeholder.com/300x200';
  }
}

class VideoCategory {
  String categoryTitle;
  List<VideoGalleryEntry> videos;
  VideoCategory({this.categoryTitle = '', List<VideoGalleryEntry>? videos})
    : videos = videos ?? [];

  Map<String, dynamic> toMap() => {
    'categoryTitle': categoryTitle,
    'videos': videos.map((v) => v.toMap()).toList(),
  };

  factory VideoCategory.fromMap(Map<String, dynamic> map) => VideoCategory(
    categoryTitle: map['categoryTitle'] ?? '',
    videos: (map['videos'] as List? ?? [])
        .map((v) => VideoGalleryEntry.fromMap(v))
        .toList(),
  );
}

class VideoGalleryPageData {
  String headerImageUrl;
  List<VideoCategory> categories;
  VideoGalleryPageData({
    this.headerImageUrl = '',
    List<VideoCategory>? categories,
  }) : categories = categories ?? [];

  Map<String, dynamic> toMap() => {
    'headerImageUrl': headerImageUrl,
    'categories': categories.map((c) => c.toMap()).toList(),
  };

  factory VideoGalleryPageData.fromMap(Map<String, dynamic> map) =>
      VideoGalleryPageData(
        headerImageUrl: map['headerImageUrl'] ?? '',
        categories: (map['categories'] as List? ?? [])
            .map((c) => VideoCategory.fromMap(c))
            .toList(),
      );
}

class PhotoGallerySection {
  String heading;
  List<String> photoUrls;

  PhotoGallerySection({this.heading = '', List<String>? photoUrls})
      : photoUrls = photoUrls ?? [];

  Map<String, dynamic> toMap() => {
        'heading': heading,
        'photoUrls': photoUrls,
      };

  factory PhotoGallerySection.fromMap(Map<String, dynamic> map) =>
      PhotoGallerySection(
        heading: map['heading'] ?? '',
        photoUrls: List<String>.from(map['photoUrls'] ?? []),
      );
}

class PhotoGalleryPageData {
  String title;
  String headerImageUrl;
  List<PhotoGallerySection> sections;

  PhotoGalleryPageData({
    this.title = 'Gallery',
    this.headerImageUrl = '',
    List<PhotoGallerySection>? sections,
  }) : sections = sections ?? [
          PhotoGallerySection(heading: 'Bapu & Ram Katha'),
          PhotoGallerySection(heading: 'Temples in Taljagrda'),
        ];

  Map<String, dynamic> toMap() => {
        'title': title,
        'headerImageUrl': headerImageUrl,
        'sections': sections.map((c) => c.toMap()).toList(),
      };

  factory PhotoGalleryPageData.fromMap(Map<String, dynamic> map) =>
      PhotoGalleryPageData(
        title: map['title'] ?? 'Gallery',
        headerImageUrl: map['headerImageUrl'] ?? '',
        sections: (map['sections'] as List? ?? map['categories'] as List? ?? [])
            .map((c) => PhotoGallerySection.fromMap(c))
            .toList(),
      );
}
