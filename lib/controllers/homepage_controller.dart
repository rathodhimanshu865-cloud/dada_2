import 'package:flutter/material.dart';
import '../models/homepage_model.dart';

class HomePageController extends ChangeNotifier {
  WebsiteSettings websiteSettings = WebsiteSettings();
  NoticeBar noticeBar = NoticeBar();
  List<HeroBanner> heroBanners = [];
  LiveKatha liveKatha = LiveKatha();
  AboutDada aboutDada = AboutDada();
  List<UpcomingKatha> upcomingKathas = [];
  List<LatestVideo> latestVideos = [];
  Suvichar suvichar = Suvichar();
  List<GalleryPhoto> galleryPhotos = [];
  Statistics statistics = Statistics();
  SocialMedia socialMedia = SocialMedia();
  ContactInfo contactInfo = ContactInfo();
  FooterSettings footerSettings = FooterSettings();

  // Methods to update state
  void updateWebsiteSettings(WebsiteSettings settings) {
    websiteSettings = settings;
    notifyListeners();
  }

  void updateNoticeBar(NoticeBar bar) {
    noticeBar = bar;
    notifyListeners();
  }

  void addHeroBanner(HeroBanner banner) {
    heroBanners.add(banner);
    notifyListeners();
  }

  void removeHeroBanner(int index) {
    heroBanners.removeAt(index);
    notifyListeners();
  }

  void updateLiveKatha(LiveKatha katha) {
    liveKatha = katha;
    notifyListeners();
  }

  void updateAboutDada(AboutDada about) {
    aboutDada = about;
    notifyListeners();
  }

  void addUpcomingKatha(UpcomingKatha katha) {
    upcomingKathas.add(katha);
    notifyListeners();
  }

  void removeUpcomingKatha(int index) {
    upcomingKathas.removeAt(index);
    notifyListeners();
  }

  void addLatestVideo(LatestVideo video) {
    latestVideos.add(video);
    notifyListeners();
  }

  void removeLatestVideo(int index) {
    latestVideos.removeAt(index);
    notifyListeners();
  }

  void updateSuvichar(Suvichar s) {
    suvichar = s;
    notifyListeners();
  }

  void addGalleryPhoto(GalleryPhoto photo) {
    galleryPhotos.add(photo);
    notifyListeners();
  }

  void removeGalleryPhoto(int index) {
    galleryPhotos.removeAt(index);
    notifyListeners();
  }

  void updateStatistics(Statistics stats) {
    statistics = stats;
    notifyListeners();
  }

  void updateSocialMedia(SocialMedia social) {
    socialMedia = social;
    notifyListeners();
  }

  void updateContactInfo(ContactInfo contact) {
    contactInfo = contact;
    notifyListeners();
  }

  void updateFooterSettings(FooterSettings footer) {
    footerSettings = footer;
    notifyListeners();
  }

  void saveAll() {
    debugPrint('Saving all settings...');
  }
}
