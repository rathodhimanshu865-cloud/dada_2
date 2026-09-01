import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../utils/app_typography.dart';

class UserNews extends StatelessWidget {
  final HomePageController controller;
  const UserNews({super.key, required this.controller});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = controller.homepageData.news;
    if (news.isEmpty) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 900;
    final displayNews = news.take(4).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 70 : 120,
        horizontal: isMobile ? 20 : 40,
      ),
      color: const Color(0xFFFAF8F4),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              Text(
                AppLocalizations.of(context)!.latestUpdates,
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
                AppLocalizations.of(context)!.newsAndEvents,
                style: AppTypography.headingStyle(
                  context,
                  fontSize: isMobile ? 30 : 42,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F4C5C),
                ),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),

          SizedBox(height: isMobile ? 50 : 80),

          // News Grid (responsive)
          Container(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: LayoutBuilder(builder: (context, constraints) {
              int cols = constraints.maxWidth > 1000
                  ? 4
                  : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: isMobile ? 15 : 25,
                  mainAxisSpacing: isMobile ? 30 : 40,
                  childAspectRatio: isMobile ? 0.9 : 0.8,
                ),
                itemCount: displayNews.length,
                itemBuilder: (context, index) =>
                    _buildNewsCard(context, displayNews[index]),
              );
            }),
          ),

          SizedBox(height: isMobile ? 40 : 60),

          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/news'),
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
              AppLocalizations.of(context)!.viewAllNews,
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

  Widget _buildNewsCard(BuildContext context, NewsItem item) {
    final lang = Localizations.localeOf(context).languageCode;
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
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.image.isNotEmpty
                    ? Image.network(item.image, fit: BoxFit.cover)
                    : const Icon(Icons.newspaper_rounded, size: 50, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _launchUrl(item.url),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.localizedCategory(lang).toUpperCase(),
                style: AppTypography.bodyStyle(
                  context,
                  color: const Color(0xFFC89A5B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.localizedTitle(lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headingStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.localizedDate(lang),
                style: AppTypography.bodyStyle(
                  context,
                  color: const Color(0xFF6D6D6D),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
