import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      color: const Color(0xFFFAF8F4),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              const Text(
                "SACRED MOMENTS",
                style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text(
                "Divine Gallery",
                style: TextStyle(fontSize: 42, fontFamily: 'serif', fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C)),
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
                        children: allPhotos.asMap().entries
                            .where((e) => e.key % cols == colIdx)
                            .map((e) => _buildGalleryItem(e.value, colIdx, e.key))
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
            child: const Text('EXPLORE FULL GALLERY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(String url, int colIdx, int globalIdx) {
    // Alternate height for masonry feel
    double height = (globalIdx % 3 == 0) ? 400 : 300;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: Colors.white, size: 50),
        ),
      ),
    );
  }
}
