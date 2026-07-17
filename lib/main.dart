import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'controllers/homepage_controller.dart';
import 'views/user_side/user_homepage.dart';
import 'views/user_side/about_jignesh_dada_page.dart';
import 'views/user_side/about_katha_page.dart';
import 'views/user_side/about_devi_page.dart';
import 'views/user_side/about_shiv_page.dart';
import 'views/user_side/katha_list_page.dart';
import 'views/user_side/photo_gallery_page.dart';
import 'views/user_side/stotra_page.dart';
import 'views/user_side/upcoming_ram_kathas_page.dart';
import 'views/user_side/video_gallery_page.dart';
import 'views/user_side/contact_page.dart';
import 'views/user_side/news_page.dart';
import 'views/admin/admin_login_page.dart';
import 'views/admin/admin_dashboard.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLanguageCode = prefs.getString('selected_locale') ?? 'en';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomePageController()),
        ChangeNotifierProvider(create: (_) => LanguageController(savedLanguageCode)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C); 
    const backgroundBeige = Color(0xFFF9F3EA); 
    const accentBrown = Color(0xFFC19A6B); 

    final languageController = Provider.of<LanguageController>(context);

    // Dynamic Font Families based on Locale (derived from controller, NOT context,
    // because Localizations ancestor does not exist above MaterialApp)
    final String langCode = languageController.locale.languageCode;
    final String headingFont = langCode == 'gu'
        ? 'NotoSansGujarati'
        : langCode == 'hi'
            ? 'NotoSansDevanagari'
            : 'PlayfairDisplay';
    final String bodyFont = langCode == 'gu'
        ? 'NotoSansGujarati'
        : langCode == 'hi'
            ? 'NotoSansDevanagari'
            : 'Inter';

    return MaterialApp(
      title: 'Jignesh Dada Official',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('gu'),
        Locale('hi'),
      ],
      locale: languageController.locale,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: primaryTeal,
        
        // Base Text Theme
        textTheme: TextTheme(
          displayLarge: TextStyle(fontFamily: headingFont, fontWeight: FontWeight.w700, color: primaryTeal),
          displayMedium: TextStyle(fontFamily: headingFont, fontWeight: FontWeight.w700, color: primaryTeal),
          displaySmall: TextStyle(fontFamily: headingFont, fontWeight: FontWeight.w700, color: primaryTeal),
          headlineLarge: TextStyle(fontFamily: headingFont, fontWeight: FontWeight.w700, color: primaryTeal),
          headlineMedium: TextStyle(fontFamily: headingFont, fontWeight: FontWeight.w700, color: primaryTeal),
          headlineSmall: TextStyle(fontFamily: headingFont, fontWeight: FontWeight.w600, color: primaryTeal),
          titleLarge: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w400, fontSize: 17, height: 1.8),
          bodyMedium: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w400, fontSize: 16),
          labelLarge: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          primary: primaryTeal,
          secondary: accentBrown,
          surface: Colors.white,
          error: Colors.redAccent,
        ).copyWith(background: backgroundBeige),
        
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: primaryTeal,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: headingFont,
            color: primaryTeal,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: primaryTeal, width: 1.5),
          ),
          labelStyle: TextStyle(fontFamily: bodyFont, color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          ),
        ),
        
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryTeal,
            side: BorderSide(color: primaryTeal, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            textStyle: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const UserHomePage(),
        '/about_dada': (context) => const AboutJigneshDadaPage(),
        '/about_katha': (context) => const AboutKathaPage(),
        '/about_devi_katha': (context) => const AboutDeviPage(),
        '/about_shiv_katha': (context) => const AboutShivPage(),
        '/katha_list': (context) => const KathaListPage(),
        '/photo_gallery': (context) => const PhotoGalleryPage(),
        '/stotra': (context) => const StotraPage(),
        '/upcoming_ram_kathas': (context) => const UpcomingRamKathasPage(),
        '/video_gallery': (context) => const VideoGalleryPage(),
        '/contact_us': (context) => const ContactPage(),
        '/news': (context) => const NewsPage(),
        '/admin_login': (context) => const AdminLoginPage(),
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
