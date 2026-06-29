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
import 'views/admin/admin_login_page.dart';
import 'views/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageController(),
      child: MaterialApp(
        title: 'Dada Admin & User Panel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            primary: Colors.black,
            secondary: Colors.grey[800]!,
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
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
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          '/admin_login': (context) => const AdminLoginPage(),
          '/admin_dashboard': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}
