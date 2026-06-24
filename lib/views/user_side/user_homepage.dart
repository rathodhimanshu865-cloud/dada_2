import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_header.dart';
import 'sections/user_hero.dart';
import 'sections/user_upcoming_kathas.dart';
import 'sections/user_about.dart';
import 'sections/user_latest_chaupai.dart';
import 'sections/user_videos.dart';
import 'sections/user_ram_katha.dart';
import 'sections/user_footer.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    
    if (controller.isLoading && controller.websiteSettings.name.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            UserHero(controller: controller),
            UserUpcomingKathas(controller: controller),
            UserAbout(controller: controller),
            UserLatestChaupai(controller: controller),
            UserVideos(controller: controller),
            UserRamKatha(controller: controller),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }
}
