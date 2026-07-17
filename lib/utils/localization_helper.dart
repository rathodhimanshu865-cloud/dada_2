import 'package:flutter/material.dart';
import 'package:dada_2/l10n/app_localizations.dart';

extension DynamicLocalize on String {
  String dynamicTr(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return this;
    
    final key = trim();
    
    switch (key) {
      case 'Home': return localizations.home;
      case 'About Dada': return localizations.aboutDada;
      case 'Katha': return localizations.katha;
      case 'Shrimad Bhagvat Katha': return localizations.shrimadBhagvatKatha;
      case 'Devi Bhagvat Katha': return localizations.deviBhagvatKatha;
      case 'Shivmahapuran Katha': return localizations.shivmahapuranKatha;
      case 'Full Katha List': return localizations.fullKathaList;
      case 'Upcoming Kathas': return localizations.upcomingKathas;
      case 'Stotra / Bhajan': return localizations.stotraBhajan;
      case 'Gallery': return localizations.gallery;
      case 'Photo Gallery': return localizations.photoGallery;
      case 'Video Gallery': return localizations.videoGallery;
      case 'News Gallery': return localizations.newsGallery;
      case 'Contact': return localizations.contact;
      case 'Contact Us': return localizations.contactUs;
      case 'ENQUIRIES': return localizations.enquiries;
      case 'This site is an informative website, therefore please fill in the form below for any technical website related queries only.': 
        return localizations.siteQueryDisclaimer;
      case 'Kathas List': return localizations.kathasList;
      case 'SEARCH KATHAS': return localizations.searchKathas;
      case 'WATCH ON YOUTUBE': return localizations.watchOnYoutube;
      case 'READ MORE': return localizations.readMore;
      case 'No photos added to this section yet.': return localizations.noPhotosAdded;
      case 'More Details': return localizations.moreDetails;
      case 'CLOSE': return localizations.close;
      case 'READ FULL BIOGRAPHY': return localizations.readFullBiography;
      case 'Image link copied to clipboard!': return localizations.imageLinkCopied;
      case 'VIEW ALL VIDEOS': return localizations.viewAllVideos;
      case 'VIEW ALL NEWS': return localizations.viewAllNews;
      case 'EXPLORE FULL GALLERY': return localizations.exploreFullGallery;
      case 'EXPLORE KATHA JOURNEY': return localizations.exploreKathaJourney;
      case 'VIEW ALL UPCOMING KATHAS': return localizations.viewAllUpcomingKathas;
      case 'English': return localizations.english;
      case 'Gujarati': return localizations.gujarati;
      case 'Hindi': return localizations.hindi;
      case 'SPIRITUAL CALENDAR': return localizations.spiritualCalendar;
      case 'LIST VIEW': return localizations.listView;
      case 'CALENDAR': return localizations.calendar;
      case 'DETAILS >': return localizations.detailsArrow;
      case 'WATCH & REFLECT': return localizations.watchAndReflect;
      case 'Latest Videos': return localizations.latestVideos;
      case 'YOUTUBE DISCOURSE': return localizations.youtubeDiscourse;
      case 'DISCOVER THE JOURNEY': return localizations.discoverTheJourney;
      case 'Please verify that you are not a robot.': return localizations.verifyNotRobot;
      case 'Message saved and email draft opened.': return localizations.messageSavedEmailOpened;
      case 'Website Contact Form Message': return localizations.websiteContactFormMessage;
      case 'Name *': return localizations.nameLabel;
      case 'Email address *': return localizations.emailLabel;
      case 'Tel/Mobile# *': return localizations.telMobileLabel;
      case 'Country *': return localizations.countryLabel;
      case 'Message *': return localizations.messageLabel;
      case "I'm not a robot": return localizations.imNotRobot;
      case 'SENDING...': return localizations.sending;
      case 'SEND MESSAGE': return localizations.sendMessage;
      case 'Required': return localizations.requiredField;
      case 'Invalid email': return localizations.invalidEmail;
      case 'Home > News': return localizations.homeNews;
      case 'Latest News': return localizations.latestNews;
      
      // Footer links
      case 'ORGANIZATION': return localizations.organization;
      case 'RESOURCES': return localizations.resources;
      case 'Admin Panel': return localizations.adminPanel;
      case 'Privacy Policy': return localizations.privacyPolicy;
      case 'Terms of Service': return localizations.termsOfService;
      case 'Cookie Policy': return localizations.cookiePolicy;

      // Katha table / list page items
      case 'All Kathas': return localizations.allKathas;
      case 'ID': return localizations.id;
      case 'YEAR': return localizations.year;
      case 'DATES': return localizations.dates;
      case 'TOPIC / HEADING': return localizations.topicHeading;
      case 'LOCATION': return localizations.location;
      case 'COUNTRY': return localizations.country;
      case 'LANG': return localizations.lang;
      case 'PLAYLIST': return localizations.playlist;
      case 'ACTION': return localizations.action;
      case 'Details for this katha will be updated soon.': return localizations.kathaDetailsFallback;

      default:
        return this;
    }
  }
}
