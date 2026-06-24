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
