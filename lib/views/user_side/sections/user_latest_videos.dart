import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../utils/app_typography.dart';

class UserLatestVideos extends StatelessWidget {
  final HomePageController controller;
  const UserLatestVideos({super.key, required this.controller});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.videos.isEmpty) return const SizedBox.shrink();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 20 : 40,
      ),
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Column(
            children: [
              Text(
                AppLocalizations.of(context)!.watchAndReflect,
                style: AppTypography.bodyStyle(
                  context,
                  color: const Color(0xFFC89A5B),
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.latestVideos,
                textAlign: TextAlign.center,
                style: AppTypography.headingStyle(
                  context,
                  fontSize: isMobile ? 32 : 42,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F4C5C),
                ),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),

          SizedBox(height: isMobile ? 50 : 80),

          // Responsive Video Grid
          Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1000
                  ? 3
                  : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isMobile ? 15 : 30,
                  mainAxisSpacing: isMobile ? 30 : 40,
                  childAspectRatio: isMobile ? 1.4 : 1.2,
                ),
                itemCount: controller.videos.take(6).length,
                itemBuilder: (context, index) =>
                    _buildVideoCard(context, controller.videos[index]),
              );
            }),
          ),

          SizedBox(height: isMobile ? 50 : 80),

          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/video_gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 30 : 50,
                vertical: isMobile ? 18 : 25,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              AppLocalizations.of(context)!.viewAllVideos,
              style: AppTypography.bodyStyle(
                context,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, dynamic video) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    return GestureDetector(
      onTap: () => _launchUrl(video.youtubeUrl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 30, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            video.localizedTitle(lang).toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.youtubeDiscourse,
            style: AppTypography.bodyStyle(
              context,
              color: const Color(0xFFC89A5B),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
