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
        : 'https://via.placeholder.com/300x200';
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
    this.heroBadge = 'KATHA OVERVIEW',
    this.heroTitle = 'PU. JIGNESH DADA',
    this.heroDesc1 = 'A divine journey through ancient wisdom.',
    this.heroDesc2 = 'Exploring the path of devotion and spirituality.',
    this.heroImage = '',
    this.bioText = '',
    this.quoteText = '',
    this.quoteAuthor = 'Jignesh Dada',
    this.quoteImage = '',
    this.highlight1Title = 'CORE HIGHLIGHT 1',
    this.highlight1Desc = 'Detailed description of spiritual significance.',
    this.highlight2Title = 'CORE HIGHLIGHT 2',
    this.highlight2Desc = 'Detailed description of cultural impact.',
    this.highlight3Title = 'CORE HIGHLIGHT 3',
    this.highlight3Desc = 'Detailed description of personal transformation.',
    this.ctaTitle = 'Join the Journey',
    this.ctaSubtitle = 'Experience the divinity.',
    this.ctaButtonText = 'EXPLORE MORE',
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
    heroDesc1: map['heroDesc1'] ?? map['heroSubtitle'] ?? '',
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
