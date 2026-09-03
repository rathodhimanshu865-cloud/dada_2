import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../utils/animation_utils.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({super.key});

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> with TickerProviderStateMixin {
  int activeSectionIndex = 0;
  bool _isFiltering = false;
  int _visibleCount = 12;
  bool _isLoadingMore = false;

  static const Color primaryTeal = Color(0xFF0F4C5C);
  static const Color goldAccent = Color(0xFFC19A6B);
  static const Color backgroundBeige = Color(0xFFF9F3EA);

  void _showFullScreenGallery(BuildContext context, int initialIndex, List<String> allPhotos) {
    Navigator.of(context).push(SiteLightboxRoute(
      builder: (_) => PremiumLightbox(
        initialIndex: initialIndex,
        allPhotos: allPhotos,
      ),
    ));
  }

  Future<void> _loadMore(int total) async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _visibleCount = (_visibleCount + 12).clamp(0, total);
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final data = controller.photoGalleryData;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final bool isMobile = Responsive.isMobile(context);

    List<PhotoGallerySection> categories = [
      PhotoGallerySection(
        heading: lang == 'hi' ? 'सभी तस्वीरें' : lang == 'gu' ? 'બધી તસવીરો' : 'All Photos',
        photoUrls: controller.realTimePhotos.map((p) => p['url'] as String? ?? '').where((u) => u.isNotEmpty).toList(),
      ),
      ...data.sections,
    ];

    List<String> currentPhotos = categories[activeSectionIndex].photoUrls.toList();
    
    final List<String> visiblePhotos = currentPhotos.take(_visibleCount).toList();
    final bool hasMore = visiblePhotos.length < currentPhotos.length;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),

          // ── Hero Banner ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100),
            decoration: BoxDecoration(
              color: backgroundBeige.withOpacity(0.4),
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
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(height: 1.5, width: 60, color: goldAccent),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    AppLocalizations.of(context)!.homeGalleryPhotos,
                    style: TextStyle(
                      color: primaryTeal.withOpacity(0.6),
                      fontSize: isMobile ? 14 : 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ── Category Filter Tabs — Canonical SiteFilterTabBar ────────────
          if (categories.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SiteFilterTabBar(
                tabs: categories.map((c) => c.localizedHeading(lang)).toList(),
                activeIndex: activeSectionIndex,
                onTabSelected: (index) {
                  if (activeSectionIndex != index) {
                    setState(() {
                      _isFiltering = true;
                      activeSectionIndex = index;
                      _visibleCount = 12;
                    });
                    Future.delayed(const Duration(milliseconds: 350), () {
                      if (mounted) setState(() => _isFiltering = false);
                    });
                  }
                },
              ),
            ),

          const SizedBox(height: 40),

          // ── Album Covers (if sections have cover images) ─────────────────
          if (!_isFiltering && data.sections.isNotEmpty && activeSectionIndex == 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ALBUMS",
                    style: TextStyle(
                      color: primaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                  Container(margin: const EdgeInsets.only(top: 10, bottom: 24), width: 30, height: 2, color: goldAccent),
                  Wrap(
                    spacing: isMobile ? 12 : 24,
                    runSpacing: isMobile ? 12 : 24,
                    children: data.sections.asMap().entries.map((entry) {
                      final int i = entry.key;
                      final section = entry.value;
                      if (section.photoUrls.isEmpty) return const SizedBox.shrink();
                      return SizedBox(
                        width: isMobile ? 150 : 200,
                        child: _AlbumCoverCard(
                          section: section,
                          lang: lang,
                          onTap: () => setState(() {
                            activeSectionIndex = i + 1;
                            _visibleCount = 12;
                          }),
                          goldAccent: goldAccent,
                          primaryTeal: primaryTeal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),

          // ── Photo Grid — Canonical SiteGridSwitcher ──────────────────────
          SiteGridSwitcher(
            child: _isFiltering
              ? const SizedBox(key: ValueKey('loading'), height: 200, child: Center(child: _PulsingLoadingIndicator()))
              : _buildMasonryGrid(context, visiblePhotos, currentPhotos, isMobile),
          ),

          // ── Load More ────────────────────────────────────────────────────
          if (!_isFiltering && hasMore) ...[
            const SizedBox(height: 40),
            _isLoadingMore
              ? const _PulsingLoadingIndicator()
              : GestureDetector(
                  onTap: () => _loadMore(currentPhotos.length),
                  child: FadeInUp(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: goldAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_outlined, color: goldAccent, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            "LOAD MORE",
                            style: TextStyle(
                              color: primaryTeal,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],

          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildMasonryGrid(
      BuildContext context, List<String> visiblePhotos, List<String> allPhotos, bool isMobile) {
    if (visiblePhotos.isEmpty) {
      return FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Text(
            AppLocalizations.of(context)!.noPhotosAdded,
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      );
    }

    return Padding(
      key: ValueKey('grid-$activeSectionIndex'),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40),
      child: LayoutBuilder(builder: (context, constraints) {
        int cols = Responsive.isDesktop(context) ? 4 : (Responsive.isTablet(context) ? 3 : 2);
        if (constraints.maxWidth < 500) cols = 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(cols * 2 - 1, (colIndexRaw) {
            if (colIndexRaw.isOdd) return SizedBox(width: isMobile ? 12 : 20);
            final int colIdx = colIndexRaw ~/ 2;
            return Expanded(
              child: Column(
                children: visiblePhotos.asMap().entries
                    .where((e) => e.key % cols == colIdx)
                    .map<Widget>((e) {
                  final int overallIndex = e.key;
                  return SiteCardEntrance(
                    index: overallIndex,
                    child: _PhotoCard(
                      url: e.value,
                      index: overallIndex,
                      allPhotos: allPhotos,
                      isMobile: isMobile,
                      onTap: () => _showFullScreenGallery(context, overallIndex, allPhotos),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// ALBUM COVER CARD WITH HOVER STACK EFFECT
// ---------------------------------------------------------------------------
class _AlbumCoverCard extends StatefulWidget {
  final PhotoGallerySection section;
  final String lang;
  final VoidCallback onTap;
  final Color goldAccent;
  final Color primaryTeal;

  const _AlbumCoverCard({
    required this.section,
    required this.lang,
    required this.onTap,
    required this.goldAccent,
    required this.primaryTeal,
  });

  @override
  State<_AlbumCoverCard> createState() => _AlbumCoverCardState();
}

class _AlbumCoverCardState extends State<_AlbumCoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String coverUrl = widget.section.photoUrls.isNotEmpty ? widget.section.photoUrls.first : '';
    final String secondUrl = widget.section.photoUrls.length > 1 ? widget.section.photoUrls[1] : coverUrl;
    final String thirdUrl = widget.section.photoUrls.length > 2 ? widget.section.photoUrls[2] : coverUrl;
    final int count = widget.section.photoUrls.length;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 3rd card (back, reveals most on hover)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    top: _isHovered ? -10 : 0,
                    right: _isHovered ? -12 : 0,
                    child: AnimatedRotation(
                      turns: _isHovered ? 0.035 : 0,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      child: _stackCard(thirdUrl, 0.85),
                    ),
                  ),
                  // 2nd card (middle)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    top: _isHovered ? -5 : 0,
                    right: _isHovered ? -6 : 0,
                    child: AnimatedRotation(
                      turns: _isHovered ? 0.018 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: _stackCard(secondUrl, 0.92),
                    ),
                  ),
                  // Front cover (main)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.identity()
                      ..translate(0.0, _isHovered ? -4.0 : 0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.08),
                          blurRadius: _isHovered ? 20 : 10,
                          offset: Offset(0, _isHovered ? 10 : 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: coverUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: coverUrl,
                            width: double.infinity,
                            height: 155,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => Container(height: 155, color: Colors.grey.shade200),
                            errorWidget: (c, u, e) => Container(
                              height: 155,
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.photo_album_outlined, size: 48, color: Colors.grey),
                            ),
                          )
                        : Container(height: 155, color: Colors.grey.shade200, child: const Icon(Icons.photo_album_outlined, size: 48, color: Colors.grey)),
                    ),
                  ),
                  // Count badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$count",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.section.localizedHeading(widget.lang),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: widget.primaryTeal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "$count photos",
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stackCard(String url, double opacity) {
    return Opacity(
      opacity: opacity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: url,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
          placeholder: (c, u) => Container(height: 150, color: Colors.grey.shade300),
          errorWidget: (c, u, e) => Container(height: 150, color: Colors.grey.shade200),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PHOTO CARD (with blur-up lazy load & hover)
// ---------------------------------------------------------------------------
class _PhotoCard extends StatefulWidget {
  final String url;
  final int index;
  final List<String> allPhotos;
  final bool isMobile;
  final VoidCallback onTap;

  const _PhotoCard({
    required this.url,
    required this.index,
    required this.allPhotos,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: widget.isMobile ? 12 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.06),
                blurRadius: _isHovered ? 30 : 15,
                offset: Offset(0, _isHovered ? 12 : 6),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedScale(
              scale: _isHovered ? 1.04 : 1.0,
              duration: const Duration(milliseconds: 400),
              alignment: Alignment.center,
              child: Hero(
                tag: 'gallery-img-${widget.index}',
                child: AspectRatio(
                  aspectRatio: widget.index % 3 == 0 ? 0.85 : (widget.index % 3 == 1 ? 1.1 : 0.95),
                  child: CachedNetworkImage(
                    imageUrl: widget.url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC19A6B))),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
                    ),
                    fadeInDuration: const Duration(milliseconds: 600),
                    fadeOutDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PULSING LOADING INDICATOR
// ---------------------------------------------------------------------------
class _PulsingLoadingIndicator extends StatefulWidget {
  const _PulsingLoadingIndicator();

  @override
  State<_PulsingLoadingIndicator> createState() => _PulsingLoadingIndicatorState();
}

class _PulsingLoadingIndicatorState extends State<_PulsingLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 8 + (_ctrl.value * 4),
            height: 8 + (_ctrl.value * 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC19A6B).withOpacity(0.4 + (_ctrl.value * 0.5)),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PREMIUM LIGHTBOX with keyboard nav, parallax swipe, & staggered controls
// ---------------------------------------------------------------------------
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
  bool _controlsVisible = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    // Stagger controls: image first, controls after 200ms
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _controlsVisible = true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (currentIndex < widget.allPhotos.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _goPrev() {
    if (currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) _goNext();
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _goPrev();
          if (event.logicalKey == LogicalKeyboardKey.escape) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // ── Swipeable PageView with Parallax ─────────────────────────
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => currentIndex = i),
              itemCount: widget.allPhotos.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double parallax = 0.0;
                    if (_pageController.position.haveDimensions) {
                      parallax = (_pageController.page! - index);
                    }
                    // outgoing image scales down ~5%, incoming slides in
                    final double scale = (1.0 - parallax.abs() * 0.05).clamp(0.95, 1.0);
                    final double opacity = (1.0 - parallax.abs() * 0.5).clamp(0.0, 1.0);

                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(parallax * 30, 0),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Hero(
                        tag: 'gallery-img-$index',
                        child: CachedNetworkImage(
                          imageUrl: widget.allPhotos[index],
                          fit: BoxFit.contain,
                          placeholder: (c, u) => const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)),
                          errorWidget: (c, u, e) => const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 60),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Staggered Controls (appear 250ms after image) ─────────────
            AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: [
                  // Close Button
                  Positioned(
                    top: 40,
                    right: 20,
                    child: _LightboxIconButton(
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Download + Share (stagger slightly more than close)
                  AnimatedSlide(
                    offset: _controlsVisible ? Offset.zero : const Offset(0, -0.2),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: Positioned(
                      top: 40,
                      right: 80,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LightboxIconButton(
                            icon: Icons.download_rounded,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          _LightboxIconButton(
                            icon: Icons.share_rounded,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Desktop Arrow Navigation
                  if (isDesktop) ...[
                    Positioned(
                      left: 20,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _LightboxArrowButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onPressed: _goPrev,
                          enabled: currentIndex > 0,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _LightboxArrowButton(
                          icon: Icons.arrow_forward_ios_rounded,
                          onPressed: _goNext,
                          enabled: currentIndex < widget.allPhotos.length - 1,
                        ),
                      ),
                    ),
                  ],

                  // Index Counter
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "${currentIndex + 1} / ${widget.allPhotos.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dot Row Indicator
                  Positioned(
                    bottom: 90,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            widget.allPhotos.length > 20 ? 20 : widget.allPhotos.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == currentIndex ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == currentIndex
                                  ? const Color(0xFFC19A6B)
                                  : Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightboxIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _LightboxIconButton({required this.icon, required this.onPressed});

  @override
  State<_LightboxIconButton> createState() => _LightboxIconButtonState();
}

class _LightboxIconButtonState extends State<_LightboxIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _LightboxArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  const _LightboxArrowButton({required this.icon, required this.onPressed, required this.enabled});

  @override
  State<_LightboxArrowButton> createState() => _LightboxArrowButtonState();
}

class _LightboxArrowButtonState extends State<_LightboxArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.2,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(_isHovered ? 0.5 : 0.1)),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
