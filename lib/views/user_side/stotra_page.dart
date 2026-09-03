import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import '../../utils/animation_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StotraPage extends StatefulWidget {
  const StotraPage({super.key});

  @override
  State<StotraPage> createState() => _StotraPageState();
}

class _StotraPageState extends State<StotraPage> with TickerProviderStateMixin {
  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  // Bookmark / favorite IDs set
  final Set<String> _bookmarks = {};

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color goldAccent = const Color(0xFFC89A5B);
  final Color backgroundBeige = const Color(0xFFF9F3EA);

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarks.contains(id)) {
        _bookmarks.remove(id);
      } else {
        _bookmarks.add(id);
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final section = controller.stotraSection;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    final bool isReducedMotion = !AnimationUtils.shouldAnimate(context);

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),

          // 1. Devotional Banner with breathing glow animation
          _buildBanner(context, section, lang, isMobile, isReducedMotion),

          SizedBox(height: isMobile ? 30 : 60),

          const SizedBox(height: 40),
          _AnimatedTrishulDivider(primaryTeal: primaryTeal, goldAccent: goldAccent),
          const SizedBox(height: 40),

          // 2. Stotra / Bhajan / Aarti PDF List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
            child: _buildStotraList(context, section, lang, isMobile),
          ),

          const SizedBox(height: 80),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  // ── Banner with Ken-Burns breathing glow ─────────────────────────────────
  Widget _buildBanner(
      BuildContext context, dynamic section, String lang, bool isMobile, bool isReducedMotion) {
    return Container(
      width: double.infinity,
      color: backgroundBeige,
      child: Stack(
        children: [
          // Background Glow — scale breathing animation preserved
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _zoomAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isReducedMotion ? 1.0 : _zoomAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          goldAccent.withValues(alpha: 0.18),
                          primaryTeal.withValues(alpha: 0.05),
                          backgroundBeige,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Banner Content
          Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 50 : 90, horizontal: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 700),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: goldAccent.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: goldAccent.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_rounded, color: goldAccent, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "SACRED TEXTS & DEVOTIONAL PDFS",
                              style: TextStyle(
                                color: goldAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        section.localizedPageTitle(lang),
                        textAlign: TextAlign.center,
                        style: AppTypography.headingStyle(
                          context,
                          fontSize: AppTypography.getResponsiveSize(
                              context, desktop: 48, tablet: 38, mobile: 28),
                          fontWeight: FontWeight.bold,
                          color: primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        AppLocalizations.of(context)!.homeStotra,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyStyle(
                          context,
                          color: primaryTeal.withValues(alpha: 0.75),
                          fontSize: isMobile ? 14 : 17,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PDF Item List ─────────────────────────────────────────────────────────
  Widget _buildStotraList(
      BuildContext context, dynamic section, String lang, bool isMobile) {
    final items = section.items;

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final String itemId = 'stotra_$index';
        final String title = item.localizedTitle(lang);
        final bool isBookmarked = _bookmarks.contains(itemId);

        return SiteCardEntrance(
          index: index,
          reducedMotion: false,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.symmetric(
                vertical: isMobile ? 16 : 20, horizontal: isMobile ? 14 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Index number badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primaryTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: primaryTeal,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: AppTypography.bodyStyle(
                          context,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isMobile && (item.englishPdfUrl.isNotEmpty || item.hindiPdfUrl.isNotEmpty || item.gujaratiPdfUrl.isNotEmpty)) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: [
                            if (item.englishPdfUrl.isNotEmpty)
                              _pdfChip("EN", item.englishPdfUrl, primaryTeal),
                            if (item.hindiPdfUrl.isNotEmpty)
                              _pdfChip("हि", item.hindiPdfUrl, goldAccent),
                            if (item.gujaratiPdfUrl.isNotEmpty)
                              _pdfChip("ગુ", item.gujaratiPdfUrl, const Color(0xFF4A7C59)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // PDF Links (desktop)
                if (!isMobile) ...[
                  if (item.englishPdfUrl.isNotEmpty)
                    _pdfChip("EN", item.englishPdfUrl, primaryTeal),
                  if (item.hindiPdfUrl.isNotEmpty)
                    _pdfChip("हि", item.hindiPdfUrl, goldAccent),
                  if (item.gujaratiPdfUrl.isNotEmpty)
                    _pdfChip("ગુ", item.gujaratiPdfUrl, const Color(0xFF4A7C59)),
                ],

                const SizedBox(width: 12),

                // Bookmark icon (kept for UX — preserves the spring-bounce animation)
                _BookmarkButton(
                  isBookmarked: isBookmarked,
                  onTap: () => _toggleBookmark(itemId),
                  primaryTeal: primaryTeal,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _pdfChip(String label, String url, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_outlined, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ANIMATED TRISHUL DIVIDER (animation preserved)
// ---------------------------------------------------------------------------
class _AnimatedTrishulDivider extends StatefulWidget {
  final Color primaryTeal;
  final Color goldAccent;

  const _AnimatedTrishulDivider({required this.primaryTeal, required this.goldAccent});

  @override
  State<_AnimatedTrishulDivider> createState() => _AnimatedTrishulDividerState();
}

class _AnimatedTrishulDividerState extends State<_AnimatedTrishulDivider> with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('trishul-divider'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5 && !_isVisible) {
          if (mounted) setState(() => _isVisible = true);
        }
      },
      child: FadeIn(
        animate: _isVisible,
        duration: const Duration(milliseconds: 1000),
        child: Row(
          children: [
            Expanded(child: Container(height: 1, color: widget.goldAccent.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Icon(
                    Icons.menu_book_rounded,
                    color: widget.goldAccent.withOpacity(0.3 + (0.4 * _pulseController.value)),
                    size: 32,
                    shadows: [
                      Shadow(color: widget.goldAccent.withOpacity(0.5 * _pulseController.value), blurRadius: 15)
                    ],
                  );
                },
              ),
            ),
            Expanded(child: Container(height: 1, color: widget.goldAccent.withOpacity(0.2))),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BOOKMARK BUTTON WITH SPRING BOUNCE (replaces FavoriteHeartButton — keeps animation)
// ---------------------------------------------------------------------------
class _BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onTap;
  final Color primaryTeal;

  const _BookmarkButton({
    required this.isBookmarked,
    required this.onTap,
    required this.primaryTeal,
  });

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _scaleAnimation;
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _bounceController.forward(from: 0.0);
    setState(() => _showParticles = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _showParticles = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Particle burst animation — preserved
            if (_showParticles)
              ...List.generate(6, (i) {
                final double angle = (i * 60) * (pi / 180);
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 14.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, val, child) {
                    return Transform.translate(
                      offset: Offset(cos(angle) * val, sin(angle) * val),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: widget.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),

            // Bouncing bookmark icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: widget.isBookmarked ? widget.primaryTeal : Colors.grey.shade400,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
