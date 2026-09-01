import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../utils/app_typography.dart';

class UserPhotoGallery extends StatelessWidget {
  final HomePageController controller;
  const UserPhotoGallery({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final List<String> allPhotos = controller.realTimePhotos
        .map((p) => p['url'] as String? ?? '')
        .where((u) => u.isNotEmpty)
        .toList();
    if (allPhotos.isEmpty) return const SizedBox.shrink();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    final displayPhotos = allPhotos.take(isMobile ? 6 : 4).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 120,
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

          // Masonry-style Grid — responsive columns
          Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: LayoutBuilder(builder: (context, constraints) {
              int cols = constraints.maxWidth > 1200
                  ? 4
                  : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1));

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(cols * 2 - 1, (index) {
                  if (index.isOdd) {
                    return SizedBox(width: isMobile ? 12 : 20);
                  }
                  int colIdx = index ~/ 2;
                  return Expanded(
                    child: Column(
                      children: displayPhotos
                          .asMap()
                          .entries
                          .where((e) => e.key % cols == colIdx)
                          .map<Widget>(
                              (e) => _buildGalleryItem(context, e.value, allPhotos.indexOf(e.value), allPhotos))
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

  void _showFullScreenGallery(BuildContext context, int initialIndex, List<String> allPhotos) {
    showDialog(
      context: context,
      builder: (context) {
        int currentIndex = initialIndex;
        return StatefulBuilder(
          builder: (context, setState) {
            final isMobile = MediaQuery.of(context).size.width < 900;
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: isMobile ? const EdgeInsets.all(10) : const EdgeInsets.all(40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < 0) {
                          setState(() {
                            currentIndex = (currentIndex + 1) % allPhotos.length;
                          });
                        } else if (details.primaryVelocity! > 0) {
                          setState(() {
                            currentIndex = (currentIndex - 1 + allPhotos.length) % allPhotos.length;
                          });
                        }
                      }
                    },
                    child: InteractiveViewer(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            allPhotos[currentIndex],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    Positioned(
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
                          onPressed: () {
                            setState(() {
                              currentIndex = (currentIndex - 1 + allPhotos.length) % allPhotos.length;
                            });
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                          onPressed: () {
                            setState(() {
                              currentIndex = (currentIndex + 1) % allPhotos.length;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGalleryItem(BuildContext context, String url, int index, List<String> allPhotos) {
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
          onTap: () => _showFullScreenGallery(context, index, allPhotos),
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

