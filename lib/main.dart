import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/homepage_controller.dart';
import 'views/user_side/user_homepage.dart';
import 'views/user_side/about_katha_page.dart';
import 'views/user_side/katha_list_page.dart';
import 'views/user_side/photo_gallery_page.dart';
import 'views/user_side/stotra_page.dart';
import 'views/user_side/upcoming_ram_kathas_page.dart';
import 'views/user_side/video_gallery_page.dart';
import 'views/user_side/contact_page.dart';
import 'views/admin/admin_login_page.dart';
import 'views/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // New Color Palette based on provided home page photo
    const primaryTeal = Color(0xFF0F4C5C); // Dark Teal from buttons/footer
    const backgroundBeige = Color(0xFFF9F3EA); // Light Cream/Beige background
    const accentBrown = Color(0xFFC19A6B); // Gold/Brown accent from icons

    return ChangeNotifierProvider(
      create: (_) => HomePageController(),
      child: MaterialApp(
        title: 'Jignesh Dada Official',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: primaryTeal,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryTeal,
            primary: primaryTeal,
            secondary: accentBrown,
            surface: Colors.white,
            background: backgroundBeige,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: primaryTeal,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: primaryTeal,
              fontSize: 22,
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
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryTeal,
              side: BorderSide(color: primaryTeal, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const UserHomePage(),
          '/about_katha': (context) => const AboutKathaPage(),
          '/katha_list': (context) => const KathaListPage(),
          '/photo_gallery': (context) => const PhotoGalleryPage(),
          '/stotra': (context) => const StotraPage(),
          '/upcoming_ram_kathas': (context) => const UpcomingRamKathasPage(),
          '/video_gallery': (context) => const VideoGalleryPage(),
          '/contact_us': (context) => const ContactPage(),
          '/admin_login': (context) => const AdminLoginPage(),
          '/admin_dashboard': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}
