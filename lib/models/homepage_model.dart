class WebsiteSettings {
  String name;
  String logoUrl;
  WebsiteSettings({this.name = '', this.logoUrl = ''});
  Map<String, dynamic> toMap() => {'name': name, 'logoUrl': logoUrl};
  factory WebsiteSettings.fromMap(Map<String, dynamic> map) => WebsiteSettings(
    name: map['name'] ?? '',
    logoUrl: map['logoUrl'] ?? '',
  );
}

class HeroSection {
  List<String> bannerUrls;
  HeroSection({List<String>? bannerUrls}) : this.bannerUrls = bannerUrls ?? List.filled(8, '');
  Map<String, dynamic> toMap() => {'bannerUrls': bannerUrls};
  factory HeroSection.fromMap(Map<String, dynamic> map) => HeroSection(
    bannerUrls: List<String>.from(map['bannerUrls'] ?? []),
  );
}

class UpcomingKatha {
  String kathaNumber;
  String name;
  String dateString;
  DateTime? startDate;
  DateTime? endDate;

  UpcomingKatha({
    this.kathaNumber = '',
    this.name = '',
    this.dateString = '',
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'kathaNumber': kathaNumber,
    'name': name,
    'dateString': dateString,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory UpcomingKatha.fromMap(Map<String, dynamic> map) => UpcomingKatha(
    kathaNumber: map['kathaNumber'] ?? '',
    name: map['name'] ?? '',
    dateString: map['dateString'] ?? '',
    startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
    endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
  );
}

class AboutSection {
  String photoUrl;
  String description;
  AboutSection({this.photoUrl = '', this.description = ''});
  Map<String, dynamic> toMap() => {'photoUrl': photoUrl, 'description': description};
  factory AboutSection.fromMap(Map<String, dynamic> map) => AboutSection(
    photoUrl: map['photoUrl'] ?? '',
    description: map['description'] ?? '',
  );
}

class DailySuvichar {
  String imageUrl;
  String date;

  DailySuvichar({this.imageUrl = '', this.date = ''});

  Map<String, dynamic> toMap() => {
    'imageUrl': imageUrl,
    'date': date,
  };

  factory DailySuvichar.fromMap(Map<String, dynamic> map) => DailySuvichar(
    imageUrl: map['imageUrl'] ?? '',
    date: map['date'] ?? '',
  );
}

class VideoItem {
  String title;
  String youtubeUrl;

  VideoItem({this.title = '', this.youtubeUrl = ''});

  Map<String, dynamic> toMap() => {'title': title, 'youtubeUrl': youtubeUrl};

  factory VideoItem.fromMap(Map<String, dynamic> map) => VideoItem(
    title: map['title'] ?? '',
    youtubeUrl: map['youtubeUrl'] ?? '',
  );

  // Helper to extract YouTube Thumbnail from any YouTube/Shorts URL
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
  RamKathaSection({this.title = 'Ram Katha', this.description1 = '', this.description2 = '', this.photoUrl = ''});
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
  FooterData({this.description = '', this.copyright = ''});
  Map<String, dynamic> toMap() => {'description': description, 'copyright': copyright};
  factory FooterData.fromMap(Map<String, dynamic> map) => FooterData(
    description: map['description'] ?? '',
    copyright: map['copyright'] ?? '',
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
  String pdfLink;
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
    this.pdfLink = '',
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
    'pdfLink': pdfLink,
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
    pdfLink: map['pdfLink'] ?? '',
    description: map['description'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
  );
}


class AboutKathaPageData {
  String topHeaderImage;
  String title;
  String mainItalicDesc;
  String subDescCol1;
  String subDescCol2;
  String subDescCol3;
  
  // Middle section with image and text
  String midSectionImage;
  String midSectionTitle;
  String midSectionPara1;
  String midSectionPara2;

  // Bottom section with calligraphy
  String signatureImage; // For "Satya Prem Karuna" image
  String bottomPara1;
  String bottomPara2;
  String largeBottomImage;

  AboutKathaPageData({
    this.topHeaderImage = '',
    this.title = 'About Ram Katha & Morari Bapu',
    this.mainItalicDesc = '',
    this.subDescCol1 = '',
    this.subDescCol2 = '',
    this.subDescCol3 = '',
    this.midSectionImage = '',
    this.midSectionTitle = '',
    this.midSectionPara1 = '',
    this.midSectionPara2 = '',
    this.signatureImage = '',
    this.bottomPara1 = '',
    this.bottomPara2 = '',
    this.largeBottomImage = '',
  });

  Map<String, dynamic> toMap() => {
    'topHeaderImage': topHeaderImage,
    'title': title,
    'mainItalicDesc': mainItalicDesc,
    'subDescCol1': subDescCol1,
    'subDescCol2': subDescCol2,
    'subDescCol3': subDescCol3,
    'midSectionImage': midSectionImage,
    'midSectionTitle': midSectionTitle,
    'midSectionPara1': midSectionPara1,
    'midSectionPara2': midSectionPara2,
    'signatureImage': signatureImage,
    'bottomPara1': bottomPara1,
    'bottomPara2': bottomPara2,
    'largeBottomImage': largeBottomImage,
  };

  factory AboutKathaPageData.fromMap(Map<String, dynamic> map) => AboutKathaPageData(
    topHeaderImage: map['topHeaderImage'] ?? '',
    title: map['title'] ?? 'About Ram Katha & Morari Bapu',
    mainItalicDesc: map['mainItalicDesc'] ?? '',
    subDescCol1: map['subDescCol1'] ?? '',
    subDescCol2: map['subDescCol2'] ?? '',
    subDescCol3: map['subDescCol3'] ?? '',
    midSectionImage: map['midSectionImage'] ?? '',
    midSectionTitle: map['midSectionTitle'] ?? '',
    midSectionPara1: map['midSectionPara1'] ?? '',
    midSectionPara2: map['midSectionPara2'] ?? '',
    signatureImage: map['signatureImage'] ?? '',
    bottomPara1: map['bottomPara1'] ?? '',
    bottomPara2: map['bottomPara2'] ?? '',
    largeBottomImage: map['largeBottomImage'] ?? '',
  );
}

class KathaListPageData {
  String bannerImageUrl;

  KathaListPageData({this.bannerImageUrl = ''});

  Map<String, dynamic> toMap() => {'bannerImageUrl': bannerImageUrl};

  factory KathaListPageData.fromMap(Map<String, dynamic> map) => KathaListPageData(
    bannerImageUrl: map['bannerImageUrl'] ?? '',
  );
}


