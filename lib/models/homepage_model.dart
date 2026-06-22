class WebsiteSettings {
  String name;
  String tagline;
  String? logoUrl;
  String? faviconUrl;

  WebsiteSettings({
    this.name = '',
    this.tagline = '',
    this.logoUrl,
    this.faviconUrl,
  });
}

class NoticeBar {
  bool enabled;
  String text;
  String link;
  bool openInNewTab;

  NoticeBar({
    this.enabled = false,
    this.text = '',
    this.link = '',
    this.openInNewTab = false,
  });
}

class HeroBanner {
  String? imageUrl;
  String? mobileImageUrl;
  String heading;
  String subHeading;
  String button1Text;
  String button1Link;
  String button2Text;
  String button2Link;
  int sortOrder;
  bool status;

  HeroBanner({
    this.imageUrl,
    this.mobileImageUrl,
    this.heading = '',
    this.subHeading = '',
    this.button1Text = '',
    this.button1Link = '',
    this.button2Text = '',
    this.button2Link = '',
    this.sortOrder = 0,
    this.status = true,
  });
}

class LiveKatha {
  bool showLiveSection;
  String title;
  String description;
  String youtubeLiveUrl;
  String? thumbnail;

  LiveKatha({
    this.showLiveSection = false,
    this.title = '',
    this.description = '',
    this.youtubeLiveUrl = '',
    this.thumbnail,
  });
}

class AboutDada {
  String title;
  String? photoUrl;
  String description;
  String readMoreText;
  String readMoreLink;

  AboutDada({
    this.title = '',
    this.photoUrl,
    this.description = '',
    this.readMoreText = '',
    this.readMoreLink = '',
  });
}

class UpcomingKatha {
  String? bannerUrl;
  String name;
  String type;
  String location;
  String state;
  String country;
  DateTime? startDate;
  DateTime? endDate;
  String googleMapLink;
  String registrationLink;
  String description;
  bool status;

  UpcomingKatha({
    this.bannerUrl,
    this.name = '',
    this.type = 'General',
    this.location = '',
    this.state = '',
    this.country = '',
    this.startDate,
    this.endDate,
    this.googleMapLink = '',
    this.registrationLink = '',
    this.description = '',
    this.status = true,
  });
}

class LatestVideo {
  String? thumbnail;
  String title;
  String youtubeUrl;
  String duration;
  DateTime? publishDate;
  bool status;

  LatestVideo({
    this.thumbnail,
    this.title = '',
    this.youtubeUrl = '',
    this.duration = '',
    this.publishDate,
    this.status = true,
  });
}

class Suvichar {
  String text;
  String author;
  String? backgroundImage;

  Suvichar({
    this.text = '',
    this.author = '',
    this.backgroundImage,
  });
}

class GalleryPhoto {
  String? photoUrl;
  String title;
  int sortOrder;

  GalleryPhoto({
    this.photoUrl,
    this.title = '',
    this.sortOrder = 0,
  });
}

class Statistics {
  int totalKathas;
  int totalCountries;
  int totalCities;
  int totalDevotees;

  Statistics({
    this.totalKathas = 0,
    this.totalCountries = 0,
    this.totalCities = 0,
    this.totalDevotees = 0,
  });
}

class SocialMedia {
  String facebook;
  String instagram;
  String youtube;
  String whatsapp;
  String telegram;
  String twitter;

  SocialMedia({
    this.facebook = '',
    this.instagram = '',
    this.youtube = '',
    this.whatsapp = '',
    this.telegram = '',
    this.twitter = '',
  });
}

class ContactInfo {
  String address;
  String mobile;
  String whatsapp;
  String email;
  String googleMapLink;

  ContactInfo({
    this.address = '',
    this.mobile = '',
    this.whatsapp = '',
    this.email = '',
    this.googleMapLink = '',
  });
}

class FooterSettings {
  String description;
  String copyrightText;
  String privacyPolicyLink;
  String termsConditionsLink;

  FooterSettings({
    this.description = '',
    this.copyrightText = '',
    this.privacyPolicyLink = '',
    this.termsConditionsLink = '',
  });
}
