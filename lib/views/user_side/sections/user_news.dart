import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../utils/app_typography.dart';

class UserNews extends StatefulWidget {
  final HomePageController controller;
  const UserNews({super.key, required this.controller});

  @override
  State<UserNews> createState() => _UserNewsState();
}

class _UserNewsState extends State<UserNews> {
  bool _isVisible = false;

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = widget.controller.homepageData.news;
    if (news.isEmpty) return const SizedBox.shrink();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    final displayNews = news.take(4).toList();

    return VisibilityDetector(
      key: const Key('user-news-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          if (mounted) setState(() => _isVisible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 120,
          horizontal: isMobile ? 20 : 40,
        ),
        color: const Color(0xFFFAF8F4),
        child: Column(
          children: [
            // Header — fades+drops in
            FadeInDown(
              animate: _isVisible,
              duration: const Duration(milliseconds: 600),
              child: Column(
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
                    textAlign: TextAlign.center,
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
            ),

            SizedBox(height: isMobile ? 50 : 80),

            // News Grid — each card staggered
            Container(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: LayoutBuilder(builder: (context, constraints) {
                int cols = constraints.maxWidth > 1200
                    ? 4
                    : (constraints.maxWidth > 800 ? 2 : 1);
                return Wrap(
                  spacing: isMobile ? 15 : 25,
                  runSpacing: isMobile ? 30 : 40,
                  children: displayNews.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return FadeInUp(
                      animate: _isVisible,
                      duration: const Duration(milliseconds: 600),
                      delay: Duration(milliseconds: 80 * index),
                      child: SizedBox(
                        width: cols == 1
                            ? double.infinity
                            : (constraints.maxWidth - (cols - 1) * (isMobile ? 15 : 25)) / cols,
                        height: isMobile ? 300 : 400,
                        child: _buildNewsCard(context, item),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),

            SizedBox(height: isMobile ? 40 : 60),

            FadeInUp(
              animate: _isVisible,
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 320),
              child: ElevatedButton(
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
            ),
          ],
        ),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                    color: Colors.black.withOpacity(0.06),
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
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
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
