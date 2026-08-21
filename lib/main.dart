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
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'controllers/language_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'views/user_side/product_detail_page.dart';
import 'views/user_side/cart_page.dart';
import 'views/user_side/checkout_page.dart';
import 'views/user_side/auth/login_page.dart';
import 'views/user_side/auth/signup_page.dart';
import 'views/user_side/profile/my_orders_page.dart';

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
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CartController()),
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
        scaffoldBackgroundColor: Colors.white,
        primaryColor: primaryTeal,
        textTheme: TextTheme(
          displayLarge:  (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 57, fontWeight: FontWeight.w700, color: primaryTeal) : GoogleFonts.cormorantGaramond(fontSize: 57, fontWeight: FontWeight.w700, color: primaryTeal),
          displayMedium: (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 45, fontWeight: FontWeight.w700, color: primaryTeal) : GoogleFonts.cormorantGaramond(fontSize: 45, fontWeight: FontWeight.w700, color: primaryTeal),
          displaySmall:  (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 36, fontWeight: FontWeight.w700, color: primaryTeal) : GoogleFonts.cormorantGaramond(fontSize: 36, fontWeight: FontWeight.w700, color: primaryTeal),
          headlineLarge: (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 32, fontWeight: FontWeight.w700, color: primaryTeal) : GoogleFonts.cormorantGaramond(fontSize: 32, fontWeight: FontWeight.w700, color: primaryTeal),
          headlineMedium:(langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 28, fontWeight: FontWeight.w700, color: primaryTeal) : GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w700, color: primaryTeal),
          headlineSmall: (langCode == 'hi' || langCode == 'gu') ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', fontSize: 24, fontWeight: FontWeight.w600, color: primaryTeal) : GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w600, color: primaryTeal),
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
          titleTextStyle: (langCode == 'hi' || langCode == 'gu')
              ? TextStyle(fontFamily: langCode == 'hi' ? 'NotoSansDevanagari' : 'NotoSansGujarati', color: primaryTeal, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)
              : GoogleFonts.cormorantGaramond(color: primaryTeal, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey[400]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: primaryTeal, width: 1.5)),
          labelStyle: GoogleFonts.nunito(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryTeal,
            side: const BorderSide(color: primaryTeal, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/cart') {
          return MaterialPageRoute(builder: (_) => const CartPage());
        }

        if (settings.name == '/checkout') {
          return MaterialPageRoute(builder: (_) => const CheckoutPage());
        }

        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }

        if (settings.name == '/signup') {
          return MaterialPageRoute(builder: (_) => const SignupPage());
        }

        if (settings.name == '/my_orders') {
          return MaterialPageRoute(builder: (_) => const MyOrdersPage());
        }

        if (settings.name != null && settings.name!.startsWith('/products/')) {
          final slug = settings.name!.replaceFirst('/products/', '');
          return MaterialPageRoute(builder: (_) => ProductDetailPage(slug: slug));
        }

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
        '/admin_login': (context) => const AdminLoginPage(),
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
