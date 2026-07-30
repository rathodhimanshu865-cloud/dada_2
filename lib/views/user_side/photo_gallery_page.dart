import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({super.key});

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  int activeSectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);
    
    final controller = Provider.of<HomePageController>(context);
    final data = controller.photoGalleryData;
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
          
          // Hero Title Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
            color: backgroundBeige.withOpacity(0.5),
            child: Column(
              children: [
                Text(
                  data.localizedTitle(lang).isNotEmpty ? data.localizedTitle(lang) : 'Photo Gallery', 
                  style: AppTypography.headingStyle(
                    context, 
                    fontSize: AppTypography.getResponsiveSize(context, desktop: 52, tablet: 44, mobile: 34),
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  )
                ),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.homeGalleryPhotos, style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: isMobile ? 14 : 16, letterSpacing: 0.5)),
              ],
            ),
          ),

          const SizedBox(height: 40),

          _buildPhotoSection(context, controller.realTimePhotos.map((p) => p['url'] as String? ?? '').where((u) => u.isNotEmpty).toList()),

          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, List<String> photoUrls) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    if (photoUrls.isEmpty) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 100), child: Text(AppLocalizations.of(context)!.noPhotosAdded, style: const TextStyle(color: Colors.grey, fontSize: 18)));
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
          child: LayoutBuilder(builder: (context, constraints) {
            int cols = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1));
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(cols * 2 - 1, (index) {
                if (index.isOdd) return SizedBox(width: isMobile ? 15 : 30);
                int colIdx = index ~/ 2;
                return Expanded(
                  child: Column(
                    children: photoUrls.asMap().entries
                        .where((e) => e.key % cols == colIdx)
                        .map<Widget>((e) => _buildPhotoCard(context, e.value, photoUrls.indexOf(e.value), photoUrls, isMobile))
                        .toList(),
                  ),
                );
              }),
            );
          }),
        ),
        SizedBox(height: isMobile ? 50 : 120),
      ],
    );
  }

  Widget _buildPhotoCard(BuildContext context, String url, int index, List<String> allPhotos, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 15 : 30),
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
          onTap: () => _showFullScreenGallery(context, index, allPhotos),
          child: AspectRatio(
            aspectRatio: 0.85,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[100], child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 50)),
            ),
          ),
        ),
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
                          color: Colors.black.withOpacity(0.5),
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
                          color: Colors.black.withOpacity(0.5),
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
                        color: Colors.black.withOpacity(0.5),
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
}
