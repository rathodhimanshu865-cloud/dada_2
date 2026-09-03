import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../controllers/homepage_controller.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../utils/app_typography.dart';

class UserPhotoGallery extends StatefulWidget {
  final HomePageController controller;
  const UserPhotoGallery({super.key, required this.controller});

  @override
  State<UserPhotoGallery> createState() => _UserPhotoGalleryState();
}

class _UserPhotoGalleryState extends State<UserPhotoGallery> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final List<String> allPhotos = widget.controller.realTimePhotos
        .map((p) => p['url'] as String? ?? '')
        .where((u) => u.isNotEmpty)
        .toList();
    if (allPhotos.isEmpty) return const SizedBox.shrink();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    final displayPhotos = allPhotos.take(isMobile ? 6 : 8).toList();

    return VisibilityDetector(
      key: const Key('user-photo-gallery'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() => _isVisible = true);
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
            // Header
            Column(
              children: [
                FadeInDown(
                  animate: _isVisible,
                  child: Text(
                    AppLocalizations.of(context)!.sacredMoments,
                    style: AppTypography.bodyStyle(
                      context,
                      color: const Color(0xFFC89A5B),
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    AppLocalizations.of(context)!.divineGallery,
                    textAlign: TextAlign.center,
                    style: AppTypography.headingStyle(
                      context,
                      fontSize: isMobile ? 32 : 52,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F4C5C),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeIn(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 400),
                  child: Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 50 : 80),

            // Masonry-style Grid
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
                      return SizedBox(width: isMobile ? 12 : 24);
                    }
                    int colIdx = index ~/ 2;
                    return Expanded(
                      child: Column(
                        children: displayPhotos
                            .asMap()
                            .entries
                            .where((e) => e.key % cols == colIdx)
                            .map<Widget>((e) {
                              int overallIndex = e.key;
                              return FadeInUp(
                                animate: _isVisible,
                                delay: Duration(milliseconds: 100 * overallIndex),
                                child: _GalleryItem(
                                  url: e.value,
                                  index: overallIndex,
                                  allPhotos: allPhotos,
                                  onTap: () => _showFullScreenGallery(context, overallIndex, allPhotos),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    );
                  }),
                );
              }),
            ),

            SizedBox(height: isMobile ? 50 : 80),

            FadeInUp(
              animate: _isVisible,
              delay: const Duration(milliseconds: 800),
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenGallery(BuildContext context, int initialIndex, List<String> allPhotos) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.9),
      pageBuilder: (context, _, __) => FullScreenGallery(
        initialIndex: initialIndex,
        allPhotos: allPhotos,
      ),
    ));
  }
}

class _GalleryItem extends StatefulWidget {
  final String url;
  final int index;
  final List<String> allPhotos;
  final VoidCallback onTap;

  const _GalleryItem({
    required this.url,
    required this.index,
    required this.allPhotos,
    required this.onTap,
  });

  @override
  State<_GalleryItem> createState() => _GalleryItemState();
}

class _GalleryItemState extends State<_GalleryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.05),
                blurRadius: _isHovered ? 30 : 20,
                offset: Offset(0, _isHovered ? 15 : 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Hero(
                  tag: 'gallery-photo-${widget.index}',
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 600),
                    scale: _isHovered ? 1.05 : 1.0,
                    child: AspectRatio(
                      aspectRatio: widget.index % 2 == 0 ? 0.8 : 1.2,
                      child: Image.network(
                        widget.url,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_outlined, color: Colors.grey, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Gold Glow Border on Hover
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _isHovered ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFC89A5B).withOpacity(0.5), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                // Caption Slide Up
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 400),
                    offset: _isHovered ? Offset.zero : const Offset(0, 1),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        ),
                      ),
                      child: const Text(
                        "View Moment",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final int initialIndex;
  final List<String> allPhotos;

  const FullScreenGallery({
    super.key,
    required this.initialIndex,
    required this.allPhotos,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < 0) {
                  setState(() {
                    currentIndex = (currentIndex + 1) % widget.allPhotos.length;
                  });
                } else if (details.primaryVelocity! > 0) {
                  setState(() {
                    currentIndex = (currentIndex - 1 + widget.allPhotos.length) % widget.allPhotos.length;
                  });
                }
              }
            },
            child: InteractiveViewer(
              child: Center(
                child: Hero(
                  tag: 'gallery-photo-$currentIndex',
                  child: Image.network(
                    widget.allPhotos[currentIndex],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Navigation Arrows (Desktop)
          if (MediaQuery.of(context).size.width > 900) ...[
            Positioned(
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 40),
                onPressed: () {
                  setState(() {
                    currentIndex = (currentIndex - 1 + widget.allPhotos.length) % widget.allPhotos.length;
                  });
                },
              ),
            ),
            Positioned(
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40),
                onPressed: () {
                  setState(() {
                    currentIndex = (currentIndex + 1) % widget.allPhotos.length;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

