import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import '../../utils/image_url_helper.dart';
import '../../utils/app_typography.dart';
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
    
    if (controller.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    List<KathaRecord> filteredKathas = controller.allKathas.where((katha) {
      final query = _searchQuery.toLowerCase();
      return katha.topic.toLowerCase().contains(query) || 
             katha.location.toLowerCase().contains(query) ||
             katha.kathaNumber.toLowerCase().contains(query) ||
             katha.year.contains(query);
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
    
    final List<KathaRecord> pagedKathas = filteredKathas.isEmpty ? [] : filteredKathas.sublist(
      startIndex, 
      endIndex > totalItems ? totalItems : endIndex
    );

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 80),
            color: backgroundBeige.withOpacity(0.5),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.kathasList, 
                  style: AppTypography.headingStyle(
                    context, 
                    fontSize: AppTypography.getResponsiveSize(context, desktop: 52, tablet: 44, mobile: 34),
                    color: primaryTeal,
                  )
                ),
                const SizedBox(height: 12),
                Text(
                  '${AppLocalizations.of(context)!.home} > ${AppLocalizations.of(context)!.kathasList}', 
                  style: AppTypography.bodyStyle(
                    context,
                    color: primaryTeal.withOpacity(0.6), 
                    fontSize: 16, 
                    letterSpacing: 0.5
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tabButton(AppLocalizations.of(context)!.allKathas, activeTab == 0, () => setState(() { activeTab = 0; currentPage = 1; })),
              const SizedBox(width: 80),
              _tabButton(AppLocalizations.of(context)!.upcomingKathas, activeTab == 1, () => Navigator.pushNamed(context, '/upcoming_ram_kathas')),
            ],
          ),
          const SizedBox(height: 60),
          if (activeTab == 0) _buildAllKathasView(pagedKathas, totalItems, totalPages),
          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

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
              letterSpacing: 1.5
            )
          ),
          const SizedBox(height: 10),
          AnimatedContainer(duration: const Duration(milliseconds: 300), height: 4, width: isActive ? 60 : 0, color: primaryTeal),
        ],
      ),
    );
  }

  Widget _buildAllKathasView(List<KathaRecord> kathas, int totalItems, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 10))]),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 25)
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() { _searchQuery = _searchController.text; currentPage = 1; }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal, 
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30), 
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)))
                  ),
                  child: Text(AppLocalizations.of(context)!.searchKathas, style: AppTypography.bodyStyle(context, color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.kathasFound(totalItems), 
                style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w700, color: primaryTeal, fontSize: 16, letterSpacing: 2)
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: BoxDecoration(color: primaryTeal.withOpacity(0.04), border: Border(bottom: BorderSide(color: primaryTeal.withOpacity(0.15), width: 2))),
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
          ...kathas.asMap().entries.map((entry) {
            int index = entry.key;
            KathaRecord katha = entry.value;
            bool isExpanded = expandedIndex == index;
            return Column(
              children: [
                InkWell(
                  onTap: () => setState(() => expandedIndex = isExpanded ? null : index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                    decoration: BoxDecoration(color: isExpanded ? primaryTeal.withOpacity(0.02) : Colors.transparent, border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Center(child: _circleId(katha.kathaNumber))),
                        Expanded(flex: 1, child: Text(katha.year, style: AppTypography.bodyStyle(context, fontSize: 16, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text(katha.dates, style: AppTypography.bodyStyle(context, fontSize: 15, color: accentBrown, fontWeight: FontWeight.w600))),
                        Expanded(flex: 4, child: Text(katha.topic.toUpperCase(), style: AppTypography.headingStyle(context, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.5))),
                        Expanded(flex: 3, child: Row(children: [Icon(Icons.location_on, size: 18, color: primaryTeal.withOpacity(0.5)), const SizedBox(width: 8), Flexible(child: Text(katha.location, style: AppTypography.bodyStyle(context, fontSize: 16, color: Colors.black87)))])),
                        Expanded(flex: 2, child: Row(children: [Icon(Icons.public, size: 18, color: Colors.green.withOpacity(0.5)), const SizedBox(width: 8), Text(katha.country, style: AppTypography.bodyStyle(context, fontSize: 16))])),
                        Expanded(flex: 1, child: Text(katha.language.toUpperCase(), style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blueGrey))),
                        Expanded(flex: 1, child: Center(child: IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFFCD201F), size: 30), onPressed: () => _launchUrl(katha.youtubePlaylistUrl), tooltip: 'Watch Playlist'))),
                        Expanded(flex: 1, child: Center(child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right, size: 28, color: primaryTeal))),
                      ],
                    ),
                  ),
                ),
                if (isExpanded) _buildExpandedDetails(katha),
              ],
            );
          }),
          const SizedBox(height: 80),
          if (totalItems > 0) _buildPagination(totalPages),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(KathaRecord katha) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(color: backgroundBeige.withOpacity(0.3), border: Border(left: BorderSide(color: primaryTeal, width: 6))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text(katha.location.toUpperCase(), style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.w700, color: primaryTeal, letterSpacing: 1.5)), const SizedBox(width: 25), Container(width: 50, height: 2, color: accentBrown)]),
                const SizedBox(height: 10),
                Text('${katha.dates} | ${katha.year}', style: AppTypography.bodyStyle(context, color: accentBrown, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 40),
                Text(katha.description.isNotEmpty ? katha.description : AppLocalizations.of(context)!.kathaDetailsFallback, style: AppTypography.bodyStyle(context, fontSize: 18, height: 1.8, color: Colors.black87)),
                const SizedBox(height: 50),
                OutlinedButton.icon(
                  onPressed: () => _launchUrl(katha.youtubePlaylistUrl), 
                  icon: const Icon(Icons.play_arrow, size: 24), 
                  label: Text(AppLocalizations.of(context)!.watchOnYoutube),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryTeal, 
                    side: BorderSide(color: primaryTeal, width: 2), 
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25)
                  )
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
                aspectRatio: 16/9,
                child: Image.network(normalizeImageUrl(katha.imageUrl), fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image_outlined))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageNavButton(Icons.chevron_left, currentPage > 1, () => setState(() { currentPage--; expandedIndex = null; })),
        const SizedBox(width: 30),
        ...List.generate(totalPages, (index) {
          int pageNum = index + 1;
          if (totalPages > 7 && (pageNum > 3 && pageNum < totalPages - 2)) {
            if (pageNum == 4) return Text('...', style: AppTypography.bodyStyle(context));
            return const SizedBox.shrink();
          }
          return _pageNumberCircle(pageNum, currentPage == pageNum);
        }),
        const SizedBox(width: 30),
        _pageNavButton(Icons.chevron_right, currentPage < totalPages, () => setState(() { currentPage++; expandedIndex = null; })),
      ],
    );
  }

  Widget _pageNavButton(IconData icon, bool enabled, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, size: 32), color: enabled ? primaryTeal : Colors.grey[300], onPressed: enabled ? onTap : null);
  }

  Widget _pageNumberCircle(int num, bool active) {
    return InkWell(
      onTap: () => setState(() { currentPage = num; expandedIndex = null; }),
      child: Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 44, height: 44, decoration: BoxDecoration(color: active ? primaryTeal : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: active ? primaryTeal : Colors.grey[200]!, width: 2)), child: Center(child: Text(num.toString(), style: AppTypography.bodyStyle(context, color: active ? Colors.white : Colors.black87, fontSize: 16, fontWeight: active ? FontWeight.bold : FontWeight.w500)))),
    );
  }

  Widget _colHeader(String title, {required int flex, bool center = false}) {
    return Expanded(flex: flex, child: Text(title, textAlign: center ? TextAlign.center : TextAlign.start, style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.bold, color: primaryTeal.withOpacity(0.7), letterSpacing: 1.5)));
  }

  Widget _circleId(String id) {
    return Container(width: 40, height: 40, decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryTeal.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3))]), child: Center(child: Text(id, style: AppTypography.bodyStyle(context, color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))));
  }
}
