import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';

class GallerySection extends StatefulWidget {
  final HomePageController controller;
  const GallerySection({super.key, required this.controller});

  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: const Text('Photo Gallery Preview', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Grid display for the homepage gallery', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.photo_library_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          if (widget.controller.galleryPhotos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.controller.galleryPhotos.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => widget.controller.removeGalleryPhoto(index)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => widget.controller.addGalleryPhoto(GalleryPhoto())),
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text('UPLOAD NEW PHOTOS'),
            ),
          ),
        ],
      ),
    );
  }
}
