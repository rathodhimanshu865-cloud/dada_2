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
import 'views/user_side/product_home_page.dart';
import 'views/user_side/product_details_page.dart';
import 'views/user_side/catalogue_page.dart';
import 'views/user_side/pu_dada_teachings_page.dart';
import 'views/user_side/cart_page.dart';
import 'views/user_side/checkout_page.dart';
import 'views/admin/admin_login_page.dart';
import 'views/admin/admin_dashboard.dart';

import 'views/user_side/auth/login_page.dart';
import 'views/user_side/auth/signup_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'controllers/cart_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/auth_controller.dart';

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
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlack = Color(0xFF111111);
    const backgroundWhite = Color(0xFFFFFFFF);
    const accentGrey = Color(0xFF757575);

    final languageController = Provider.of<LanguageController>(context);

    final String langCode = languageController.locale.languageCode;

    return MaterialApp(
      title: 'Jignesh Dada Official',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
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
        scaffoldBackgroundColor: backgroundWhite,
        primaryColor: primaryBlack,
        textTheme: TextTheme(
          displayLarge:  (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 57, fontWeight: FontWeight.w700, color: primaryBlack) : GoogleFonts.cormorantGaramond(fontSize: 57, fontWeight: FontWeight.w700, color: primaryBlack),
          displayMedium: (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 45, fontWeight: FontWeight.w700, color: primaryBlack) : GoogleFonts.cormorantGaramond(fontSize: 45, fontWeight: FontWeight.w700, color: primaryBlack),
          displaySmall:  (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 36, fontWeight: FontWeight.w700, color: primaryBlack) : GoogleFonts.cormorantGaramond(fontSize: 36, fontWeight: FontWeight.w700, color: primaryBlack),
          headlineLarge: (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 32, fontWeight: FontWeight.w700, color: primaryBlack) : GoogleFonts.cormorantGaramond(fontSize: 32, fontWeight: FontWeight.w700, color: primaryBlack),
          headlineMedium:(langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 28, fontWeight: FontWeight.w700, color: primaryBlack) : GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w700, color: primaryBlack),
          headlineSmall: (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 24, fontWeight: FontWeight.w600, color: primaryBlack) : GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w600, color: primaryBlack),
          titleLarge:    (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 22, fontWeight: FontWeight.w600) : GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium:   (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 16, fontWeight: FontWeight.w600) : GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
          titleSmall:    (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 14, fontWeight: FontWeight.w600) : GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
          bodyLarge:     (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 17, fontWeight: FontWeight.w400, height: 1.8) : GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w400, height: 1.8),
          bodyMedium:    (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 16, fontWeight: FontWeight.w400) : GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400),
          bodySmall:     (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 13, fontWeight: FontWeight.w400) : GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w400),
          labelLarge:    (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 16, fontWeight: FontWeight.w600) : GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
          labelMedium:   (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 12, fontWeight: FontWeight.w500) : GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlack,
          primary: primaryBlack,
          secondary: accentGrey,
          surface: backgroundWhite,
          error: Colors.redAccent,
        ).copyWith(surface: backgroundWhite),
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundWhite,
          foregroundColor: primaryBlack,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: (langCode == 'hi' || langCode == 'gu')
              ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', color: primaryBlack, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)
              : GoogleFonts.cormorantGaramond(color: primaryBlack, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        cardTheme: CardThemeData(
          color: backgroundWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: backgroundWhite,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: primaryBlack, width: 1.5)),
          labelStyle: GoogleFonts.nunito(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlack,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryBlack,
            side: const BorderSide(color: primaryBlack, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Default routes
        return null;
      },
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
        '/product': (context) => const ProductHomePage(),
        '/product_details': (context) => const ProductDetailsPage(),
        '/catalogue': (context) => const CataloguePage(),
        '/teachings': (context) => const PuDadaTeachingsPage(),
        '/cart': (context) => const CartPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/admin_login': (context) => const AdminLoginPage(),
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
