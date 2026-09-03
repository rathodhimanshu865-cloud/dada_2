import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import '../../utils/app_typography.dart';
import '../../utils/animation_utils.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class KathaListPage extends StatefulWidget {
  const KathaListPage({super.key});

  @override
  State<KathaListPage> createState() => _KathaListPageState();
}

class _KathaListPageState extends State<KathaListPage> {
  int activeTab = 0;
  int? expandedIndex;
  int currentPage = 1;
  final int itemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color backgroundBeige = const Color(0xFFF9F3EA);
  final Color accentBrown = const Color(0xFFC19A6B);

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

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),

          // ── Page hero banner ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
            color: backgroundBeige.withValues(alpha: 0.5),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.kathasList,
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: AppTypography.getResponsiveSize(
                        context, desktop: 52, tablet: 44, mobile: 34),
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${AppLocalizations.of(context)!.home} > ${AppLocalizations.of(context)!.kathasList}',
                  style: AppTypography.bodyStyle(
                    context,
                    color: primaryTeal.withValues(alpha: 0.6),
                    fontSize: isMobile ? 14 : 16,
                    letterSpacing: 0.5,
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
          Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 30),
                Icon(Icons.search, size: 28, color: primaryTeal.withValues(alpha: 0.5)),
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
          const SizedBox(height: 80),
          // Results count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.kathasFound(totalItems),
                style: AppTypography.bodyStyle(
                  context,
                  fontWeight: FontWeight.w700,
                  color: primaryTeal,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: BoxDecoration(
              color: primaryTeal.withValues(alpha: 0.04),
              border: Border(
                bottom: BorderSide(color: primaryTeal.withValues(alpha: 0.15), width: 2),
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
                      color: isExpanded ? primaryTeal.withValues(alpha: 0.02) : Colors.transparent,
                      border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Center(child: _circleId(katha.kathaNumber))),
                        Expanded(flex: 1, child: Text(katha.localizedYear(lang), style: AppTypography.bodyStyle(context, fontSize: 16, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text(katha.localizedDates(lang), style: AppTypography.bodyStyle(context, fontSize: 15, color: accentBrown, fontWeight: FontWeight.w600))),
                        Expanded(flex: 4, child: Text(katha.localizedTopic(lang).toUpperCase(), style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5, color: const Color(0xFF333333)))),
                        Expanded(flex: 3, child: Row(children: [Icon(Icons.location_on, size: 18, color: primaryTeal.withValues(alpha: 0.5)), const SizedBox(width: 8), Flexible(child: Text(katha.localizedLocation(lang), style: AppTypography.bodyStyle(context, fontSize: 16, color: Colors.black87)))])),
                        Expanded(flex: 2, child: Row(children: [Icon(Icons.public, size: 18, color: Colors.green.withValues(alpha: 0.5)), const SizedBox(width: 8), Text(katha.country, style: AppTypography.bodyStyle(context, fontSize: 16))])),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
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
                    Icon(Icons.search, size: 24, color: primaryTeal.withValues(alpha: 0.5)),
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

          const SizedBox(height: 24),

          // Results count
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.kathasFound(totalItems),
              style: AppTypography.bodyStyle(
                context,
                fontWeight: FontWeight.w700,
                color: primaryTeal,
                fontSize: 13,
                letterSpacing: 1.5,
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
            color: Colors.black.withValues(alpha: 0.04),
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
                      Icon(Icons.location_on_outlined, size: 14, color: primaryTeal.withValues(alpha: 0.5)),
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
                          color: Colors.blueGrey.withValues(alpha: 0.08),
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
                        side: BorderSide(color: primaryTeal.withValues(alpha: 0.2)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      decoration: BoxDecoration(
        color: backgroundBeige.withValues(alpha: 0.4),
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
          ClipRRect(
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
          const SizedBox(height: 16),
          Text(
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
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(KathaRecord katha, String lang) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: backgroundBeige.withValues(alpha: 0.3),
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
                Row(children: [
                  Text(katha.localizedLocation(lang).toUpperCase(), style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.w700, color: primaryTeal, letterSpacing: 1.5)),
                  const SizedBox(width: 25),
                  Container(width: 50, height: 2, color: accentBrown),
                ]),
                const SizedBox(height: 10),
                Text('${katha.localizedDates(lang)} | ${katha.localizedYear(lang)}', style: AppTypography.bodyStyle(context, color: accentBrown, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 40),
                Text(
                  katha.localizedDescription(lang).isNotEmpty ? katha.localizedDescription(lang) : AppLocalizations.of(context)!.kathaDetailsFallback,
                  style: AppTypography.bodyStyle(context, fontSize: 18, height: 1.8, color: Colors.black87),
                ),
                const SizedBox(height: 50),
                OutlinedButton.icon(
                  onPressed: () => _launchUrl(katha.youtubePlaylistUrl),
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: Text(AppLocalizations.of(context)!.watchOnYoutube),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryTeal,
                    side: BorderSide(color: primaryTeal, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            flex: 2,
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
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _styledPageNavButton(
            AppLocalizations.of(context)!.previous,
            currentPage > 1 ? () => setState(() { currentPage--; expandedIndex = null; }) : null,
            icon: Icons.chevron_left,
            isNext: false,
          ),
          const SizedBox(width: 20),

          // Page Numbers
          ...List.generate(totalPages, (index) {
            int pageNum = index + 1;
            bool isActive = pageNum == currentPage;

            // Simple logic for showing page numbers (can be enhanced if totalPages is very large)
            if (totalPages > 7 && (pageNum > 3 && pageNum < totalPages - 2)) {
              if (pageNum == 4) return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('...', style: AppTypography.bodyStyle(context, color: primaryTeal, fontWeight: FontWeight.bold)),
              );
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
            );
          }),

          const SizedBox(width: 20),

          // Next Button
          _styledPageNavButton(
            AppLocalizations.of(context)!.next,
            currentPage < totalPages ? () => setState(() { currentPage++; expandedIndex = null; }) : null,
            icon: Icons.chevron_right,
            isNext: true,
          ),
        ],
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
          color: primaryTeal.withValues(alpha: 0.7),
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
            color: primaryTeal.withValues(alpha: 0.2),
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
