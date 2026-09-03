import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/animation_utils.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  int _activeCategory = 0; // 0 = All
  final List<String> _staticCategories = ['All'];

  static const Color primaryTeal = Color(0xFF0F4C5C);
  static const Color goldAccent = Color(0xFFC19A6B);
  static const Color bgBeige = Color(0xFFF9F3EA);

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  List<String> _buildCategories(List<NewsItem> news) {
    final cats = <String>{'All'};
    for (final item in news) {
      if (item.category.isNotEmpty) cats.add(item.category);
    }
    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final newsList = controller.homepageData.news;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final bool isMobile = Responsive.isMobile(context);

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final List<String> categories = _buildCategories(newsList);

    final List<NewsItem> filtered = _activeCategory == 0
      ? newsList
      : newsList.where((n) => n.category == categories[_activeCategory]).toList();

    // Deduplicate ticker headlines
    final List<String> tickerHeadlines = newsList
        .where((n) => n.localizedTitle(lang).isNotEmpty)
        .map((n) => n.localizedTitle(lang))
        .toList();

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),

          // ── Clean Title Banner (fade+rise, 400ms) ────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
            color: bgBeige.withOpacity(0.5),
            child: Column(
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    AppLocalizations.of(context)!.latestNews,
                    style: AppTypography.headingStyle(
                      context,
                      fontSize: AppTypography.getResponsiveSize(
                          context, desktop: 52, tablet: 44, mobile: 34),
                      fontWeight: FontWeight.bold,
                      color: primaryTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeInUp(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 400),
                  child: Container(height: 2, width: 50, color: goldAccent),
                ),
                const SizedBox(height: 14),
                FadeInUp(
                  delay: const Duration(milliseconds: 160),
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    AppLocalizations.of(context)!.homeNews,
                    style: AppTypography.bodyStyle(
                      context,
                      color: primaryTeal.withOpacity(0.6),
                      fontSize: isMobile ? 14 : 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Breaking News Ticker ─────────────────────────────────────────
          if (tickerHeadlines.isNotEmpty)
            _NewsTicker(headlines: tickerHeadlines, goldAccent: goldAccent, primaryTeal: primaryTeal),

          const SizedBox(height: 40),

          // ── Category Filter Tabs — Canonical SiteFilterTabBar ──────────
          if (categories.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SiteFilterTabBar(
                tabs: categories,
                activeIndex: _activeCategory,
                onTabSelected: (i) => setState(() => _activeCategory = i),
              ),
            ),

          SizedBox(height: isMobile ? 30 : 50),

          // ── News Cards Grid — Canonical SiteCardEntrance + SiteGridSwitcher
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40),
            child: SiteGridSwitcher(
              child: filtered.isEmpty
                ? Padding(
                    key: const ValueKey('empty'),
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Text(
                      "No news available.",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                    ),
                  )
                : Wrap(
                    key: ValueKey('news-${_activeCategory}'),
                    spacing: isMobile ? 15 : 30,
                    runSpacing: isMobile ? 30 : 50,
                    children: List.generate(filtered.length, (index) {
                      final item = filtered[index];
                      return SizedBox(
                        width: isMobile
                          ? double.infinity
                          : (Responsive.isDesktop(context) ? 360 : 300),
                        child: SiteCardEntrance(
                          index: index,
                          child: _NewsCard(
                            item: item,
                            lang: lang,
                            primaryTeal: primaryTeal,
                            goldAccent: goldAccent,
                            onReadMore: () => _launchUrl(item.url),
                          ),
                        ),
                      );
                    }),
                  ),
            ),
          ),

          SizedBox(height: isMobile ? 60 : 120),
          UserFooter(controller: controller),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BREAKING NEWS TICKER (continuous seamless loop, pauses on hover)
// ---------------------------------------------------------------------------
class _NewsTicker extends StatefulWidget {
  final List<String> headlines;
  final Color goldAccent;
  final Color primaryTeal;

  const _NewsTicker({required this.headlines, required this.goldAccent, required this.primaryTeal});

  @override
  State<_NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<_NewsTicker> with SingleTickerProviderStateMixin {
  late AnimationController _tickerCtrl;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _tickerCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.headlines.length * 8),
    )..repeat();
  }

  @override
  void dispose() {
    _tickerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String text = widget.headlines.join('  ·  ');
    final String doubledText = '$text  ·  $text'; // seamless loop

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isPaused = true);
        _tickerCtrl.stop();
      },
      onExit: (_) {
        setState(() => _isPaused = false);
        _tickerCtrl.repeat();
      },
      child: GestureDetector(
        onLongPressStart: (_) {
          setState(() => _isPaused = true);
          _tickerCtrl.stop();
        },
        onLongPressEnd: (_) {
          setState(() => _isPaused = false);
          _tickerCtrl.repeat();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: widget.primaryTeal,
          child: Row(
            children: [
              // "LIVE" Badge
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.goldAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "NEWS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              // Scrolling Text
              Expanded(
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _tickerCtrl,
                    builder: (context, child) {
                      // Translate from 0% to -50% (since we doubled the string)
                      return FractionalTranslation(
                        translation: Offset(-_tickerCtrl.value, 0),
                        child: child,
                      );
                    },
                    child: Text(
                      doubledText,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NEWS CARD (with image zoom, "read more" underline draw + arrow nudge)
// ---------------------------------------------------------------------------
class _NewsCard extends StatefulWidget {
  final NewsItem item;
  final String lang;
  final Color primaryTeal;
  final Color goldAccent;
  final VoidCallback onReadMore;

  const _NewsCard({
    required this.item,
    required this.lang,
    required this.primaryTeal,
    required this.goldAccent,
    required this.onReadMore,
  });

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> {
  bool _isHovered = false;
  bool _isReadMoreHovered = false;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = !Responsive.isMobile(context);
    final String title = widget.item.localizedTitle(widget.lang);
    final String category = widget.item.localizedCategory(widget.lang);
    final String date = widget.item.localizedDate(widget.lang);

    return VisibilityDetector(
      key: Key('news-card-${title.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          if (mounted) setState(() => _isVisible = true);
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with zoom on hover ──────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..scale(isDesktop && _isHovered ? 1.05 : 1.0),
                transformAlignment: Alignment.center,
                height: 220,
                width: double.infinity,
                child: widget.item.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.item.image,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC19A6B))),
                      ),
                      errorWidget: (c, u, e) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.newspaper_rounded, size: 50, color: Colors.grey),
                      ),
                      fadeInDuration: const Duration(milliseconds: 600),
                    )
                  : Container(
                      color: const Color(0xFFF3EEE6),
                      child: const Icon(Icons.newspaper_rounded, size: 50, color: Colors.grey),
                    ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Category badge (static, no animation) ───────────────────
            if (category.isNotEmpty)
              Text(
                category.toUpperCase(),
                style: TextStyle(
                  color: widget.goldAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

            const SizedBox(height: 10),

            // ── Headline ─────────────────────────────────────────────────
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headingStyle(
                context,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 10),

            // ── Date (static — informational element) ────────────────────
            Text(
              date,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 16),

            // ── "Read More" with underline draw + arrow nudge ─────────────
            if (widget.item.url.isNotEmpty)
              MouseRegion(
                onEnter: (_) => setState(() => _isReadMoreHovered = true),
                onExit: (_) => setState(() => _isReadMoreHovered = false),
                child: GestureDetector(
                  onTap: widget.onReadMore,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Read More",
                            style: TextStyle(
                              color: widget.primaryTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Underline draws left-to-right on hover
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            height: 1.5,
                            width: _isReadMoreHovered ? 70 : 0,
                            color: widget.primaryTeal,
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      // Arrow nudges right on hover
                      AnimatedSlide(
                        offset: _isReadMoreHovered ? const Offset(0.15, 0) : Offset.zero,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: widget.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
