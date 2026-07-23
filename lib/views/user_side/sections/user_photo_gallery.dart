import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class UserPhotoGallery extends StatelessWidget {
  final HomePageController controller;
  const UserPhotoGallery({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final sections = controller.photoGalleryData.sections;
    if (sections.isEmpty) return const SizedBox.shrink();

    // Flatten all photos for a homepage masonry preview
    final List<String> allPhotos = [];
    for (var s in sections) {
      allPhotos.addAll(s.photoUrls);
    }

    if (allPhotos.isEmpty) return const SizedBox.shrink();
    final displayPhotos = allPhotos.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      color: const Color(0xFFFAF8F4),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              Text(
                AppLocalizations.of(context)!.sacredMoments,
                style: const TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.divineGallery,
                style: const TextStyle(fontSize: 42, fontFamily: 'serif', fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C)),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),
          
          const SizedBox(height: 80),

          // Masonry-style Grid
          Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: LayoutBuilder(builder: (context, constraints) {
              int cols = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 2);
              double colWidth = (constraints.maxWidth - (cols - 1) * 20) / cols;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(cols, (colIdx) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: colIdx < cols - 1 ? 20 : 0),
                      child: Column(
                        children: displayPhotos.asMap().entries
                          .where((e) => e.key % cols == colIdx)
                          .map<Widget>((e) => _buildGalleryItem(context, e.value, colIdx, e.key))
                          .toList(),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
          
          const SizedBox(height: 80),
          
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/photo_gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(AppLocalizations.of(context)!.exploreFullGallery, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
        insetPadding: const EdgeInsets.all(40),
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

  Widget _buildGalleryItem(BuildContext context, String url, int colIdx, int globalIdx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _showFullScreenImage(context, url),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: Colors.white, size: 50),
          ),
        ),
      ),
    );
  }
}
