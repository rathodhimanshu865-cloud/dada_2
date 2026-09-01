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

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

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

  /// No description provided for @latestUpdates.
  ///
  /// In en, this message translates to:
  /// **'LATEST UPDATES'**
  String get latestUpdates;

  /// No description provided for @newsAndEvents.
  ///
  /// In en, this message translates to:
  /// **'News & Events'**
  String get newsAndEvents;

  /// No description provided for @homeGalleryVideos.
  ///
  /// In en, this message translates to:
  /// **'Home > Gallery > Videos'**
  String get homeGalleryVideos;

  /// No description provided for @homeGalleryPhotos.
  ///
  /// In en, this message translates to:
  /// **'Home > Gallery > Photos'**
  String get homeGalleryPhotos;

  /// No description provided for @homeStotra.
  ///
  /// In en, this message translates to:
  /// **'Home > Stotra / Bhajan / Aarti'**
  String get homeStotra;

  /// No description provided for @homeKathasUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Home > Kathas > Upcoming Kathas'**
  String get homeKathasUpcoming;

  /// No description provided for @upcomingKathas2026.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Kathas 2026'**
  String get upcomingKathas2026;

  /// No description provided for @kathaPrefix.
  ///
  /// In en, this message translates to:
  /// **'Katha'**
  String get kathaPrefix;

  /// No description provided for @kathaDate.
  ///
  /// In en, this message translates to:
  /// **'Katha Date'**
  String get kathaDate;

  /// No description provided for @kathaTiming.
  ///
  /// In en, this message translates to:
  /// **'Katha Timing'**
  String get kathaTiming;

  /// No description provided for @kathaLocation.
  ///
  /// In en, this message translates to:
  /// **'Katha Location'**
  String get kathaLocation;

  /// No description provided for @kathaHosting.
  ///
  /// In en, this message translates to:
  /// **'Katha Hosting'**
  String get kathaHosting;

  /// No description provided for @sacredMoments.
  ///
  /// In en, this message translates to:
  /// **'SACRED MOMENTS'**
  String get sacredMoments;

  /// No description provided for @divineGallery.
  ///
  /// In en, this message translates to:
  /// **'Divine Gallery'**
  String get divineGallery;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @idColumn.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idColumn;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'NAME / TITLE'**
  String get nameTitle;

  /// No description provided for @englishCol.
  ///
  /// In en, this message translates to:
  /// **'ENGLISH'**
  String get englishCol;

  /// No description provided for @hindiCol.
  ///
  /// In en, this message translates to:
  /// **'HINDI'**
  String get hindiCol;

  /// No description provided for @gujaratiCol.
  ///
  /// In en, this message translates to:
  /// **'GUJARATI'**
  String get gujaratiCol;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Stock'**
  String get inventory;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders & Dispatch'**
  String get orders;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments & COD'**
  String get payments;

  /// No description provided for @devotees.
  ///
  /// In en, this message translates to:
  /// **'Devotees / Users'**
  String get devotees;

  /// No description provided for @coupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons & Offers'**
  String get coupons;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Blessings'**
  String get reviews;

  /// No description provided for @storeSettings.
  ///
  /// In en, this message translates to:
  /// **'Store & Seva Settings'**
  String get storeSettings;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlaced;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @trackingInfo.
  ///
  /// In en, this message translates to:
  /// **'Tracking Info'**
  String get trackingInfo;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @sacredFoundations.
  ///
  /// In en, this message translates to:
  /// **'Sacred Foundations of Pu. Dada Seva'**
  String get sacredFoundations;

  /// No description provided for @exploreSacredProducts.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE PU. DADA SACRED PRODUCT COLLECTIONS →'**
  String get exploreSacredProducts;

  /// No description provided for @biographyDetailsFallback.
  ///
  /// In en, this message translates to:
  /// **'Full biography details will appear here as managed from the admin side.'**
  String get biographyDetailsFallback;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'ABOUT US'**
  String get aboutUs;

  /// No description provided for @anIntroduction.
  ///
  /// In en, this message translates to:
  /// **'AN INTRODUCTION'**
  String get anIntroduction;

  /// No description provided for @vision.
  ///
  /// In en, this message translates to:
  /// **'VISION'**
  String get vision;

  /// No description provided for @objective.
  ///
  /// In en, this message translates to:
  /// **'OBJECTIVE'**
  String get objective;

  /// No description provided for @signatureIdentity.
  ///
  /// In en, this message translates to:
  /// **'SIGNATURE IDENTITY'**
  String get signatureIdentity;

  /// No description provided for @pujyaDadaTeachings.
  ///
  /// In en, this message translates to:
  /// **'Pujya Dada Teachings'**
  String get pujyaDadaTeachings;

  /// No description provided for @sacredProducts.
  ///
  /// In en, this message translates to:
  /// **'Sacred Products'**
  String get sacredProducts;

  /// No description provided for @adminAccess.
  ///
  /// In en, this message translates to:
  /// **'Admin Access'**
  String get adminAccess;

  /// No description provided for @selectedLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectedLanguage;

  /// No description provided for @trackShipment.
  ///
  /// In en, this message translates to:
  /// **'TRACK SHIPMENT'**
  String get trackShipment;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'MY ORDERS'**
  String get myOrders;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'LOGIN / SIGN UP'**
  String get loginSignUp;

  /// No description provided for @sacredCatalogue.
  ///
  /// In en, this message translates to:
  /// **'SACRED CATALOGUE'**
  String get sacredCatalogue;

  /// No description provided for @searchProductPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name, SKU, or keyword...'**
  String get searchProductPlaceholder;

  /// No description provided for @showingSacredItems.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} sacred items in '**
  String showingSacredItems(int count);

  /// No description provided for @loadingSacredProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading sacred products...'**
  String get loadingSacredProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found in this category.'**
  String get noProductsFound;

  /// No description provided for @sortByAz.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortByAz;

  /// No description provided for @sortByPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortByPriceLow;

  /// No description provided for @sortByLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest Arrival'**
  String get sortByLatest;

  /// No description provided for @allSacredProducts.
  ///
  /// In en, this message translates to:
  /// **'All Sacred Products'**
  String get allSacredProducts;

  /// No description provided for @officialStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Official Pu. Jignesh Dada Devotional Store'**
  String get officialStoreLabel;

  /// No description provided for @exploreCollectionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore revered photo keychains, acrylic frames, home mandirs, and holy puja essentials.'**
  String get exploreCollectionsDesc;

  /// No description provided for @viewAllCollections.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL COLLECTIONS'**
  String get viewAllCollections;

  /// No description provided for @featuredProductsDesc.
  ///
  /// In en, this message translates to:
  /// **'Every item is crafted with devotion, checked for high structural durability, and energized with Vedic sanctification.'**
  String get featuredProductsDesc;

  /// No description provided for @browseCompleteCatalog.
  ///
  /// In en, this message translates to:
  /// **'BROWSE COMPLETE STORE CATALOG'**
  String get browseCompleteCatalog;

  /// No description provided for @vedicAssuranceLabel.
  ///
  /// In en, this message translates to:
  /// **'VEDIC ASSURANCE & PURITY SEAL'**
  String get vedicAssuranceLabel;

  /// No description provided for @sacredConsecrationTitle.
  ///
  /// In en, this message translates to:
  /// **'The Sacred Consecration Process'**
  String get sacredConsecrationTitle;

  /// No description provided for @vedicSanctityDesc.
  ///
  /// In en, this message translates to:
  /// **'We uphold complete sanctity from the artisan\'s hands to your puja room.'**
  String get vedicSanctityDesc;

  /// No description provided for @gangaJalTitle.
  ///
  /// In en, this message translates to:
  /// **'Ganga Jal & Chandan Snan'**
  String get gangaJalTitle;

  /// No description provided for @gangaJalDesc.
  ///
  /// In en, this message translates to:
  /// **'Articles are purified with sacred Haridwar Ganga jal and fragrant sandalwood paste.'**
  String get gangaJalDesc;

  /// No description provided for @vedicMantraTitle.
  ///
  /// In en, this message translates to:
  /// **'Vedic Mantra Archana'**
  String get vedicMantraTitle;

  /// No description provided for @vedicMantraDesc.
  ///
  /// In en, this message translates to:
  /// **'Energized by Vedic scholars chanting sacred protection and peace mantras.'**
  String get vedicMantraDesc;

  /// No description provided for @zeroBreakageTitle.
  ///
  /// In en, this message translates to:
  /// **'Zero-Breakage Transit'**
  String get zeroBreakageTitle;

  /// No description provided for @zeroBreakageDesc.
  ///
  /// In en, this message translates to:
  /// **'Multi-layer protective packaging & sanctified cloth wraps with free replacement assurance.'**
  String get zeroBreakageDesc;

  /// No description provided for @codAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery Available'**
  String get codAvailableTitle;

  /// No description provided for @codAvailableDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay with confidence upon doorstep delivery anywhere across India.'**
  String get codAvailableDesc;

  /// No description provided for @devoteeExperiences.
  ///
  /// In en, this message translates to:
  /// **'DEVOTEE EXPERIENCES'**
  String get devoteeExperiences;

  /// No description provided for @averageRatingText.
  ///
  /// In en, this message translates to:
  /// **'4.9 / 5 Average Rating across 15,000+ Blessed Homes'**
  String get averageRatingText;

  /// No description provided for @spiritualEssence.
  ///
  /// In en, this message translates to:
  /// **'SPIRITUAL ESSENCE'**
  String get spiritualEssence;

  /// No description provided for @sacredCatalog.
  ///
  /// In en, this message translates to:
  /// **'Sacred Catalog'**
  String get sacredCatalog;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popular;

  /// No description provided for @genuineStockLabel.
  ///
  /// In en, this message translates to:
  /// **'100% Genuine Atelier Stock'**
  String get genuineStockLabel;

  /// No description provided for @sanctifiedConsecrated.
  ///
  /// In en, this message translates to:
  /// **'Sanctified & Consecrated: Energized with holy temple mantras.'**
  String get sanctifiedConsecrated;

  /// No description provided for @inSanctifiedStock.
  ///
  /// In en, this message translates to:
  /// **'In Sanctified Stock — Auspicious 24-hr temple dispatch'**
  String get inSanctifiedStock;

  /// No description provided for @outOfStockSacred.
  ///
  /// In en, this message translates to:
  /// **'OUT OF STOCK — Sacred item currently unavailable'**
  String get outOfStockSacred;

  /// No description provided for @addToBag.
  ///
  /// In en, this message translates to:
  /// **'ADD TO BAG'**
  String get addToBag;

  /// No description provided for @instantSacredCheckout.
  ///
  /// In en, this message translates to:
  /// **'⚡ INSTANT SACRED CHECKOUT (COD / ONLINE)'**
  String get instantSacredCheckout;

  /// No description provided for @orderInquireWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Order / Inquire via WhatsApp'**
  String get orderInquireWhatsapp;

  /// No description provided for @deliveryPaymentAvailability.
  ///
  /// In en, this message translates to:
  /// **'Delivery & Payment Availability'**
  String get deliveryPaymentAvailability;

  /// No description provided for @cashOnDeliveryAvailable.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery Available'**
  String get cashOnDeliveryAvailable;

  /// No description provided for @enterPincode.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit Pincode'**
  String get enterPincode;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @freeStandardDelivery.
  ///
  /// In en, this message translates to:
  /// **'FREE Standard Delivery'**
  String get freeStandardDelivery;

  /// No description provided for @orderedBy4PM.
  ///
  /// In en, this message translates to:
  /// **'Ordered by 4 PM for same-day sanctum dispatch.'**
  String get orderedBy4PM;

  /// No description provided for @replacementGuarantee.
  ///
  /// In en, this message translates to:
  /// **'7-Day Replacement Guarantee'**
  String get replacementGuarantee;

  /// No description provided for @weReplaceDamagedDeity.
  ///
  /// In en, this message translates to:
  /// **'We replace damaged deity frames instantly.'**
  String get weReplaceDamagedDeity;

  /// No description provided for @safeSecurePayment.
  ///
  /// In en, this message translates to:
  /// **'100% Safe & Secure Payment Options'**
  String get safeSecurePayment;

  /// No description provided for @sslEncrypted.
  ///
  /// In en, this message translates to:
  /// **'256-Bit SSL Encrypted'**
  String get sslEncrypted;

  /// No description provided for @vedicPure.
  ///
  /// In en, this message translates to:
  /// **'100% Vedic Pure'**
  String get vedicPure;

  /// No description provided for @naturalMaterials.
  ///
  /// In en, this message translates to:
  /// **'Natural materials'**
  String get naturalMaterials;

  /// No description provided for @abhimantrit.
  ///
  /// In en, this message translates to:
  /// **'Abhimantrit'**
  String get abhimantrit;

  /// No description provided for @mantraEnergized.
  ///
  /// In en, this message translates to:
  /// **'Mantra energized'**
  String get mantraEnergized;

  /// No description provided for @frequentlyBlessedTogether.
  ///
  /// In en, this message translates to:
  /// **'Frequently Blessed Together — Save 10% on Complete Sacred Set'**
  String get frequentlyBlessedTogether;

  /// No description provided for @bundleTotal.
  ///
  /// In en, this message translates to:
  /// **'Bundle Total (10% Off):'**
  String get bundleTotal;

  /// No description provided for @addCompleteSet.
  ///
  /// In en, this message translates to:
  /// **'ADD COMPLETE SET TO BAG'**
  String get addCompleteSet;

  /// No description provided for @vedicSignificanceTab.
  ///
  /// In en, this message translates to:
  /// **'Vedic Significance & Details'**
  String get vedicSignificanceTab;

  /// No description provided for @specificationsTab.
  ///
  /// In en, this message translates to:
  /// **'Specifications & Dimensions'**
  String get specificationsTab;

  /// No description provided for @sacredCareTab.
  ///
  /// In en, this message translates to:
  /// **'Sacred Care & Purity'**
  String get sacredCareTab;

  /// No description provided for @devoteeReviewsTab.
  ///
  /// In en, this message translates to:
  /// **'Devotee Reviews'**
  String get devoteeReviewsTab;

  /// No description provided for @faqsTab.
  ///
  /// In en, this message translates to:
  /// **'FAQs & Guidance'**
  String get faqsTab;

  /// No description provided for @aboutThisOffering.
  ///
  /// In en, this message translates to:
  /// **'About this Sacred Offering:'**
  String get aboutThisOffering;

  /// No description provided for @blessingsSignificance.
  ///
  /// In en, this message translates to:
  /// **'Blessings & Significance:'**
  String get blessingsSignificance;

  /// No description provided for @purityStandards.
  ///
  /// In en, this message translates to:
  /// **'Purity Standards:'**
  String get purityStandards;

  /// No description provided for @submitReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Your Devotional Review for'**
  String get submitReviewTitle;

  /// No description provided for @publishReview.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH REVIEW'**
  String get publishReview;

  /// No description provided for @similarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar Devotional Keychains'**
  String get similarProducts;

  /// No description provided for @exploreFullCollection.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE FULL COLLECTION →'**
  String get exploreFullCollection;

  /// No description provided for @coreCompetencies.
  ///
  /// In en, this message translates to:
  /// **'CORE COMPETENCIES'**
  String get coreCompetencies;

  /// No description provided for @professionalHighlights.
  ///
  /// In en, this message translates to:
  /// **'PROFESSIONAL HIGHLIGHTS'**
  String get professionalHighlights;

  /// No description provided for @socialInitiative.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL INITIATIVE'**
  String get socialInitiative;

  /// No description provided for @philosophyOfLife.
  ///
  /// In en, this message translates to:
  /// **'PHILOSOPHY OF LIFE'**
  String get philosophyOfLife;

  /// No description provided for @personalAttributes.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL ATTRIBUTES'**
  String get personalAttributes;
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
