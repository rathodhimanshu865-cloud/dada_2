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
import 'sections/user_teachings.dart';
import 'sections/user_news.dart';
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
          if (controller.homepageData.showHeroSlider) UserHeroSlider(controller: controller),
          if (controller.homepageData.showFeaturedQuote) UserFeaturedQuote(controller: controller),
          if (controller.homepageData.showAboutPreview) UserAboutPreview(controller: controller),
          if (controller.homepageData.showUpcomingKathas) UserUpcomingKathas(controller: controller),
          if (controller.homepageData.showLatestVideos) UserLatestVideos(controller: controller),
          if (controller.homepageData.showPhotoGallery) UserPhotoGallery(controller: controller),
          if (controller.homepageData.showTeachings) UserTeachings(controller: controller),
          if (controller.homepageData.showDailySuvichar) UserDailySuvichar(controller: controller),
          if (controller.homepageData.showRamKathaSection) UserRamKatha(controller: controller),
          if (controller.homepageData.showNewsSection) UserNews(controller: controller),
          UserFooter(controller: controller),
        ],
      ),
    );
  }
}
