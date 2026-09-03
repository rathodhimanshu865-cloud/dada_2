import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import '../../utils/responsive_utils.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({super.key});

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> with TickerProviderStateMixin {
  int activeSectionIndex = 0;
  bool _isFiltering = false;

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    
    final controller = Provider.of<HomePageController>(context);
    final data = controller.photoGalleryData;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final bool isMobile = Responsive.isMobile(context);

    // Prepare Categories (Sections + All Photos as first option)
    List<PhotoGallerySection> categories = [
      PhotoGallerySection(
        heading: lang == 'hi' ? 'सभी तस्वीरें' : lang == 'gu' ? 'બધી તસવીરો' : 'All Photos',
        photoUrls: controller.realTimePhotos.map((p) => p['url'] as String? ?? '').where((u) => u.isNotEmpty).toList(),
      ),
      ...data.sections,
    ];

    List<String> currentPhotos = categories[activeSectionIndex].photoUrls;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          
          // Hero Title Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100),
            decoration: BoxDecoration(
              color: backgroundBeige.withOpacity(0.4),
              image: DecorationImage(
                image: const NetworkImage('https://www.transparenttextures.com/patterns/natural-paper.png'),
                opacity: 0.05,
              ),
            ),
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    data.localizedTitle(lang).isNotEmpty ? data.localizedTitle(lang) : 'Photo Gallery', 
                    style: AppTypography.headingStyle(
                      context, 
                      fontSize: AppTypography.getResponsiveSize(context, desktop: 56, tablet: 48, mobile: 38),
                      fontWeight: FontWeight.w900,
                      color: primaryTeal,
                      height: 1.1,
                    )
                  ),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    height: 1.5, width: 60, color: const Color(0xFFC19A6B),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    AppLocalizations.of(context)!.homeGalleryPhotos, 
                    style: TextStyle(
                      color: primaryTeal.withOpacity(0.6), 
                      fontSize: isMobile ? 14 : 16, 
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600
                    )
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Category Filter Tabs
          if (categories.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(categories.length, (index) {
                    final section = categories[index];
                    bool isActive = activeSectionIndex == index;
                    return GestureDetector(
                      onTap: () {
                        if (activeSectionIndex != index) {
                          setState(() {
                            _isFiltering = true;
                            activeSectionIndex = index;
                          });
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) setState(() => _isFiltering = false);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: Column(
                          children: [
                            Text(
                              section.localizedHeading(lang).toUpperCase(),
                              style: TextStyle(
                                color: isActive ? primaryTeal : Colors.grey,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                letterSpacing: 1.5,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height: 2,
                              width: isActive ? 30 : 0,
                              color: const Color(0xFFC19A6B),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

          const SizedBox(height: 40),

          // Photo Grid with Exit/Entrance Animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isFiltering 
              ? const SizedBox(height: 400, width: double.infinity)
              : _buildPhotoSection(context, currentPhotos),
          ),

          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, List<String> photoUrls) {
    final bool isMobile = Responsive.isMobile(context);
    if (photoUrls.isEmpty) {
      return FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100), 
          child: Text(AppLocalizations.of(context)!.noPhotosAdded, style: const TextStyle(color: Colors.grey, fontSize: 18))
        ),
      );
    }

    return Column(
      key: ValueKey('grid-${activeSectionIndex}'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40),
          child: LayoutBuilder(builder: (context, constraints) {
            int cols = Responsive.isDesktop(context) ? 4 : (Responsive.isTablet(context) ? 3 : 2);
            if (constraints.maxWidth < 500) cols = 1;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(cols * 2 - 1, (index) {
                if (index.isOdd) return SizedBox(width: isMobile ? 15 : 24);
                int colIdx = index ~/ 2;
                return Expanded(
                  child: Column(
                    children: photoUrls.asMap().entries
                        .where((e) => e.key % cols == colIdx)
                        .map<Widget>((e) {
                          int overallIndex = e.key;
                          return FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: Duration(milliseconds: (overallIndex % 8) * 100),
                            child: _buildPhotoCard(context, e.value, overallIndex, photoUrls, isMobile),
                          );
                        })
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
          BoxShadow(
            color: Colors.black.withOpacity(0.06), 
            blurRadius: 30, 
            offset: const Offset(0, 15)
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () => _showFullScreenGallery(context, index, allPhotos),
          child: Hero(
            tag: 'gallery-img-$index',
            child: AspectRatio(
              aspectRatio: index % 2 == 0 ? 0.85 : 1.1,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[100], 
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 50)
                ),
                fadeOutDuration: const Duration(milliseconds: 500),
                fadeInDuration: const Duration(milliseconds: 700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenGallery(BuildContext context, int initialIndex, List<String> allPhotos) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, _, __) => PremiumLightbox(
        initialIndex: initialIndex,
        allPhotos: allPhotos,
      ),
    ));
  }
}

class PremiumLightbox extends StatefulWidget {
  final int initialIndex;
  final List<String> allPhotos;

  const PremiumLightbox({
    super.key,
    required this.initialIndex,
    required this.allPhotos,
  });

  @override
  State<PremiumLightbox> createState() => _PremiumLightboxState();
}

class _PremiumLightboxState extends State<PremiumLightbox> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Swipeable Gallery with Parallax-like transition
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemCount: widget.allPhotos.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index);
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * MediaQuery.of(context).size.height,
                      width: Curves.easeOut.transform(value) * MediaQuery.of(context).size.width,
                      child: child,
                    ),
                  );
                },
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'gallery-img-$index',
                    child: CachedNetworkImage(
                      imageUrl: widget.allPhotos[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Controls
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 35),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Desktop Navigation Arrows
          if (MediaQuery.of(context).size.width > 900) ...[
            Positioned(
              left: 30,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 45),
                onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
              ),
            ),
            Positioned(
              right: 30,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 45),
                onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
              ),
            ),
          ],
          
          // Index Indicator
          Positioned(
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "${currentIndex + 1} / ${widget.allPhotos.length}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

