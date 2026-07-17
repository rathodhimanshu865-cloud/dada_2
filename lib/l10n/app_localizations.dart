import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @aboutDada.
  ///
  /// In en, this message translates to:
  /// **'About Dada'**
  String get aboutDada;

  /// No description provided for @katha.
  ///
  /// In en, this message translates to:
  /// **'Katha'**
  String get katha;

  /// No description provided for @shrimadBhagvatKatha.
  ///
  /// In en, this message translates to:
  /// **'Shrimad Bhagvat Katha'**
  String get shrimadBhagvatKatha;

  /// No description provided for @deviBhagvatKatha.
  ///
  /// In en, this message translates to:
  /// **'Devi Bhagvat Katha'**
  String get deviBhagvatKatha;

  /// No description provided for @shivmahapuranKatha.
  ///
  /// In en, this message translates to:
  /// **'Shivmahapuran Katha'**
  String get shivmahapuranKatha;

  /// No description provided for @fullKathaList.
  ///
  /// In en, this message translates to:
  /// **'Full Katha List'**
  String get fullKathaList;

  /// No description provided for @upcomingKathas.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Kathas'**
  String get upcomingKathas;

  /// No description provided for @stotraBhajan.
  ///
  /// In en, this message translates to:
  /// **'Stotra / Bhajan'**
  String get stotraBhajan;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo Gallery'**
  String get photoGallery;

  /// No description provided for @videoGallery.
  ///
  /// In en, this message translates to:
  /// **'Video Gallery'**
  String get videoGallery;

  /// No description provided for @newsGallery.
  ///
  /// In en, this message translates to:
  /// **'News Gallery'**
  String get newsGallery;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @enquiries.
  ///
  /// In en, this message translates to:
  /// **'ENQUIRIES'**
  String get enquiries;

  /// No description provided for @siteQueryDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This site is an informative website, therefore please fill in the form below for any technical website related queries only.'**
  String get siteQueryDisclaimer;

  /// No description provided for @kathasList.
  ///
  /// In en, this message translates to:
  /// **'Kathas List'**
  String get kathasList;

  /// No description provided for @searchKathas.
  ///
  /// In en, this message translates to:
  /// **'SEARCH KATHAS'**
  String get searchKathas;

  /// No description provided for @watchOnYoutube.
  ///
  /// In en, this message translates to:
  /// **'WATCH ON YOUTUBE'**
  String get watchOnYoutube;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'READ MORE'**
  String get readMore;

  /// No description provided for @noPhotosAdded.
  ///
  /// In en, this message translates to:
  /// **'No photos added to this section yet.'**
  String get noPhotosAdded;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More Details'**
  String get moreDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @readFullBiography.
  ///
  /// In en, this message translates to:
  /// **'READ FULL BIOGRAPHY'**
  String get readFullBiography;

  /// No description provided for @imageLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Image link copied to clipboard!'**
  String get imageLinkCopied;

  /// No description provided for @viewAllVideos.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL VIDEOS'**
  String get viewAllVideos;

  /// No description provided for @viewAllNews.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL NEWS'**
  String get viewAllNews;

  /// No description provided for @exploreFullGallery.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE FULL GALLERY'**
  String get exploreFullGallery;

  /// No description provided for @exploreKathaJourney.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE KATHA JOURNEY'**
  String get exploreKathaJourney;

  /// No description provided for @viewAllUpcomingKathas.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL UPCOMING KATHAS'**
  String get viewAllUpcomingKathas;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @spiritualCalendar.
  ///
  /// In en, this message translates to:
  /// **'SPIRITUAL CALENDAR'**
  String get spiritualCalendar;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'LIST VIEW'**
  String get listView;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'CALENDAR'**
  String get calendar;

  /// No description provided for @detailsArrow.
  ///
  /// In en, this message translates to:
  /// **'DETAILS >'**
  String get detailsArrow;

  /// No description provided for @watchAndReflect.
  ///
  /// In en, this message translates to:
  /// **'WATCH & REFLECT'**
  String get watchAndReflect;

  /// No description provided for @latestVideos.
  ///
  /// In en, this message translates to:
  /// **'Latest Videos'**
  String get latestVideos;

  /// No description provided for @youtubeDiscourse.
  ///
  /// In en, this message translates to:
  /// **'YOUTUBE DISCOURSE'**
  String get youtubeDiscourse;

  /// No description provided for @discoverTheJourney.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER THE JOURNEY'**
  String get discoverTheJourney;

  /// No description provided for @countCharacters.
  ///
  /// In en, this message translates to:
  /// **'{count} of 500 max characters.'**
  String countCharacters(int count);

  /// No description provided for @verifyNotRobot.
  ///
  /// In en, this message translates to:
  /// **'Please verify that you are not a robot.'**
  String get verifyNotRobot;

  /// No description provided for @messageSavedEmailOpened.
  ///
  /// In en, this message translates to:
  /// **'Message saved and email draft opened.'**
  String get messageSavedEmailOpened;

  /// No description provided for @websiteContactFormMessage.
  ///
  /// In en, this message translates to:
  /// **'Website Contact Form Message'**
  String get websiteContactFormMessage;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address *'**
  String get emailLabel;

  /// No description provided for @telMobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Tel/Mobile# *'**
  String get telMobileLabel;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country *'**
  String get countryLabel;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message *'**
  String get messageLabel;

  /// No description provided for @imNotRobot.
  ///
  /// In en, this message translates to:
  /// **'I\'m not a robot'**
  String get imNotRobot;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'SENDING...'**
  String get sending;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'SEND MESSAGE'**
  String get sendMessage;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @homeNews.
  ///
  /// In en, this message translates to:
  /// **'Home > News'**
  String get homeNews;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get latestNews;

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'ADMIN LOGIN'**
  String get adminLogin;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid Credentials'**
  String get invalidCredentials;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'ORGANIZATION'**
  String get organization;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'RESOURCES'**
  String get resources;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @cookiePolicy.
  ///
  /// In en, this message translates to:
  /// **'Cookie Policy'**
  String get cookiePolicy;

  /// No description provided for @allKathas.
  ///
  /// In en, this message translates to:
  /// **'All Kathas'**
  String get allKathas;

  /// No description provided for @searchKathaPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter Katha title, Year, or Location...'**
  String get searchKathaPlaceholder;

  /// No description provided for @kathasFound.
  ///
  /// In en, this message translates to:
  /// **'{count} KATHAS FOUND'**
  String kathasFound(int count);

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'YEAR'**
  String get year;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'DATES'**
  String get dates;

  /// No description provided for @topicHeading.
  ///
  /// In en, this message translates to:
  /// **'TOPIC / HEADING'**
  String get topicHeading;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get location;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'COUNTRY'**
  String get country;

  /// No description provided for @lang.
  ///
  /// In en, this message translates to:
  /// **'LANG'**
  String get lang;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'PLAYLIST'**
  String get playlist;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'ACTION'**
  String get action;

  /// No description provided for @kathaDetailsFallback.
  ///
  /// In en, this message translates to:
  /// **'Details for this katha will be updated soon.'**
  String get kathaDetailsFallback;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get mission;

  /// No description provided for @bhagvatKatha.
  ///
  /// In en, this message translates to:
  /// **'Bhagvat Katha'**
  String get bhagvatKatha;

  /// No description provided for @shivmahapuran.
  ///
  /// In en, this message translates to:
  /// **'Shivmahapuran'**
  String get shivmahapuran;

  /// No description provided for @divineDiscourses.
  ///
  /// In en, this message translates to:
  /// **'DIVINE DISCOURSES'**
  String get divineDiscourses;

  /// No description provided for @shreemadBhagwatKatha.
  ///
  /// In en, this message translates to:
  /// **'Shreemad Bhagwat Katha'**
  String get shreemadBhagwatKatha;

  /// No description provided for @dadasDailySuvichar.
  ///
  /// In en, this message translates to:
  /// **'DADA\'S DAILY SUVICHAR'**
  String get dadasDailySuvichar;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @openToDownload.
  ///
  /// In en, this message translates to:
  /// **'Open to Download'**
  String get openToDownload;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
