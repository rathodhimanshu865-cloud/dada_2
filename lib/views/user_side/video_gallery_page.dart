import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class VideoGalleryPage extends StatelessWidget {
  const VideoGalleryPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final data = controller.videoGalleryData;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final isMobile = MediaQuery.of(context).size.width < 900;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
            color: backgroundBeige.withOpacity(0.5),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.videoGallery, style: TextStyle(fontSize: isMobile ? 32 : 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.homeGalleryVideos, style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: isMobile ? 14 : 16, letterSpacing: 0.5)),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 40 : 80),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
            child: Column(
              children: data.categories.map((category) => _buildVideoSection(context, category, primaryTeal, accentBrown, lang)).toList(),
            ),
          ),
          SizedBox(height: isMobile ? 50 : 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context, dynamic category, Color primaryTeal, Color accentBrown, String lang) {
    if (category.videos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Column(children: [Text(category.localizedCategoryTitle(lang).toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF444444), letterSpacing: 2)), const SizedBox(height: 15), Container(width: 60, height: 3, color: accentBrown)]),
        const SizedBox(height: 60),
        LayoutBuilder(builder: (context, constraints) {
          int cols = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1));
          bool isMobile = MediaQuery.of(context).size.width < 900;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(cols, (colIdx) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: colIdx < cols - 1 ? (isMobile ? 15 : 30) : 0),
                  child: Column(
                    children: category.videos.asMap().entries
                        .where((e) => e.key % cols == colIdx)
                        .map<Widget>((e) => _buildVideoCard(e.value, primaryTeal, lang, isMobile))
                        .toList(),
                  ),
                ),
              );
            }),
          );
        }),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildVideoCard(dynamic video, Color primaryTeal, String lang, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 15 : 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        GestureDetector(
          onTap: () => _launchUrl(video.youtubeUrl),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 16/9,
                      child: Image.network(video.thumbnail, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[200])),
                    ),
                    Positioned.fill(child: Container(color: Colors.black.withOpacity(0.15))),
                    const Icon(Icons.play_circle_outline, color: Colors.white, size: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Text(video.localizedTitle(lang).toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF444444), height: 1.4, letterSpacing: 0.5)),
      ],
    ),
  );
}
}
