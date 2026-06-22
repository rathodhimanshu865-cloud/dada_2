import 'package:flutter/material.dart';
import '../controllers/homepage_controller.dart';
import 'sections/website_settings_section.dart';
import 'sections/notice_bar_section.dart';
import 'sections/hero_banner_section.dart';
import 'sections/live_katha_section.dart';
import 'sections/about_dada_section.dart';
import 'sections/upcoming_katha_section.dart';
import 'sections/latest_videos_section.dart';
import 'sections/suvichar_section.dart';
import 'sections/gallery_section.dart';
import 'sections/statistics_section.dart';
import 'sections/social_media_section.dart';
import 'sections/contact_info_section.dart';
import 'sections/footer_settings_section.dart';

class HomePageAdminPage extends StatefulWidget {
  const HomePageAdminPage({super.key});

  @override
  State<HomePageAdminPage> createState() => _HomePageAdminPageState();
}

class _HomePageAdminPageState extends State<HomePageAdminPage> {
  final HomePageController _controller = HomePageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.dashboard_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('DADA PANEL'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: () => _controller.saveAll(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('PUBLISH CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[300]),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar indicator (Optional decoration for professional look)
              Container(
                width: 60,
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildSidebarIcon(Icons.home, true),
                    _buildSidebarIcon(Icons.settings, false),
                    _buildSidebarIcon(Icons.image_outlined, false),
                    _buildSidebarIcon(Icons.video_collection_outlined, false),
                  ],
                ),
              ),
              VerticalDivider(width: 1, color: Colors.grey[300]),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  children: [
                    const Text(
                      'Homepage Management',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                    const Text(
                      'Configure all sections of the public website from this dashboard.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('CORE CONFIGURATION'),
                    WebsiteSettingsSection(controller: _controller),
                    NoticeBarSection(controller: _controller),
                    const SizedBox(height: 32),
                    _buildSectionHeader('HERO & LIVE CONTENT'),
                    HeroBannerSection(controller: _controller),
                    LiveKathaSection(controller: _controller),
                    const SizedBox(height: 32),
                    _buildSectionHeader('BIOGRAPHY & RECORDS'),
                    AboutDadaSection(controller: _controller),
                    UpcomingKathaSection(controller: _controller),
                    LatestVideosSection(controller: _controller),
                    const SizedBox(height: 32),
                    _buildSectionHeader('RESOURCES & STATS'),
                    SuvicharSection(controller: _controller),
                    GallerySection(controller: _controller),
                    StatisticsSection(controller: _controller),
                    const SizedBox(height: 32),
                    _buildSectionHeader('FOOTER & SOCIAL'),
                    SocialMediaSection(controller: _controller),
                    ContactInfoSection(controller: _controller),
                    FooterSettingsSection(controller: _controller),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebarIcon(IconData icon, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Icon(icon, color: selected ? Colors.black : Colors.grey[400]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.grey[600],
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
