import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../utils/app_typography.dart';

class UserPhotoGallery extends StatelessWidget {
  final HomePageController controller;
  const UserPhotoGallery({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final sections = controller.photoGalleryData.sections;
    if (sections.isEmpty) return const SizedBox.shrink();

    final List<String> allPhotos = [];
    for (var s in sections) {
      allPhotos.addAll(s.photoUrls);
    }
    if (allPhotos.isEmpty) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 900;
    final displayPhotos = allPhotos.take(isMobile ? 4 : 4).toList();

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
                AppLocalizations.of(context)!.sacredMoments,
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
                AppLocalizations.of(context)!.divineGallery,
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

          // Masonry-style Grid — responsive columns
          Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: LayoutBuilder(builder: (context, constraints) {
              int cols = constraints.maxWidth > 1200
                  ? 4
                  : (constraints.maxWidth > 800 ? 3 : 2);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(cols * 2 - 1, (index) {
                  if (index.isOdd) {
                    return SizedBox(width: isMobile ? 10 : 20);
                  }
                  int colIdx = index ~/ 2;
                  return Expanded(
                    child: Column(
                      children: displayPhotos
                          .asMap()
                          .entries
                          .where((e) => e.key % cols == colIdx)
                          .map<Widget>(
                              (e) => _buildGalleryItem(context, e.value))
                          .toList(),
                    ),
                  );
                }),
              );
            }),
          ),

          SizedBox(height: isMobile ? 50 : 80),

          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/photo_gallery'),
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
              AppLocalizations.of(context)!.exploreFullGallery,
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

  Widget _buildGalleryItem(BuildContext context, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _showFullScreenImage(context, url),
          child: AspectRatio(
            aspectRatio: 0.85,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_outlined, color: Colors.grey, size: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
