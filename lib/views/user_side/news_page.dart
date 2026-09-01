import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import '../../utils/responsive_utils.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 40),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final newsList = controller.homepageData.news;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final bool isMobile = Responsive.isMobile(context);

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),

          // Hero Title Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
            color: backgroundBeige.withValues(alpha: 0.5),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.latestNews,
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: AppTypography.getResponsiveSize(
                        context, desktop: 52, tablet: 44, mobile: 34),
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.homeNews,
                  style: AppTypography.bodyStyle(
                    context,
                    color: primaryTeal.withValues(alpha: 0.6),
                    fontSize: isMobile ? 14 : 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 40 : 80),

          // News Grid — responsive padding
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                crossAxisSpacing: isMobile ? 15 : 30,
                mainAxisSpacing: isMobile ? 30 : 50,
                childAspectRatio: isMobile ? 0.9 : 0.85,
              ),
              itemCount: newsList.length,
              itemBuilder: (context, index) =>
                  _buildNewsCard(context, newsList[index], accentBrown, primaryTeal, lang),
            ),
          ),

          SizedBox(height: isMobile ? 60 : 120),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, NewsItem item, Color accentGold,
      Color primaryTeal, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showFullScreenImage(context, item.image),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEE6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.image.isNotEmpty
                    ? Image.network(item.image, fit: BoxFit.cover)
                    : const Icon(Icons.newspaper_rounded, size: 50, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          item.localizedCategory(lang).toUpperCase(),
          style: AppTypography.bodyStyle(
            context,
            color: accentGold,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          item.localizedTitle(lang),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headingStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.localizedDate(lang),
              style: AppTypography.bodyStyle(
                context,
                color: const Color(0xFF6D6D6D),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
            if (item.url.isNotEmpty)
              TextButton(
                onPressed: () => _launchUrl(item.url),
                child: Text(
                  AppLocalizations.of(context)!.readMore,
                  style: AppTypography.bodyStyle(
                    context,
                    color: primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
