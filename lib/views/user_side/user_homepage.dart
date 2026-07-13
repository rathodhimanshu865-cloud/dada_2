import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_hero_slider.dart';
import 'sections/user_featured_quote.dart';
import 'sections/user_about_preview.dart';
import 'sections/user_upcoming_kathas.dart';
import 'sections/user_latest_videos.dart';
import 'sections/user_photo_gallery.dart';
import 'sections/user_daily_suvichar.dart';
import 'sections/user_ram_katha.dart';
import 'sections/user_news.dart';
import 'sections/user_donation_cta.dart';
import 'sections/user_footer.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    
    if (controller.isLoading && controller.websiteSettings.name.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F4C5C)),
        ),
      );
    }

    return UserPageLayout(
      controller: controller,
      scrollController: _scrollController,
      child: Column(
        children: [
          UserHeroSlider(controller: controller),
          UserFeaturedQuote(controller: controller),
          UserAboutPreview(controller: controller),
          UserUpcomingKathas(controller: controller),
          UserLatestVideos(controller: controller),
          UserPhotoGallery(controller: controller),
          // Spiritual Teachings removed
          UserDailySuvichar(controller: controller),
          UserRamKatha(controller: controller), // This is the "About Katha" preview section
          // Testimonials removed
          UserNews(controller: controller),
          UserDonationCTA(controller: controller),
          UserFooter(controller: controller),
        ],
      ),
    );
  }
}
