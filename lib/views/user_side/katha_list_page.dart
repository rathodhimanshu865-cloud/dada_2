import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import '../../utils/app_typography.dart';
import '../../utils/animation_utils.dart';
import '../../utils/site_interactions.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class KathaListPage extends StatefulWidget {
  const KathaListPage({super.key});

  @override
  State<KathaListPage> createState() => _KathaListPageState();
}

class _KathaListPageState extends State<KathaListPage> with TickerProviderStateMixin {
  int activeTab = 0;
  int? expandedIndex;
  int currentPage = 1;
  final int itemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isVisible = false;

  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color backgroundBeige = const Color(0xFFF9F3EA);
  final Color accentBrown = const Color(0xFFC19A6B);

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _searchController.dispose();
    super.dispose();
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
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    if (controller.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    List<KathaRecord> filteredKathas = controller.allKathas.where((katha) {
      final query = _searchQuery.toLowerCase();
      return katha.localizedTopic(lang).toLowerCase().contains(query) ||
             katha.localizedLocation(lang).toLowerCase().contains(query) ||
             katha.kathaNumber.toLowerCase().contains(query) ||
             katha.localizedYear(lang).contains(query);
    }).toList();

    filteredKathas.sort((a, b) {
      int idA = int.tryParse(a.kathaNumber) ?? 0;
      int idB = int.tryParse(b.kathaNumber) ?? 0;
      return idA.compareTo(idB);
    });

    final int totalItems = filteredKathas.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();
    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;

    final List<KathaRecord> pagedKathas = filteredKathas.isEmpty
        ? []
        : filteredKathas.sublist(
            startIndex, endIndex > totalItems ? totalItems : endIndex);

    final bool isReducedMotion = !AnimationUtils.shouldAnimate(context);

    return UserPageLayout(
      controller: controller,
      child: VisibilityDetector(
        key: const Key('katha-list-visibility'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.05 && !_isVisible) {
            if (mounted) setState(() => _isVisible = true);
          }
        },
        child: Column(
          children: [
            const SizedBox(height: 120),

            // ── Page hero banner with Ken Burns ─────────────────────────────
            Container(
              width: double.infinity,
              color: backgroundBeige,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                                  accentBrown.withOpacity(0.12),
                                  primaryTeal.withOpacity(0.04),
                                  backgroundBeige,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        children: [
                          FadeInDown(
                            duration: const Duration(milliseconds: 600),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: accentBrown.withOpacity(0.3)),
                                boxShadow: [BoxShadow(color: accentBrown.withOpacity(0.1), blurRadius: 10)],
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.fullKathaListTitle.toUpperCase(),
                                style: TextStyle(color: accentBrown, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              AppLocalizations.of(context)!.kathasList,
                              textAlign: TextAlign.center,
                              style: AppTypography.headingStyle(
                                context,
                                fontSize: isMobile ? 36 : 64,
                                fontWeight: FontWeight.w900,
                                color: primaryTeal,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 400),
                            child: Text(
                              '${AppLocalizations.of(context)!.home} > ${AppLocalizations.of(context)!.kathasList}',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyStyle(
                                context,
                                color: primaryTeal.withOpacity(0.6),
                                fontSize: isMobile ? 14 : 16,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 30 : 60),

            // ── Tab row ──────────────────────────────────────────────────────
            SiteFilterTabBar(
              tabs: [
                AppLocalizations.of(context)!.allKathas,
                AppLocalizations.of(context)!.upcomingKathas
              ],
              activeIndex: activeTab,
              onTabSelected: (index) {
                if (index == 0) {
                  setState(() {
                    activeTab = 0;
                    currentPage = 1;
                  });
                } else {
                  Navigator.pushNamed(context, '/upcoming_ram_kathas');
                }
              },
            ),

            SizedBox(height: isMobile ? 30 : 60),

            if (activeTab == 0)
              isMobile
                  ? _buildMobileView(pagedKathas, totalItems, totalPages, lang)
                  : _buildAllKathasView(pagedKathas, totalItems, totalPages, lang),

            const SizedBox(height: 80),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  // ── Shared tab button ────────────────────────────────────────────────────
  Widget _tabButton(String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.bodyStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive ? primaryTeal : Colors.black45,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isActive ? 60 : 0,
            color: primaryTeal,
          ),
        ],
      ),
    );
  }

  // ── DESKTOP: full multi-column table ────────────────────────────────────
  Widget _buildAllKathasView(
      List<KathaRecord> kathas, int totalItems, int totalPages, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          // Search bar
          FadeInDown(
            animate: _isVisible,
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 600),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 30),
                  Icon(Icons.search, size: 28, color: primaryTeal.withOpacity(0.5)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() { _searchQuery = v; currentPage = 1; }),
                      style: AppTypography.bodyStyle(context, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchKathaPlaceholder,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 25),
                      ),
                    ),
                  ),
                  SiteElevatedButton(
                    onPressed: () => setState(() { _searchQuery = _searchController.text; currentPage = 1; }),
                    enableHoverLift: false,
                    backgroundColor: primaryTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.searchKathas,
                      style: AppTypography.bodyStyle(
                        context,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
          // Results count
          FadeIn(
            animate: _isVisible,
            delay: const Duration(milliseconds: 800),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.kathasFound(totalItems).toUpperCase(),
                  style: AppTypography.bodyStyle(
                    context,
                    fontWeight: FontWeight.w900,
                    color: primaryTeal,
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Column headers
          FadeInUp(
            animate: _isVisible,
            delay: const Duration(milliseconds: 1000),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                color: primaryTeal.withOpacity(0.04),
                border: Border(
                  bottom: BorderSide(color: primaryTeal.withOpacity(0.15), width: 2),
                ),
              ),
              child: Row(
                children: [
                  _colHeader(AppLocalizations.of(context)!.id, flex: 1, center: true),
                  _colHeader(AppLocalizations.of(context)!.year, flex: 1),
                  _colHeader(AppLocalizations.of(context)!.dates, flex: 2),
                  _colHeader(AppLocalizations.of(context)!.topicHeading, flex: 4),
                  _colHeader(AppLocalizations.of(context)!.location, flex: 3),
                  _colHeader(AppLocalizations.of(context)!.country, flex: 2),
                  _colHeader(AppLocalizations.of(context)!.lang, flex: 1),
                  _colHeader(AppLocalizations.of(context)!.playlist, flex: 1, center: true),
                  _colHeader(AppLocalizations.of(context)!.action, flex: 1, center: true),
                ],
              ),
            ),
          ),
          // Rows
          ...kathas.asMap().entries.map((entry) {
            int index = entry.key;
            KathaRecord katha = entry.value;
            bool isExpanded = expandedIndex == index;
            return SiteCardEntrance(
              index: index,
              reducedMotion: false,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => expandedIndex = isExpanded ? null : index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isExpanded ? primaryTeal.withOpacity(0.02) : Colors.transparent,
                        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Center(child: _circleId(katha.kathaNumber))),
                          Expanded(flex: 1, child: Text(katha.localizedYear(lang), style: AppTypography.bodyStyle(context, fontSize: 16, fontWeight: FontWeight.w600))),
                          Expanded(flex: 2, child: Text(katha.localizedDates(lang), style: AppTypography.bodyStyle(context, fontSize: 15, color: accentBrown, fontWeight: FontWeight.w600))),
                          Expanded(flex: 4, child: Text(katha.localizedTopic(lang).toUpperCase(), style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5, color: const Color(0xFF333333)))),
                          Expanded(flex: 3, child: Row(children: [Icon(Icons.location_on, size: 18, color: primaryTeal.withOpacity(0.5)), const SizedBox(width: 8), Flexible(child: Text(katha.localizedLocation(lang), style: AppTypography.bodyStyle(context, fontSize: 16, color: Colors.black87)))])),
                          Expanded(flex: 2, child: Row(children: [Icon(Icons.public, size: 18, color: Colors.green.withOpacity(0.5)), const SizedBox(width: 8), Text(katha.country, style: AppTypography.bodyStyle(context, fontSize: 16))])),
                          Expanded(flex: 1, child: Text(katha.language.toUpperCase(), style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blueGrey))),
                          Expanded(flex: 1, child: Center(child: IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFFCD201F), size: 30), onPressed: () => _launchUrl(katha.youtubePlaylistUrl), tooltip: 'Watch Playlist'))),
                          Expanded(flex: 1, child: Center(child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right, size: 28, color: primaryTeal))),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded) _buildExpandedDetails(katha, lang),
                ],
              ),
            );
          }),
          const SizedBox(height: 80),
          if (totalItems > 0) _buildPagination(totalPages),
        ],
      ),
    );
  }

  // ── MOBILE: card-per-katha view ──────────────────────────────────────────
  Widget _buildMobileView(
      List<KathaRecord> kathas, int totalItems, int totalPages, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // Mobile search bar
          FadeInDown(
            animate: _isVisible,
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 600),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search, size: 24, color: primaryTeal.withOpacity(0.5)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() { _searchQuery = v; currentPage = 1; }),
                          style: AppTypography.bodyStyle(context, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.searchKathaPlaceholder,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: SiteElevatedButton(
                      onPressed: () => setState(() { _searchQuery = _searchController.text; currentPage = 1; }),
                      enableHoverLift: false,
                      backgroundColor: primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.searchKathas,
                        style: AppTypography.bodyStyle(
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Results count
          FadeIn(
            animate: _isVisible,
            delay: const Duration(milliseconds: 800),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.kathasFound(totalItems).toUpperCase(),
                style: AppTypography.bodyStyle(
                  context,
                  fontWeight: FontWeight.w900,
                  color: primaryTeal,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cards
          ...kathas.asMap().entries.map((entry) {
            int index = entry.key;
            KathaRecord katha = entry.value;
            bool isExpanded = expandedIndex == index;
            return SiteCardEntrance(
              index: index,
              reducedMotion: false,
              child: _buildMobileKathaCard(katha, index, isExpanded, lang),
            );
          }),

          const SizedBox(height: 40),
          if (totalItems > 0) _buildPagination(totalPages),
        ],
      ),
    );
  }

  Widget _buildMobileKathaCard(
      KathaRecord katha, int index, bool isExpanded, String lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? primaryTeal : Colors.grey[200]!,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => expandedIndex = isExpanded ? null : index),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: badge + number + toggle arrow
                  Row(
                    children: [
                      _circleId(katha.kathaNumber),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          katha.localizedTopic(lang).toUpperCase(),
                          style: AppTypography.bodyStyle(
                            context,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: const Color(0xFF333333),
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: primaryTeal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Meta row: dates + year
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: accentBrown),
                      const SizedBox(width: 6),
                      Text(
                        '${katha.localizedDates(lang)}  ·  ${katha.localizedYear(lang)}',
                        style: AppTypography.bodyStyle(
                          context,
                          fontSize: 13,
                          color: accentBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location + Country row
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: primaryTeal.withOpacity(0.5)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${katha.localizedLocation(lang)}, ${katha.country}',
                          style: AppTypography.bodyStyle(
                            context,
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          katha.language.toUpperCase(),
                          style: AppTypography.bodyStyle(
                            context,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Action: YouTube button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(katha.youtubePlaylistUrl),
                      icon: const Icon(Icons.play_circle_fill,
                          color: Color(0xFFCD201F), size: 20),
                      label: Text(
                        AppLocalizations.of(context)!.watchOnYoutube,
                        style: AppTypography.bodyStyle(
                          context,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryTeal,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryTeal,
                        side: BorderSide(color: primaryTeal.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded detail panel
          if (isExpanded) _buildMobileExpandedDetail(katha, lang),
        ],
      ),
    );
  }

  Widget _buildMobileExpandedDetail(KathaRecord katha, String lang) {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      from: 10,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        decoration: BoxDecoration(
          color: backgroundBeige.withOpacity(0.4),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(14)),
          border: Border(left: BorderSide(color: primaryTeal, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 12),
            // Thumbnail
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    katha.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_outlined),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                katha.localizedDescription(lang).isNotEmpty
                    ? katha.localizedDescription(lang)
                    : AppLocalizations.of(context)!.kathaDetailsFallback,
                style: AppTypography.bodyStyle(
                  context,
                  fontSize: 14,
                  height: 1.8,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(KathaRecord katha, String lang) {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      from: 20,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: backgroundBeige.withOpacity(0.3),
          border: Border(left: BorderSide(color: primaryTeal, width: 6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    child: Row(children: [
                      Text(katha.localizedLocation(lang).toUpperCase(), style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.w700, color: primaryTeal, letterSpacing: 1.5)),
                      const SizedBox(width: 25),
                      Container(width: 50, height: 2, color: accentBrown),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 100),
                    child: Text('${katha.localizedDates(lang)} | ${katha.localizedYear(lang)}', style: AppTypography.bodyStyle(context, color: accentBrown, fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      katha.localizedDescription(lang).isNotEmpty ? katha.localizedDescription(lang) : AppLocalizations.of(context)!.kathaDetailsFallback,
                      style: AppTypography.bodyStyle(context, fontSize: 18, height: 1.8, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 50),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(katha.youtubePlaylistUrl),
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: Text(AppLocalizations.of(context)!.watchOnYoutube),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryTeal,
                        side: BorderSide(color: primaryTeal, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              flex: 2,
              child: FadeInRight(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      katha.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: Colors.grey[200], child: const Icon(Icons.image_outlined)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _styledPageNavButton(
              AppLocalizations.of(context)!.previous,
              currentPage > 1 ? () => setState(() { currentPage--; expandedIndex = null; }) : null,
              icon: Icons.chevron_left,
              isNext: false,
            ),
            const SizedBox(width: 20),
            ...List.generate(totalPages, (index) {
              int pageNum = index + 1;
              bool isActive = pageNum == currentPage;

              if (totalPages > 7 && (pageNum > 3 && pageNum < totalPages - 2)) {
                if (pageNum == 4) return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('...', style: AppTypography.bodyStyle(context, color: primaryTeal, fontWeight: FontWeight.bold)),
                );
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ZoomIn(
                  delay: Duration(milliseconds: index * 30),
                  child: InkWell(
                    onTap: () => setState(() { currentPage = pageNum; expandedIndex = null; }),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isActive ? primaryTeal : Colors.white,
                        border: Border.all(color: isActive ? primaryTeal : Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "$pageNum",
                          style: AppTypography.bodyStyle(
                            context,
                            color: isActive ? Colors.white : primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 20),
            _styledPageNavButton(
              AppLocalizations.of(context)!.next,
              currentPage < totalPages ? () => setState(() { currentPage++; expandedIndex = null; }) : null,
              icon: Icons.chevron_right,
              isNext: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledPageNavButton(String label, VoidCallback? onTap, {required IconData icon, required bool isNext}) {
    bool isDisabled = onTap == null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNext) ...[
              Icon(icon, size: 18, color: isDisabled ? Colors.grey[300] : primaryTeal),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: AppTypography.bodyStyle(
                context,
                color: isDisabled ? Colors.grey[300] : primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            if (isNext) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: isDisabled ? Colors.grey[300] : primaryTeal),
            ],
          ],
        ),
      ),
    );
  }

  Widget _colHeader(String title, {required int flex, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: AppTypography.bodyStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primaryTeal.withOpacity(0.7),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _circleId(String id) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primaryTeal,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          id,
          style: AppTypography.bodyStyle(
            context,
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
