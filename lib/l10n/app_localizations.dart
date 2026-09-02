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

  /// No description provided for @myShoppingBag.
  ///
  /// In en, this message translates to:
  /// **'My Shopping Bag'**
  String get myShoppingBag;

  /// No description provided for @storeHomePortal.
  ///
  /// In en, this message translates to:
  /// **'Store Home Portal'**
  String get storeHomePortal;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed: {error}'**
  String paymentFailed(String error);

  /// No description provided for @razorpayGateway.
  ///
  /// In en, this message translates to:
  /// **'Razorpay Payment Gateway (Dummy)'**
  String get razorpayGateway;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing secure payment...'**
  String get processingPayment;

  /// No description provided for @emailMatchError.
  ///
  /// In en, this message translates to:
  /// **'Email must match your profile email.'**
  String get emailMatchError;

  /// No description provided for @validPincodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit pincode.'**
  String get validPincodeRequired;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order Placed Successfully!'**
  String get orderPlacedSuccessfully;

  /// No description provided for @failedToPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order.'**
  String get failedToPlaceOrder;

  /// No description provided for @yourBagIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your bag is empty'**
  String get yourBagIsEmpty;

  /// No description provided for @backToProducts.
  ///
  /// In en, this message translates to:
  /// **'Back to Products'**
  String get backToProducts;

  /// No description provided for @secureSacredCheckout.
  ///
  /// In en, this message translates to:
  /// **'SECURE SACRED CHECKOUT'**
  String get secureSacredCheckout;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @placed.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get placed;

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone *'**
  String get phoneLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address *'**
  String get addressLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get cityLabel;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State *'**
  String get stateLabel;

  /// No description provided for @pincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pincode *'**
  String get pincodeLabel;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get noteOptional;

  /// No description provided for @validPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Valid Phone Required'**
  String get validPhoneRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Valid Email Required'**
  String get validEmailRequired;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @payWhenDelivered.
  ///
  /// In en, this message translates to:
  /// **'Pay when delivered.'**
  String get payWhenDelivered;

  /// No description provided for @upiOnlinePayment.
  ///
  /// In en, this message translates to:
  /// **'UPI / Online Payment'**
  String get upiOnlinePayment;

  /// No description provided for @secureOnlinePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure online payment.'**
  String get secureOnlinePayment;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @taxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxes;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @completeOrder.
  ///
  /// In en, this message translates to:
  /// **'Complete Order'**
  String get completeOrder;

  /// No description provided for @secureCheckoutProtected.
  ///
  /// In en, this message translates to:
  /// **'Secure Checkout • Encrypted & Protected'**
  String get secureCheckoutProtected;

  /// No description provided for @orderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlacedTitle;

  /// No description provided for @orderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID: {id}'**
  String orderIdLabel(String id);

  /// No description provided for @orderIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Order ID copied to clipboard!'**
  String get orderIdCopied;

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// No description provided for @sendToWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send to WhatsApp'**
  String get sendToWhatsApp;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @trackOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Track Order Status'**
  String get trackOrderStatus;

  /// No description provided for @goToMyOrders.
  ///
  /// In en, this message translates to:
  /// **'Go to My Orders'**
  String get goToMyOrders;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Oops! Product not found or failed to load.'**
  String get productNotFound;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get notFound;

  /// No description provided for @itemNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This sacred item is no longer available in the store.'**
  String get itemNotAvailable;

  /// No description provided for @returnToStore.
  ///
  /// In en, this message translates to:
  /// **'Return to Store'**
  String get returnToStore;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Reviews'**
  String reviewsCount(int count);

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @checkDeliveryAvailability.
  ///
  /// In en, this message translates to:
  /// **'Please check delivery availability first'**
  String get checkDeliveryAvailability;

  /// No description provided for @checkOutSacredItem.
  ///
  /// In en, this message translates to:
  /// **'Check out this sacred item:'**
  String get checkOutSacredItem;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @premiumMaterial.
  ///
  /// In en, this message translates to:
  /// **'Premium Consecrated Material / Sacred Wood'**
  String get premiumMaterial;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @authenticAshramAtelier.
  ///
  /// In en, this message translates to:
  /// **'Authentic Ashram Atelier'**
  String get authenticAshramAtelier;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @approxWeight.
  ///
  /// In en, this message translates to:
  /// **'Approx 50g - 150g'**
  String get approxWeight;

  /// No description provided for @unableToLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reviews at this time.'**
  String get unableToLoadReviews;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first devotee to share your experience!'**
  String get noReviewsYet;

  /// No description provided for @basedOnDevoteeReviews.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} devotee reviews'**
  String basedOnDevoteeReviews(int count);

  /// No description provided for @verifiedDevoteeReviews.
  ///
  /// In en, this message translates to:
  /// **'100% Verified Devotee & Altar Reviews'**
  String get verifiedDevoteeReviews;

  /// No description provided for @inspectedVedicAuthenticity.
  ///
  /// In en, this message translates to:
  /// **'Inspected for Vedic Authenticity & Material Integrity'**
  String get inspectedVedicAuthenticity;

  /// No description provided for @closeForm.
  ///
  /// In en, this message translates to:
  /// **'CLOSE FORM'**
  String get closeForm;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'WRITE REVIEW'**
  String get writeReview;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating: '**
  String get ratingLabel;

  /// No description provided for @devoteeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Full Name / Devotee Name *'**
  String get devoteeNameLabel;

  /// No description provided for @reviewTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Review Title *'**
  String get reviewTitleLabel;

  /// No description provided for @detailedExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Detailed Experience / Feedback *'**
  String get detailedExperienceLabel;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback on the texture, finish, pooja experience, packaging...'**
  String get reviewHint;

  /// No description provided for @testimonialPublished.
  ///
  /// In en, this message translates to:
  /// **'Testimonial published with blessings!'**
  String get testimonialPublished;

  /// No description provided for @faqEnergizedQ.
  ///
  /// In en, this message translates to:
  /// **'Q: Is this item already energized?'**
  String get faqEnergizedQ;

  /// No description provided for @faqEnergizedA.
  ///
  /// In en, this message translates to:
  /// **'A: Yes, all our offerings are sanctified through a special Puja Seva before dispatch.'**
  String get faqEnergizedA;

  /// No description provided for @faqGiftQ.
  ///
  /// In en, this message translates to:
  /// **'Q: Can I gift this to someone?'**
  String get faqGiftQ;

  /// No description provided for @faqGiftA.
  ///
  /// In en, this message translates to:
  /// **'A: Absolutely. Giving a sacred offering is considered an act of great merit (Punya).'**
  String get faqGiftA;

  /// No description provided for @sacredCareInstructions.
  ///
  /// In en, this message translates to:
  /// **'• This item should be handled with spiritual reverence.\n• Avoid placing on the floor or in unclean areas.\n• Clean only with a dry, pure cotton cloth to maintain its consecrated energy.'**
  String get sacredCareInstructions;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @exploreCatalogue.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE CATALOGUE'**
  String get exploreCatalogue;

  /// No description provided for @availableSacredOffers.
  ///
  /// In en, this message translates to:
  /// **'Available Sacred Offers'**
  String get availableSacredOffers;

  /// No description provided for @noCouponsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No coupons available at the moment.'**
  String get noCouponsAvailable;

  /// No description provided for @couldNotApplyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Could not apply coupon'**
  String get couldNotApplyCoupon;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'APPLIED'**
  String get applied;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'APPLY COUPON'**
  String get applyCoupon;

  /// No description provided for @couponAppliedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Coupon {code} Applied Successfully!'**
  String couponAppliedSuccess(String code);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @promoDiscount.
  ///
  /// In en, this message translates to:
  /// **'Promo Discount ({code})'**
  String promoDiscount(String code);

  /// No description provided for @shippingSevaFee.
  ///
  /// In en, this message translates to:
  /// **'Shipping Seva Fee'**
  String get shippingSevaFee;

  /// No description provided for @sacredItemTax.
  ///
  /// In en, this message translates to:
  /// **'Sacred Item Tax (5%)'**
  String get sacredItemTax;

  /// No description provided for @finalTotal.
  ///
  /// In en, this message translates to:
  /// **'Final Total'**
  String get finalTotal;

  /// No description provided for @youSavedAmount.
  ///
  /// In en, this message translates to:
  /// **'You saved ₹{amount}!'**
  String youSavedAmount(int amount);

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'PROCEED TO CHECKOUT'**
  String get proceedToCheckout;

  /// No description provided for @yourSacredWishlist.
  ///
  /// In en, this message translates to:
  /// **'Your Sacred Wishlist'**
  String get yourSacredWishlist;

  /// No description provided for @sacredWishlistDesc.
  ///
  /// In en, this message translates to:
  /// **'Sacred items you have cherished and saved for your divine collection.'**
  String get sacredWishlistDesc;

  /// No description provided for @yourWishlistIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is currently empty.'**
  String get yourWishlistIsEmpty;

  /// No description provided for @yourSacredOrders.
  ///
  /// In en, this message translates to:
  /// **'Your Sacred Orders'**
  String get yourSacredOrders;

  /// No description provided for @trackOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your divine collections and blessings history.'**
  String get trackOrdersDesc;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @couldNotLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'We could not load your orders. Please try again.'**
  String get couldNotLoadOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @noOrdersPlacedDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t placed any sacred orders yet.'**
  String get noOrdersPlacedDesc;

  /// No description provided for @orderIdTitle.
  ///
  /// In en, this message translates to:
  /// **'ORDER ID'**
  String get orderIdTitle;

  /// No description provided for @datePlaced.
  ///
  /// In en, this message translates to:
  /// **'DATE PLACED'**
  String get datePlaced;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @moreItems.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more items'**
  String moreItems(int count);

  /// No description provided for @trackingInformation.
  ///
  /// In en, this message translates to:
  /// **'TRACKING INFORMATION'**
  String get trackingInformation;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmount;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'TRACK'**
  String get track;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'INVOICE'**
  String get invoice;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get view;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @printInvoice.
  ///
  /// In en, this message translates to:
  /// **'PRINT INVOICE'**
  String get printInvoice;

  /// No description provided for @shareInvoice.
  ///
  /// In en, this message translates to:
  /// **'SHARE INVOICE'**
  String get shareInvoice;

  /// No description provided for @officialOrderTracker.
  ///
  /// In en, this message translates to:
  /// **'Official Order Tracker'**
  String get officialOrderTracker;

  /// No description provided for @trackYourSacredOrder.
  ///
  /// In en, this message translates to:
  /// **'TRACK YOUR SACRED ORDER'**
  String get trackYourSacredOrder;

  /// No description provided for @enterOrderIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Order ID (e.g. DADA-123456)'**
  String get enterOrderIdHint;

  /// No description provided for @trackNow.
  ///
  /// In en, this message translates to:
  /// **'TRACK NOW'**
  String get trackNow;

  /// No description provided for @findOrderIdDesc.
  ///
  /// In en, this message translates to:
  /// **'You can find your Order ID in the confirmation email or \"My Orders\" section.'**
  String get findOrderIdDesc;

  /// No description provided for @enterOrderIdStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your Order ID above to see live status.'**
  String get enterOrderIdStatusDesc;

  /// No description provided for @noOrderFound.
  ///
  /// In en, this message translates to:
  /// **'No order found with this ID.'**
  String get noOrderFound;

  /// No description provided for @trackingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while tracking.'**
  String get trackingError;

  /// No description provided for @placedOnDate.
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}'**
  String placedOnDate(String date);

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PAID'**
  String get totalPaid;

  /// No description provided for @shippingPartnerTrackingId.
  ///
  /// In en, this message translates to:
  /// **'SHIPPING PARTNER & TRACKING ID'**
  String get shippingPartnerTrackingId;

  /// No description provided for @shareOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'SHARE ON WHATSAPP'**
  String get shareOnWhatsApp;

  /// No description provided for @shippingDestination.
  ///
  /// In en, this message translates to:
  /// **'Shipping Destination:'**
  String get shippingDestination;

  /// No description provided for @sacredItems.
  ///
  /// In en, this message translates to:
  /// **'Sacred Items:'**
  String get sacredItems;

  /// No description provided for @quickView.
  ///
  /// In en, this message translates to:
  /// **'Quick View'**
  String get quickView;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password'**
  String get enterEmailPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @noAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get noAccountFound;

  /// No description provided for @incorrectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get incorrectCredentials;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get accountDisabled;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again later.'**
  String get tooManyAttempts;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address above first'**
  String get enterEmailFirst;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}'**
  String passwordResetSent(String email);

  /// No description provided for @failedSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email'**
  String get failedSendResetEmail;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get allFieldsRequired;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number (10-12 digits)'**
  String get enterValidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account Created Successfully!'**
  String get accountCreatedSuccess;

  /// No description provided for @sacredAccessPortal.
  ///
  /// In en, this message translates to:
  /// **'Sacred Access Portal'**
  String get sacredAccessPortal;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get forgotPassword;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Log In to Your Account'**
  String get loginToAccount;

  /// No description provided for @mobileWhatsAppLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile / WhatsApp'**
  String get mobileWhatsAppLabel;

  /// No description provided for @securePasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Secure Password'**
  String get securePasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the Community'**
  String get joinCommunity;

  /// No description provided for @secureAuthArea.
  ///
  /// In en, this message translates to:
  /// **'Secure Devotee Authorization Area'**
  String get secureAuthArea;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated!'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(String error);

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new secure password'**
  String get enterNewPassword;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password Changed Successfully!'**
  String get passwordChangedSuccess;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get update;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @logoutFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Logout from Account'**
  String get logoutFromAccount;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFORMATION'**
  String get personalInformation;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'EDIT PROFILE'**
  String get editProfile;

  /// No description provided for @freeShippingRemaining.
  ///
  /// In en, this message translates to:
  /// **'Add ₹{amount} more for Free Express Shipping'**
  String freeShippingRemaining(String amount);

  /// No description provided for @freeShippingQualified.
  ///
  /// In en, this message translates to:
  /// **'You have qualified for Free Express Shipping!'**
  String get freeShippingQualified;

  /// No description provided for @emptyBagDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover handcrafted timepieces, bespoke ceramics, fine merino knitwear, and leather goods.'**
  String get emptyBagDesc;

  /// No description provided for @suggestedSacredOffers.
  ///
  /// In en, this message translates to:
  /// **'Suggested Sacred Offers'**
  String get suggestedSacredOffers;

  /// No description provided for @promoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'PROMO CODE (E.G. DADA10)'**
  String get promoCodeHint;

  /// No description provided for @invalidPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or inactive promo code'**
  String get invalidPromoCode;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon {code} applied!'**
  String couponApplied(String code);

  /// No description provided for @promoDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Promo Discount'**
  String get promoDiscountLabel;

  /// No description provided for @expressShipping.
  ///
  /// In en, this message translates to:
  /// **'Insured Express Shipping'**
  String get expressShipping;

  /// No description provided for @estimatedTaxes.
  ///
  /// In en, this message translates to:
  /// **'Estimated Taxes (5%)'**
  String get estimatedTaxes;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get estimatedTotal;

  /// No description provided for @proceedToSecureCheckout.
  ///
  /// In en, this message translates to:
  /// **'PROCEED TO SECURE CHECKOUT'**
  String get proceedToSecureCheckout;

  /// No description provided for @viewShoppingBag.
  ///
  /// In en, this message translates to:
  /// **'VIEW SHOPPING BAG'**
  String get viewShoppingBag;

  /// No description provided for @sslGuarantee.
  ///
  /// In en, this message translates to:
  /// **'256-bit Encrypted SSL Guarantee'**
  String get sslGuarantee;

  /// No description provided for @loginToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Please login to proceed to checkout'**
  String get loginToCheckout;

  /// No description provided for @skuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU: {sku}'**
  String skuLabel(String sku);

  /// No description provided for @bestseller.
  ///
  /// In en, this message translates to:
  /// **'BESTSELLER'**
  String get bestseller;

  /// No description provided for @ratingReviews.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count} Reviews)'**
  String ratingReviews(double rating, int count);

  /// No description provided for @offPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String offPercentage(int percent);

  /// No description provided for @addWithPrice.
  ///
  /// In en, this message translates to:
  /// **'ADD • ₹{amount}'**
  String addWithPrice(int amount);

  /// No description provided for @instantCheckout.
  ///
  /// In en, this message translates to:
  /// **'⚡ INSTANT CHECKOUT'**
  String get instantCheckout;

  /// No description provided for @viewDetailedSpecs.
  ///
  /// In en, this message translates to:
  /// **'View Detailed Specs'**
  String get viewDetailedSpecs;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'ADMIN PORTAL'**
  String get adminPortal;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'TRANSLATE'**
  String get translate;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH'**
  String get publish;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @headerFooterSettings.
  ///
  /// In en, this message translates to:
  /// **'Header, Footer, & General Settings'**
  String get headerFooterSettings;

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homePage;

  /// No description provided for @aboutDadaPage.
  ///
  /// In en, this message translates to:
  /// **'About Dada Page'**
  String get aboutDadaPage;

  /// No description provided for @kathaPages.
  ///
  /// In en, this message translates to:
  /// **'Katha Pages'**
  String get kathaPages;

  /// No description provided for @contactEnquiries.
  ///
  /// In en, this message translates to:
  /// **'Contact & Enquiries'**
  String get contactEnquiries;

  /// No description provided for @productManagement.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get productManagement;

  /// No description provided for @translationAudit.
  ///
  /// In en, this message translates to:
  /// **'Translation Audit'**
  String get translationAudit;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @backToWebsite.
  ///
  /// In en, this message translates to:
  /// **'BACK TO WEBSITE'**
  String get backToWebsite;

  /// No description provided for @selectMenu.
  ///
  /// In en, this message translates to:
  /// **'Select a menu'**
  String get selectMenu;

  /// No description provided for @deepTranslationSync.
  ///
  /// In en, this message translates to:
  /// **'Deep Translation Sync'**
  String get deepTranslationSync;

  /// No description provided for @currentSection.
  ///
  /// In en, this message translates to:
  /// **'Current Section: {section}'**
  String currentSection(String section);

  /// No description provided for @processedCount.
  ///
  /// In en, this message translates to:
  /// **'Processed: {count}/{total}'**
  String processedCount(int count, int total);

  /// No description provided for @failedCount.
  ///
  /// In en, this message translates to:
  /// **'Failed: {count}'**
  String failedCount(int count);

  /// No description provided for @pleaseEnterUsernamePassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username and password'**
  String get pleaseEnterUsernamePassword;

  /// No description provided for @adminAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'No admin account found with this username.'**
  String get adminAccountNotFound;

  /// No description provided for @incorrectUsernamePassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password.'**
  String get incorrectUsernamePassword;

  /// No description provided for @enterValidCredential.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid credential.'**
  String get enterValidCredential;

  /// No description provided for @adminAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This admin account has been disabled.'**
  String get adminAccountDisabled;

  /// No description provided for @loginFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailedTryAgain;

  /// No description provided for @loginFailedWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Login Failed: {error}'**
  String loginFailedWithDetails(String error);

  /// No description provided for @secureDashboardAccess.
  ///
  /// In en, this message translates to:
  /// **'Secure Dashboard Access'**
  String get secureDashboardAccess;

  /// No description provided for @adminEmailHint.
  ///
  /// In en, this message translates to:
  /// **'admin@example.com'**
  String get adminEmailHint;

  /// No description provided for @broadcastToAllUsers.
  ///
  /// In en, this message translates to:
  /// **'Broadcast to All Users'**
  String get broadcastToAllUsers;

  /// No description provided for @enterTitleMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter both title and message'**
  String get enterTitleMessage;

  /// No description provided for @notificationSentToUsers.
  ///
  /// In en, this message translates to:
  /// **'Notification sent to {count} users!'**
  String notificationSentToUsers(int count);

  /// No description provided for @sendBroadcastDesc.
  ///
  /// In en, this message translates to:
  /// **'Send broadcast notifications to all users.'**
  String get sendBroadcastDesc;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Title'**
  String get notificationTitle;

  /// No description provided for @sendToAllUsers.
  ///
  /// In en, this message translates to:
  /// **'Send to All Users'**
  String get sendToAllUsers;

  /// No description provided for @recentOrderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Recent Order Notifications'**
  String get recentOrderNotifications;

  /// No description provided for @noNotificationsSent.
  ///
  /// In en, this message translates to:
  /// **'No notifications sent yet.'**
  String get noNotificationsSent;

  /// No description provided for @manageAppConfig.
  ///
  /// In en, this message translates to:
  /// **'Manage application configuration, branding, and contact details.'**
  String get manageAppConfig;

  /// No description provided for @generalInfoBranding.
  ///
  /// In en, this message translates to:
  /// **'General Info & Branding'**
  String get generalInfoBranding;

  /// No description provided for @uploadNewLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload New Logo'**
  String get uploadNewLogo;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @storeDescription.
  ///
  /// In en, this message translates to:
  /// **'Store Description'**
  String get storeDescription;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @physicalAddress.
  ///
  /// In en, this message translates to:
  /// **'Physical Address'**
  String get physicalAddress;

  /// No description provided for @socialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social Links'**
  String get socialLinks;

  /// No description provided for @facebookUrl.
  ///
  /// In en, this message translates to:
  /// **'Facebook URL'**
  String get facebookUrl;

  /// No description provided for @instagramUrl.
  ///
  /// In en, this message translates to:
  /// **'Instagram URL'**
  String get instagramUrl;

  /// No description provided for @twitterUrl.
  ///
  /// In en, this message translates to:
  /// **'Twitter URL'**
  String get twitterUrl;

  /// No description provided for @deliverySettings.
  ///
  /// In en, this message translates to:
  /// **'Delivery Settings'**
  String get deliverySettings;

  /// No description provided for @standardDeliveryChargeRs.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery Charge (₹)'**
  String get standardDeliveryChargeRs;

  /// No description provided for @freeDeliveryThresholdRs.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery Threshold (₹)'**
  String get freeDeliveryThresholdRs;

  /// No description provided for @enableCod.
  ///
  /// In en, this message translates to:
  /// **'Enable Cash on Delivery (COD)'**
  String get enableCod;

  /// No description provided for @advancedTools.
  ///
  /// In en, this message translates to:
  /// **'Advanced Tools'**
  String get advancedTools;

  /// No description provided for @translateAllStoreData.
  ///
  /// In en, this message translates to:
  /// **'Translate All Store Data'**
  String get translateAllStoreData;

  /// No description provided for @translateStoreDesc.
  ///
  /// In en, this message translates to:
  /// **'This will automatically translate all existing products and categories into Hindi and Gujarati. This may take a few minutes depending on the amount of data.'**
  String get translateStoreDesc;

  /// No description provided for @startTranslationNow.
  ///
  /// In en, this message translates to:
  /// **'Start Translation Now'**
  String get startTranslationNow;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully!'**
  String get settingsSaved;

  /// No description provided for @viewRegisteredUsers.
  ///
  /// In en, this message translates to:
  /// **'View all registered users, their roles, and account status.'**
  String get viewRegisteredUsers;

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or phone...'**
  String get searchUsersHint;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedDate(String date);

  /// No description provided for @organizeOfferings.
  ///
  /// In en, this message translates to:
  /// **'Organize Pu. Dada sacred offerings into distinct store categories.'**
  String get organizeOfferings;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW CATEGORY'**
  String get addNewCategory;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found.'**
  String get noCategoriesFound;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Products'**
  String productsCount(int count);

  /// No description provided for @viewProductsArrow.
  ///
  /// In en, this message translates to:
  /// **'View Products →'**
  String get viewProductsArrow;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This will not delete products in this category but they will be unassigned.'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @couponsDevotionalOffers.
  ///
  /// In en, this message translates to:
  /// **'Coupons & Devotional Offers'**
  String get couponsDevotionalOffers;

  /// No description provided for @createPromoDesc.
  ///
  /// In en, this message translates to:
  /// **'Create promo codes and celebratory blessing discounts for devotees.'**
  String get createPromoDesc;

  /// No description provided for @createPromoCode.
  ///
  /// In en, this message translates to:
  /// **'CREATE PROMO CODE'**
  String get createPromoCode;

  /// No description provided for @noCouponsCreated.
  ///
  /// In en, this message translates to:
  /// **'No coupons created yet.'**
  String get noCouponsCreated;

  /// No description provided for @instantDiscountDesc.
  ///
  /// In en, this message translates to:
  /// **'{value}% instant discount on all Dada products'**
  String instantDiscountDesc(String value);

  /// No description provided for @flatDiscountDesc.
  ///
  /// In en, this message translates to:
  /// **'Flat ₹{value} OFF on orders above ₹{min}'**
  String flatDiscountDesc(String value, String min);

  /// No description provided for @discountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Discount: {value}'**
  String discountPrefix(String value);

  /// No description provided for @minOrderPrefix.
  ///
  /// In en, this message translates to:
  /// **'Min Order: ₹{value}'**
  String minOrderPrefix(String value);

  /// No description provided for @timesUsedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Times Used: {count}'**
  String timesUsedPrefix(int count);

  /// No description provided for @couponCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code (e.g. DADA10)'**
  String get couponCodeHint;

  /// No description provided for @flatPriceDiscount.
  ///
  /// In en, this message translates to:
  /// **'Flat Price Discount'**
  String get flatPriceDiscount;

  /// No description provided for @percentageDiscount.
  ///
  /// In en, this message translates to:
  /// **'Percentage Discount'**
  String get percentageDiscount;

  /// No description provided for @discountType.
  ///
  /// In en, this message translates to:
  /// **'Discount Type'**
  String get discountType;

  /// No description provided for @discountValueRs.
  ///
  /// In en, this message translates to:
  /// **'Discount Value (₹)'**
  String get discountValueRs;

  /// No description provided for @discountValuePercent.
  ///
  /// In en, this message translates to:
  /// **'Discount Percentage (%)'**
  String get discountValuePercent;

  /// No description provided for @minOrderValueRs.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Value (₹)'**
  String get minOrderValueRs;

  /// No description provided for @usageLimitPerUser.
  ///
  /// In en, this message translates to:
  /// **'Usage Limit Per User'**
  String get usageLimitPerUser;

  /// No description provided for @saveCoupon.
  ///
  /// In en, this message translates to:
  /// **'Save Coupon'**
  String get saveCoupon;

  /// No description provided for @usageLimitHint.
  ///
  /// In en, this message translates to:
  /// **'Maximum 2 uses per devotee.'**
  String get usageLimitHint;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'LOW STOCK'**
  String get lowStock;

  /// No description provided for @restockInventory.
  ///
  /// In en, this message translates to:
  /// **'RESTOCK / INVENTORY'**
  String get restockInventory;

  /// No description provided for @discountCoupons.
  ///
  /// In en, this message translates to:
  /// **'DISCOUNT COUPONS'**
  String get discountCoupons;

  /// No description provided for @viewAllOrders.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL ORDERS'**
  String get viewAllOrders;

  /// No description provided for @orderDispatch.
  ///
  /// In en, this message translates to:
  /// **'ORDER & DISPATCH'**
  String get orderDispatch;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recentOrders;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @devotionalOpsDashboard.
  ///
  /// In en, this message translates to:
  /// **'Devotional Operations Dashboard'**
  String get devotionalOpsDashboard;

  /// No description provided for @realTimeOverview.
  ///
  /// In en, this message translates to:
  /// **'Real-time overview of sacred orders, live stock, and devotee engagement.'**
  String get realTimeOverview;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get thirtyDays;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get threeMonths;

  /// No description provided for @oneYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get oneYear;

  /// No description provided for @noRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'No recent orders found.'**
  String get noRecentOrders;

  /// No description provided for @devoteeUserManagement.
  ///
  /// In en, this message translates to:
  /// **'Devotee User Management'**
  String get devoteeUserManagement;

  /// No description provided for @viewRegisteredDevotees.
  ///
  /// In en, this message translates to:
  /// **'View registered devotees, their contact information, and sacred purchase history.'**
  String get viewRegisteredDevotees;

  /// No description provided for @searchDevoteesHint.
  ///
  /// In en, this message translates to:
  /// **'Search devotees...'**
  String get searchDevoteesHint;

  /// No description provided for @noDevoteesFound.
  ///
  /// In en, this message translates to:
  /// **'No devotees found.'**
  String get noDevoteesFound;

  /// No description provided for @sacredDevotee.
  ///
  /// In en, this message translates to:
  /// **'Sacred Devotee'**
  String get sacredDevotee;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @lifetimeOfferings.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Offerings'**
  String get lifetimeOfferings;

  /// No description provided for @whatsAppSeva.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Seva'**
  String get whatsAppSeva;

  /// No description provided for @inventoryStockReplenishment.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Stock Replenishment'**
  String get inventoryStockReplenishment;

  /// No description provided for @monitorWarehouseLevels.
  ///
  /// In en, this message translates to:
  /// **'Monitor real-time warehouse levels and trigger batch restocks.'**
  String get monitorWarehouseLevels;

  /// No description provided for @lowStockItemsBelow.
  ///
  /// In en, this message translates to:
  /// **'{count} items below safety threshold'**
  String lowStockItemsBelow(int count);

  /// No description provided for @itemSku.
  ///
  /// In en, this message translates to:
  /// **'ITEM & SKU'**
  String get itemSku;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'CURRENT STOCK'**
  String get currentStock;

  /// No description provided for @safetyLimit.
  ///
  /// In en, this message translates to:
  /// **'SAFETY LIMIT'**
  String get safetyLimit;

  /// No description provided for @statusIndicator.
  ///
  /// In en, this message translates to:
  /// **'STATUS INDICATOR'**
  String get statusIndicator;

  /// No description provided for @batchReplenish.
  ///
  /// In en, this message translates to:
  /// **'BATCH REPLENISH'**
  String get batchReplenish;

  /// No description provided for @lowBadge.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get lowBadge;

  /// No description provided for @okBadge.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okBadge;

  /// No description provided for @manualStockUpdate.
  ///
  /// In en, this message translates to:
  /// **'Manual Stock Update: {name}'**
  String manualStockUpdate(String name);

  /// No description provided for @setAbsoluteStock.
  ///
  /// In en, this message translates to:
  /// **'Set Absolute Stock Quantity'**
  String get setAbsoluteStock;

  /// No description provided for @ordersConsecrationDispatch.
  ///
  /// In en, this message translates to:
  /// **'Orders & Consecration Dispatch'**
  String get ordersConsecrationDispatch;

  /// No description provided for @trackDevoteeOrders.
  ///
  /// In en, this message translates to:
  /// **'Track devotee orders, manage shipping carriers, and generate GST invoices.'**
  String get trackDevoteeOrders;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get allFilter;

  /// No description provided for @pendingFilter.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pendingFilter;

  /// No description provided for @processingFilter.
  ///
  /// In en, this message translates to:
  /// **'PROCESSING'**
  String get processingFilter;

  /// No description provided for @shippedFilter.
  ///
  /// In en, this message translates to:
  /// **'SHIPPED'**
  String get shippedFilter;

  /// No description provided for @deliveredFilter.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED'**
  String get deliveredFilter;

  /// No description provided for @paymentStatusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Payment: {method} ({status})'**
  String paymentStatusPrefix(String method, String status);

  /// No description provided for @netReceived.
  ///
  /// In en, this message translates to:
  /// **'NET RECEIVED: ₹{amount}'**
  String netReceived(int amount);

  /// No description provided for @couponAppliedLabel.
  ///
  /// In en, this message translates to:
  /// **'Coupon Applied: {code}'**
  String couponAppliedLabel(String code);

  /// No description provided for @qtyTimesPrice.
  ///
  /// In en, this message translates to:
  /// **'Qty: {qty} × ₹{price}'**
  String qtyTimesPrice(int qty, int price);

  /// No description provided for @shareWhatsAppTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get shareWhatsAppTooltip;

  /// No description provided for @trackingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Tracking updated!'**
  String get trackingUpdated;

  /// No description provided for @invalidTrackingFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format. Use \"Carrier: ID\"'**
  String get invalidTrackingFormat;

  /// No description provided for @trackingHint.
  ///
  /// In en, this message translates to:
  /// **'DTDC Express / Blue Dart: DADA-ID-123'**
  String get trackingHint;

  /// No description provided for @updateTracking.
  ///
  /// In en, this message translates to:
  /// **'Update Tracking'**
  String get updateTracking;

  /// No description provided for @ordersConsecrationManagement.
  ///
  /// In en, this message translates to:
  /// **'Orders & Consecration Management'**
  String get ordersConsecrationManagement;

  /// No description provided for @manageDevoteeOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage devotee orders, update dispatch status, and handle sacred item consecration flow.'**
  String get manageDevoteeOrders;

  /// No description provided for @searchOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by Order ID, Name, Phone...'**
  String get searchOrdersHint;

  /// No description provided for @confirmedStatus.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmedStatus;

  /// No description provided for @cancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledStatus;

  /// No description provided for @noOrdersFoundCriteria.
  ///
  /// In en, this message translates to:
  /// **'No orders found matching your criteria.'**
  String get noOrdersFoundCriteria;

  /// No description provided for @placedByOn.
  ///
  /// In en, this message translates to:
  /// **'Placed by {name} on {date}'**
  String placedByOn(String name, String date);

  /// No description provided for @itemsHeader.
  ///
  /// In en, this message translates to:
  /// **'ITEMS'**
  String get itemsHeader;

  /// No description provided for @deliveryAddressHeader.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY ADDRESS'**
  String get deliveryAddressHeader;

  /// No description provided for @totalAmountHeader.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmountHeader;

  /// No description provided for @phonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phonePrefix(String phone);

  /// No description provided for @paymentsCodSettlement.
  ///
  /// In en, this message translates to:
  /// **'Payments & COD Settlement'**
  String get paymentsCodSettlement;

  /// No description provided for @reconcileUpiCardCod.
  ///
  /// In en, this message translates to:
  /// **'Reconcile UPI transfers, card gateways, and Cash on Delivery collections.'**
  String get reconcileUpiCardCod;

  /// No description provided for @upiInstantTransfers.
  ///
  /// In en, this message translates to:
  /// **'UPI INSTANT TRANSFERS'**
  String get upiInstantTransfers;

  /// No description provided for @upiIdSubtext.
  ///
  /// In en, this message translates to:
  /// **'ID: dada.bhagwan@okhdfcbank'**
  String get upiIdSubtext;

  /// No description provided for @codBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'CASH ON DELIVERY (COD)'**
  String get codBoxTitle;

  /// No description provided for @codBoxSubtext.
  ///
  /// In en, this message translates to:
  /// **'Doorstep carrier collections'**
  String get codBoxSubtext;

  /// No description provided for @onlineCardsBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'ONLINE CARDS / NETBANKING'**
  String get onlineCardsBoxTitle;

  /// No description provided for @onlineCardsBoxSubtext.
  ///
  /// In en, this message translates to:
  /// **'100% Secure 256-bit Encrypted'**
  String get onlineCardsBoxSubtext;

  /// No description provided for @recentSuccessfulTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Successful Transactions'**
  String get recentSuccessfulTransactions;

  /// No description provided for @successfulStatus.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successfulStatus;

  /// No description provided for @paymentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown: ₹{subtotal} (S) - ₹{discount} (D) + ₹{tax} (T)'**
  String paymentBreakdown(int subtotal, int discount, int tax);

  /// No description provided for @dashboardTab.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTab;

  /// No description provided for @productsTab.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTab;

  /// No description provided for @categoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTab;

  /// No description provided for @inventoryTab.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTab;

  /// No description provided for @ordersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTab;

  /// No description provided for @usersTab.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTab;

  /// No description provided for @paymentsTab.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTab;

  /// No description provided for @couponsTab.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get couponsTab;

  /// No description provided for @reviewsTab.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTab;

  /// No description provided for @storeSettingsTab.
  ///
  /// In en, this message translates to:
  /// **'Store & Settings'**
  String get storeSettingsTab;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProductsHint;

  /// No description provided for @productTableHeader.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT'**
  String get productTableHeader;

  /// No description provided for @priceTableHeader.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get priceTableHeader;

  /// No description provided for @stockTableHeader.
  ///
  /// In en, this message translates to:
  /// **'STOCK'**
  String get stockTableHeader;

  /// No description provided for @actionsTableHeader.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get actionsTableHeader;

  /// No description provided for @devoteeReviewsBlessings.
  ///
  /// In en, this message translates to:
  /// **'Devotee Reviews & Blessings'**
  String get devoteeReviewsBlessings;

  /// No description provided for @moderateTestimonials.
  ///
  /// In en, this message translates to:
  /// **'Moderate customer testimonials and publish official Temple Seva replies.'**
  String get moderateTestimonials;

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymousUser;

  /// No description provided for @onProduct.
  ///
  /// In en, this message translates to:
  /// **'on {product}'**
  String onProduct(String product);

  /// No description provided for @replyToDevoteeArrow.
  ///
  /// In en, this message translates to:
  /// **'Reply to Devotee →'**
  String get replyToDevoteeArrow;

  /// No description provided for @replyToDevotee.
  ///
  /// In en, this message translates to:
  /// **'Reply to Devotee'**
  String get replyToDevotee;

  /// No description provided for @suggestedReply.
  ///
  /// In en, this message translates to:
  /// **'Suggested Reply (You can edit):'**
  String get suggestedReply;

  /// No description provided for @suggestedReplyText.
  ///
  /// In en, this message translates to:
  /// **'Jai Sachchidanand! Pranam! Thank you for your kind review and blessings. We are delighted to know that Pu. Dada\'s sacred offering brought peace and positive energy to your home. May you always be blessed with divine grace. - Temple Seva Team'**
  String get suggestedReplyText;

  /// No description provided for @invalidViewType.
  ///
  /// In en, this message translates to:
  /// **'Invalid View Type'**
  String get invalidViewType;

  /// No description provided for @generalTab.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalTab;

  /// No description provided for @headerTab.
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get headerTab;

  /// No description provided for @footerTab.
  ///
  /// In en, this message translates to:
  /// **'Footer'**
  String get footerTab;

  /// No description provided for @headerCustomization.
  ///
  /// In en, this message translates to:
  /// **'HEADER CUSTOMIZATION'**
  String get headerCustomization;

  /// No description provided for @stickyHeader.
  ///
  /// In en, this message translates to:
  /// **'Sticky Header'**
  String get stickyHeader;

  /// No description provided for @announcementBarText.
  ///
  /// In en, this message translates to:
  /// **'Announcement Bar Text'**
  String get announcementBarText;

  /// No description provided for @backgroundColorHex.
  ///
  /// In en, this message translates to:
  /// **'Background Color (Hex Code)'**
  String get backgroundColorHex;

  /// No description provided for @headerCta.
  ///
  /// In en, this message translates to:
  /// **'HEADER CALL-TO-ACTION (CTA)'**
  String get headerCta;

  /// No description provided for @enableDonationButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Donation Button'**
  String get enableDonationButton;

  /// No description provided for @buttonLabel.
  ///
  /// In en, this message translates to:
  /// **'Button Label'**
  String get buttonLabel;

  /// No description provided for @redirectionUrl.
  ///
  /// In en, this message translates to:
  /// **'Redirection URL'**
  String get redirectionUrl;

  /// No description provided for @saveHeaderSettings.
  ///
  /// In en, this message translates to:
  /// **'SAVE HEADER SETTINGS'**
  String get saveHeaderSettings;

  /// No description provided for @unifiedHomePageEditor.
  ///
  /// In en, this message translates to:
  /// **'UNIFIED HOME PAGE EDITOR'**
  String get unifiedHomePageEditor;

  /// No description provided for @saveAllChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE ALL CHANGES'**
  String get saveAllChanges;

  /// No description provided for @homePageSectionsVisibility.
  ///
  /// In en, this message translates to:
  /// **'HOME PAGE SECTIONS & VISIBILITY'**
  String get homePageSectionsVisibility;

  /// No description provided for @toggleSectionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle sections on/off and edit their content below.'**
  String get toggleSectionsDesc;

  /// No description provided for @sectionHiddenWarning.
  ///
  /// In en, this message translates to:
  /// **'This section is currently hidden on the user side.'**
  String get sectionHiddenWarning;

  /// No description provided for @biographyTab.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biographyTab;

  /// No description provided for @kathasTab.
  ///
  /// In en, this message translates to:
  /// **'Kathas'**
  String get kathasTab;

  /// No description provided for @galleryTab.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryTab;

  /// No description provided for @stotraTab.
  ///
  /// In en, this message translates to:
  /// **'Stotra'**
  String get stotraTab;

  /// No description provided for @newsTab.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsTab;

  /// No description provided for @kathaPagesTab.
  ///
  /// In en, this message translates to:
  /// **'Katha Pages'**
  String get kathaPagesTab;

  /// No description provided for @photosTab.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosTab;

  /// No description provided for @videosTab.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videosTab;

  /// No description provided for @devoteeManagementTab.
  ///
  /// In en, this message translates to:
  /// **'Devotee Management'**
  String get devoteeManagementTab;

  /// No description provided for @contactEnquiriesTab.
  ///
  /// In en, this message translates to:
  /// **'Contact Enquiries'**
  String get contactEnquiriesTab;

  /// No description provided for @organizationName.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get organizationName;

  /// No description provided for @websiteLogo.
  ///
  /// In en, this message translates to:
  /// **'Website Logo'**
  String get websiteLogo;

  /// No description provided for @announcementBar.
  ///
  /// In en, this message translates to:
  /// **'Announcement Bar'**
  String get announcementBar;

  /// No description provided for @heroSlides.
  ///
  /// In en, this message translates to:
  /// **'HERO SLIDES'**
  String get heroSlides;

  /// No description provided for @slideNumber.
  ///
  /// In en, this message translates to:
  /// **'Slide #{number}'**
  String slideNumber(int number);

  /// No description provided for @badgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Badge (Small text above)'**
  String get badgeLabel;

  /// No description provided for @headingLabel.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get headingLabel;

  /// No description provided for @subtitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get subtitleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @primaryCtaText.
  ///
  /// In en, this message translates to:
  /// **'Primary CTA Text'**
  String get primaryCtaText;

  /// No description provided for @primaryCtaUrl.
  ///
  /// In en, this message translates to:
  /// **'Primary CTA URL'**
  String get primaryCtaUrl;

  /// No description provided for @secondaryCtaText.
  ///
  /// In en, this message translates to:
  /// **'Secondary CTA Text'**
  String get secondaryCtaText;

  /// No description provided for @secondaryCtaUrl.
  ///
  /// In en, this message translates to:
  /// **'Secondary CTA URL'**
  String get secondaryCtaUrl;

  /// No description provided for @slideImage.
  ///
  /// In en, this message translates to:
  /// **'Slide Image'**
  String get slideImage;

  /// No description provided for @addSlide.
  ///
  /// In en, this message translates to:
  /// **'ADD SLIDE'**
  String get addSlide;

  /// No description provided for @homepageHeroSlider.
  ///
  /// In en, this message translates to:
  /// **'HOMEPAGE HERO SLIDER'**
  String get homepageHeroSlider;

  /// No description provided for @addNewSlide.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW SLIDE'**
  String get addNewSlide;

  /// No description provided for @shreemadBhagvatTab.
  ///
  /// In en, this message translates to:
  /// **'Shreemad Bhagvat Katha'**
  String get shreemadBhagvatTab;

  /// No description provided for @devibhagvatTab.
  ///
  /// In en, this message translates to:
  /// **'Devibhagvat Katha'**
  String get devibhagvatTab;

  /// No description provided for @shivmahapuranTab.
  ///
  /// In en, this message translates to:
  /// **'Shivmahapuran Katha'**
  String get shivmahapuranTab;

  /// No description provided for @heroSection.
  ///
  /// In en, this message translates to:
  /// **'HERO SECTION'**
  String get heroSection;

  /// No description provided for @heroBadge.
  ///
  /// In en, this message translates to:
  /// **'Hero Badge'**
  String get heroBadge;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Hero Title'**
  String get heroTitle;

  /// No description provided for @heroDesc1.
  ///
  /// In en, this message translates to:
  /// **'Hero Description 1'**
  String get heroDesc1;

  /// No description provided for @heroDesc2.
  ///
  /// In en, this message translates to:
  /// **'Hero Description 2'**
  String get heroDesc2;

  /// No description provided for @heroImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Hero Image'**
  String get heroImageLabel;

  /// No description provided for @biographyQuote.
  ///
  /// In en, this message translates to:
  /// **'BIOGRAPHY & QUOTE'**
  String get biographyQuote;

  /// No description provided for @biographyText.
  ///
  /// In en, this message translates to:
  /// **'Biography Text'**
  String get biographyText;

  /// No description provided for @quoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quoteLabel;

  /// No description provided for @quoteAuthor.
  ///
  /// In en, this message translates to:
  /// **'Quote Author'**
  String get quoteAuthor;

  /// No description provided for @quoteImage.
  ///
  /// In en, this message translates to:
  /// **'Quote Image'**
  String get quoteImage;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'HIGHLIGHTS'**
  String get highlights;

  /// No description provided for @highlightTitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight {number} Title'**
  String highlightTitle(int number);

  /// No description provided for @highlightDesc.
  ///
  /// In en, this message translates to:
  /// **'Highlight {number} Description'**
  String highlightDesc(int number);

  /// No description provided for @callToAction.
  ///
  /// In en, this message translates to:
  /// **'CALL TO ACTION'**
  String get callToAction;

  /// No description provided for @ctaTitle.
  ///
  /// In en, this message translates to:
  /// **'CTA Title'**
  String get ctaTitle;

  /// No description provided for @ctaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CTA Subtitle'**
  String get ctaSubtitle;

  /// No description provided for @ctaButtonText.
  ///
  /// In en, this message translates to:
  /// **'CTA Button Text'**
  String get ctaButtonText;

  /// No description provided for @saveKathaPage.
  ///
  /// In en, this message translates to:
  /// **'SAVE KATHA PAGE'**
  String get saveKathaPage;

  /// No description provided for @upcomingKathasTitle.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING KATHAS'**
  String get upcomingKathasTitle;

  /// No description provided for @eventList.
  ///
  /// In en, this message translates to:
  /// **'EVENT LIST'**
  String get eventList;

  /// No description provided for @eventNumber.
  ///
  /// In en, this message translates to:
  /// **'Event #{number}'**
  String eventNumber(int number);

  /// No description provided for @kathaNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Katha Number'**
  String get kathaNumberLabel;

  /// No description provided for @kathaNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Katha Name'**
  String get kathaNameLabel;

  /// No description provided for @dateDisplayString.
  ///
  /// In en, this message translates to:
  /// **'Date Display String'**
  String get dateDisplayString;

  /// No description provided for @timingLabel.
  ///
  /// In en, this message translates to:
  /// **'Timing (e.g. 3:00 PM to 7:00 PM)'**
  String get timingLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @hostingLabel.
  ///
  /// In en, this message translates to:
  /// **'Hosting / Organizer'**
  String get hostingLabel;

  /// No description provided for @addKathaButton.
  ///
  /// In en, this message translates to:
  /// **'ADD KATHA'**
  String get addKathaButton;

  /// No description provided for @homePageManagement.
  ///
  /// In en, this message translates to:
  /// **'HOME PAGE MANAGEMENT'**
  String get homePageManagement;

  /// No description provided for @publishAll.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH ALL'**
  String get publishAll;

  /// No description provided for @sectionVisibilityAccess.
  ///
  /// In en, this message translates to:
  /// **'SECTION VISIBILITY & ACCESS'**
  String get sectionVisibilityAccess;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About Section'**
  String get aboutSection;

  /// No description provided for @ramKathaPreview.
  ///
  /// In en, this message translates to:
  /// **'Ram Katha Preview'**
  String get ramKathaPreview;

  /// No description provided for @biographySectionHome.
  ///
  /// In en, this message translates to:
  /// **'BIOGRAPHY SECTION (HOME)'**
  String get biographySectionHome;

  /// No description provided for @displayTitle.
  ///
  /// In en, this message translates to:
  /// **'Display Title'**
  String get displayTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Tagline'**
  String get tagline;

  /// No description provided for @mainIntroDesc.
  ///
  /// In en, this message translates to:
  /// **'Main Intro Description'**
  String get mainIntroDesc;

  /// No description provided for @biographyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Biography Photo'**
  String get biographyPhoto;

  /// No description provided for @detailedParagraphs.
  ///
  /// In en, this message translates to:
  /// **'DETAILED PARAGRAPHS'**
  String get detailedParagraphs;

  /// No description provided for @paragraphsLabel.
  ///
  /// In en, this message translates to:
  /// **'Paragraphs'**
  String get paragraphsLabel;

  /// No description provided for @galleryImages.
  ///
  /// In en, this message translates to:
  /// **'GALLERY IMAGES'**
  String get galleryImages;

  /// No description provided for @imageUrlsLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URLs'**
  String get imageUrlsLabel;

  /// No description provided for @saveAboutData.
  ///
  /// In en, this message translates to:
  /// **'SAVE ABOUT DATA'**
  String get saveAboutData;

  /// No description provided for @featuredQuoteSection.
  ///
  /// In en, this message translates to:
  /// **'FEATURED QUOTE SECTION'**
  String get featuredQuoteSection;

  /// No description provided for @quoteTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote Text'**
  String get quoteTextLabel;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// No description provided for @portraitImage.
  ///
  /// In en, this message translates to:
  /// **'Portrait Image'**
  String get portraitImage;

  /// No description provided for @backgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Background Image'**
  String get backgroundImage;

  /// No description provided for @saveQuote.
  ///
  /// In en, this message translates to:
  /// **'SAVE QUOTE'**
  String get saveQuote;

  /// No description provided for @dailySuvicharTitle.
  ///
  /// In en, this message translates to:
  /// **'DAILY SUVICHAR'**
  String get dailySuvicharTitle;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Label'**
  String get dateLabel;

  /// No description provided for @suvicharImage.
  ///
  /// In en, this message translates to:
  /// **'Suvichar Image'**
  String get suvicharImage;

  /// No description provided for @saveSuvichar.
  ///
  /// In en, this message translates to:
  /// **'SAVE SUVICHAR'**
  String get saveSuvichar;

  /// No description provided for @ramKathaPreviewSection.
  ///
  /// In en, this message translates to:
  /// **'RAM KATHA PREVIEW SECTION'**
  String get ramKathaPreviewSection;

  /// No description provided for @descPara1.
  ///
  /// In en, this message translates to:
  /// **'Description Para 1'**
  String get descPara1;

  /// No description provided for @descPara2.
  ///
  /// In en, this message translates to:
  /// **'Description Para 2'**
  String get descPara2;

  /// No description provided for @sectionPhoto.
  ///
  /// In en, this message translates to:
  /// **'Section Photo'**
  String get sectionPhoto;

  /// No description provided for @saveRamKathaSection.
  ///
  /// In en, this message translates to:
  /// **'SAVE RAM KATHA SECTION'**
  String get saveRamKathaSection;

  /// No description provided for @latestNewsItems.
  ///
  /// In en, this message translates to:
  /// **'LATEST NEWS ITEMS'**
  String get latestNewsItems;

  /// No description provided for @newsItemNumber.
  ///
  /// In en, this message translates to:
  /// **'News Item #{number}'**
  String newsItemNumber(int number);

  /// No description provided for @targetUrl.
  ///
  /// In en, this message translates to:
  /// **'Target URL (Read More)'**
  String get targetUrl;

  /// No description provided for @newsImage.
  ///
  /// In en, this message translates to:
  /// **'News Image'**
  String get newsImage;

  /// No description provided for @addNewsButton.
  ///
  /// In en, this message translates to:
  /// **'ADD NEWS'**
  String get addNewsButton;

  /// No description provided for @newsUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'NEWS & UPDATES'**
  String get newsUpdatesTitle;

  /// No description provided for @fullKathaListTitle.
  ///
  /// In en, this message translates to:
  /// **'FULL KATHA LIST'**
  String get fullKathaListTitle;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'ADD RECORD'**
  String get addRecord;

  /// No description provided for @kathaListPageSettings.
  ///
  /// In en, this message translates to:
  /// **'KATHA LIST PAGE SETTINGS'**
  String get kathaListPageSettings;

  /// No description provided for @mainListBannerImage.
  ///
  /// In en, this message translates to:
  /// **'Main List Banner Image'**
  String get mainListBannerImage;

  /// No description provided for @fullKathaArchive.
  ///
  /// In en, this message translates to:
  /// **'FULL KATHA ARCHIVE'**
  String get fullKathaArchive;

  /// No description provided for @kathaRecordNumber.
  ///
  /// In en, this message translates to:
  /// **'Katha Record #{number}'**
  String kathaRecordNumber(int number);

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @datesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dates (e.g. 1st Jan - 9th Jan)'**
  String get datesLabel;

  /// No description provided for @topicSubject.
  ///
  /// In en, this message translates to:
  /// **'Topic / Subject'**
  String get topicSubject;

  /// No description provided for @youtubePlaylistUrl.
  ///
  /// In en, this message translates to:
  /// **'YouTube Playlist URL'**
  String get youtubePlaylistUrl;

  /// No description provided for @recordImage.
  ///
  /// In en, this message translates to:
  /// **'Record Image'**
  String get recordImage;

  /// No description provided for @featuredPhotoAlbums.
  ///
  /// In en, this message translates to:
  /// **'FEATURED PHOTO ALBUMS'**
  String get featuredPhotoAlbums;

  /// No description provided for @manageSectionsDesc.
  ///
  /// In en, this message translates to:
  /// **'To manage full sections, go to Media & Content > Gallery > Photos.'**
  String get manageSectionsDesc;

  /// No description provided for @photoUrlsLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo URLs'**
  String get photoUrlsLabel;

  /// No description provided for @addSection.
  ///
  /// In en, this message translates to:
  /// **'ADD SECTION'**
  String get addSection;

  /// No description provided for @photoGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'PHOTO GALLERY'**
  String get photoGalleryTitle;

  /// No description provided for @featuredVideos.
  ///
  /// In en, this message translates to:
  /// **'FEATURED VIDEOS'**
  String get featuredVideos;

  /// No description provided for @manageVideosDesc.
  ///
  /// In en, this message translates to:
  /// **'To manage full categories, go to Media & Content > Gallery > Videos.'**
  String get manageVideosDesc;

  /// No description provided for @videoTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Video Title'**
  String get videoTitleLabel;

  /// No description provided for @youtubeUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'YouTube URL'**
  String get youtubeUrlLabel;

  /// No description provided for @addVideoButton.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideoButton;

  /// No description provided for @videoGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'VIDEO GALLERY'**
  String get videoGalleryTitle;

  /// No description provided for @stotraBhajanTitle.
  ///
  /// In en, this message translates to:
  /// **'STOTRA / BHAJAN'**
  String get stotraBhajanTitle;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'ADD ITEM'**
  String get addItem;

  /// No description provided for @stotraBhajanPageSettings.
  ///
  /// In en, this message translates to:
  /// **'STOTRA / BHAJAN PAGE SETTINGS'**
  String get stotraBhajanPageSettings;

  /// No description provided for @pageTitle.
  ///
  /// In en, this message translates to:
  /// **'Page Title'**
  String get pageTitle;

  /// No description provided for @topHeaderImage.
  ///
  /// In en, this message translates to:
  /// **'Top Header Image'**
  String get topHeaderImage;

  /// No description provided for @stotraItems.
  ///
  /// In en, this message translates to:
  /// **'STOTRA ITEMS'**
  String get stotraItems;

  /// No description provided for @stotraItemNumber.
  ///
  /// In en, this message translates to:
  /// **'Item #{number}'**
  String stotraItemNumber(int number);

  /// No description provided for @itemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Title'**
  String get itemTitle;

  /// No description provided for @englishPdfUrl.
  ///
  /// In en, this message translates to:
  /// **'English PDF URL'**
  String get englishPdfUrl;

  /// No description provided for @hindiPdfUrl.
  ///
  /// In en, this message translates to:
  /// **'Hindi PDF URL'**
  String get hindiPdfUrl;

  /// No description provided for @gujaratiPdfUrl.
  ///
  /// In en, this message translates to:
  /// **'Gujarati PDF URL'**
  String get gujaratiPdfUrl;

  /// No description provided for @contactPageSettings.
  ///
  /// In en, this message translates to:
  /// **'CONTACT PAGE SETTINGS'**
  String get contactPageSettings;

  /// No description provided for @pageBannerImage.
  ///
  /// In en, this message translates to:
  /// **'Page Banner Image'**
  String get pageBannerImage;

  /// No description provided for @publishContactSettings.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH CONTACT SETTINGS'**
  String get publishContactSettings;

  /// No description provided for @userInquiries.
  ///
  /// In en, this message translates to:
  /// **'USER INQUIRIES'**
  String get userInquiries;

  /// No description provided for @noInquiriesYet.
  ///
  /// In en, this message translates to:
  /// **'No inquiries yet.'**
  String get noInquiriesYet;

  /// No description provided for @countryPrefix.
  ///
  /// In en, this message translates to:
  /// **'Country: {country}'**
  String countryPrefix(String country);

  /// No description provided for @typePrefix.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String typePrefix(String type);

  /// No description provided for @messageHeader.
  ///
  /// In en, this message translates to:
  /// **'Message:'**
  String get messageHeader;

  /// No description provided for @replyOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'REPLY ON WHATSAPP'**
  String get replyOnWhatsApp;

  /// No description provided for @footerSettings.
  ///
  /// In en, this message translates to:
  /// **'FOOTER SETTINGS'**
  String get footerSettings;

  /// No description provided for @footerContent.
  ///
  /// In en, this message translates to:
  /// **'FOOTER CONTENT'**
  String get footerContent;

  /// No description provided for @copyrightText.
  ///
  /// In en, this message translates to:
  /// **'Copyright Text'**
  String get copyrightText;

  /// No description provided for @socialMediaLinks.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL MEDIA LINKS'**
  String get socialMediaLinks;

  /// No description provided for @whatsappUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Group/Number URL'**
  String get whatsappUrlLabel;

  /// No description provided for @bottomBarLinks.
  ///
  /// In en, this message translates to:
  /// **'BOTTOM BAR LINKS'**
  String get bottomBarLinks;

  /// No description provided for @privacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Label'**
  String get privacyLabel;

  /// No description provided for @privacyUrl.
  ///
  /// In en, this message translates to:
  /// **'Privacy URL'**
  String get privacyUrl;

  /// No description provided for @termsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms Label'**
  String get termsLabel;

  /// No description provided for @termsUrl.
  ///
  /// In en, this message translates to:
  /// **'Terms URL'**
  String get termsUrl;

  /// No description provided for @cookieLabel.
  ///
  /// In en, this message translates to:
  /// **'Cookie Label'**
  String get cookieLabel;

  /// No description provided for @cookieUrl.
  ///
  /// In en, this message translates to:
  /// **'Cookie URL'**
  String get cookieUrl;

  /// No description provided for @additionalLinkSections.
  ///
  /// In en, this message translates to:
  /// **'ADDITIONAL LINK SECTIONS (OPTIONAL)'**
  String get additionalLinkSections;

  /// No description provided for @sectionTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Section Title'**
  String get sectionTitleLabel;

  /// No description provided for @addLinkToSection.
  ///
  /// In en, this message translates to:
  /// **'Add Link to this section'**
  String get addLinkToSection;

  /// No description provided for @addNewLinkSection.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW LINK SECTION'**
  String get addNewLinkSection;

  /// No description provided for @heroSectionContent.
  ///
  /// In en, this message translates to:
  /// **'1. HERO SECTION CONTENT'**
  String get heroSectionContent;

  /// No description provided for @heroMainHeading.
  ///
  /// In en, this message translates to:
  /// **'Hero Main Heading'**
  String get heroMainHeading;

  /// No description provided for @heroSubtitleIntro.
  ///
  /// In en, this message translates to:
  /// **'Hero Subtitle / Intro'**
  String get heroSubtitleIntro;

  /// No description provided for @ctaButton1Text.
  ///
  /// In en, this message translates to:
  /// **'CTA Button 1 Text'**
  String get ctaButton1Text;

  /// No description provided for @ctaButton2Text.
  ///
  /// In en, this message translates to:
  /// **'CTA Button 2 Text'**
  String get ctaButton2Text;

  /// No description provided for @heroBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Hero Background Image'**
  String get heroBackgroundImage;

  /// No description provided for @heroSideCard.
  ///
  /// In en, this message translates to:
  /// **'2. HERO SIDE CARD (FEATURED)'**
  String get heroSideCard;

  /// No description provided for @cardTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Title'**
  String get cardTitle;

  /// No description provided for @cardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Card Subtitle'**
  String get cardSubtitle;

  /// No description provided for @cardFeatureImage.
  ///
  /// In en, this message translates to:
  /// **'Card Feature Image'**
  String get cardFeatureImage;

  /// No description provided for @sectionHeadings.
  ///
  /// In en, this message translates to:
  /// **'3. SECTION HEADINGS'**
  String get sectionHeadings;

  /// No description provided for @offeringsCategoriesHeading.
  ///
  /// In en, this message translates to:
  /// **'Offerings / Categories Heading'**
  String get offeringsCategoriesHeading;

  /// No description provided for @featuredProductsHeading.
  ///
  /// In en, this message translates to:
  /// **'Featured Products Heading'**
  String get featuredProductsHeading;

  /// No description provided for @testimonialsHeading.
  ///
  /// In en, this message translates to:
  /// **'Testimonials Heading'**
  String get testimonialsHeading;

  /// No description provided for @wisdomSuvicharHeading.
  ///
  /// In en, this message translates to:
  /// **'Wisdom / Suvichar Heading'**
  String get wisdomSuvicharHeading;

  /// No description provided for @whatsappGuidanceBox.
  ///
  /// In en, this message translates to:
  /// **'4. WHATSAPP GUIDANCE BOX'**
  String get whatsappGuidanceBox;

  /// No description provided for @guidanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Guidance Title'**
  String get guidanceTitle;

  /// No description provided for @guidanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guidance Subtitle'**
  String get guidanceSubtitle;

  /// No description provided for @whatsappBtnText.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Button Text'**
  String get whatsappBtnText;

  /// No description provided for @saveHomePortalChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE ALL HOME PORTAL CHANGES'**
  String get saveHomePortalChanges;

  /// No description provided for @productCatalogueHeadings.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT CATALOGUE HEADINGS'**
  String get productCatalogueHeadings;

  /// No description provided for @saveCatalogueSettings.
  ///
  /// In en, this message translates to:
  /// **'SAVE CATALOGUE SETTINGS'**
  String get saveCatalogueSettings;

  /// No description provided for @teachingsPageHero.
  ///
  /// In en, this message translates to:
  /// **'TEACHINGS PAGE HERO'**
  String get teachingsPageHero;

  /// No description provided for @heroBackground.
  ///
  /// In en, this message translates to:
  /// **'Hero Background'**
  String get heroBackground;

  /// No description provided for @divinePurposeSection.
  ///
  /// In en, this message translates to:
  /// **'DIVINE PURPOSE SECTION'**
  String get divinePurposeSection;

  /// No description provided for @sideImage.
  ///
  /// In en, this message translates to:
  /// **'Side Image'**
  String get sideImage;

  /// No description provided for @saveTeachingsPage.
  ///
  /// In en, this message translates to:
  /// **'SAVE TEACHINGS PAGE'**
  String get saveTeachingsPage;

  /// No description provided for @statusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusPrefix(String status);

  /// No description provided for @addItemTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {label}'**
  String addItemTo(String label);

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @searchVisibility.
  ///
  /// In en, this message translates to:
  /// **'Search Visibility'**
  String get searchVisibility;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hero Subtitle'**
  String get heroSubtitle;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @inactiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveStatus;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @outOfStockBadge.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStockBadge;

  /// No description provided for @sendViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send via WhatsApp'**
  String get sendViaWhatsApp;
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
