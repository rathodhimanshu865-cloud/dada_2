import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import '../../utils/image_url_helper.dart';
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
      return idB.compareTo(idA); 
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
                Text('Kathas List', style: TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Home > Kathas List', style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tabButton('All Kathas', activeTab == 0, () => setState(() { activeTab = 0; currentPage = 1; })),
              const SizedBox(width: 80),
              _tabButton('Upcoming Kathas', activeTab == 1, () => Navigator.pushNamed(context, '/upcoming_ram_kathas')),
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
          Text(title.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? primaryTeal : Colors.black45, letterSpacing: 1.5)),
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
                    onSubmitted: (v) => setState(() { _searchQuery = v; currentPage = 1; }),
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(hintText: 'Enter Katha title, Year, or Location...', border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 25)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() { _searchQuery = _searchController.text; currentPage = 1; }),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)))),
                  child: const Text('SEARCH KATHAS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$totalItems KATHAS FOUND', style: TextStyle(fontWeight: FontWeight.bold, color: primaryTeal, fontSize: 16, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: BoxDecoration(color: primaryTeal.withOpacity(0.04), border: Border(bottom: BorderSide(color: primaryTeal.withOpacity(0.15), width: 2))),
            child: Row(
              children: [
                _colHeader('ID', flex: 1, center: true),
                _colHeader('YEAR', flex: 1),
                _colHeader('DATES', flex: 2),
                _colHeader('TOPIC / HEADING', flex: 4),
                _colHeader('LOCATION', flex: 3),
                _colHeader('COUNTRY', flex: 2),
                _colHeader('LANG', flex: 1),
                _colHeader('PLAYLIST', flex: 1, center: true),
                _colHeader('ACTION', flex: 1, center: true),
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
                        Expanded(flex: 1, child: Text(katha.year, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text(katha.dates, style: TextStyle(fontSize: 15, color: accentBrown, fontWeight: FontWeight.bold))),
                        Expanded(flex: 4, child: Text(katha.topic.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5))),
                        Expanded(flex: 3, child: Row(children: [Icon(Icons.location_on, size: 18, color: primaryTeal.withOpacity(0.5)), const SizedBox(width: 8), Flexible(child: Text(katha.location, style: const TextStyle(fontSize: 16, color: Colors.black87)))])),
                        Expanded(flex: 2, child: Row(children: [Icon(Icons.public, size: 18, color: Colors.green.withOpacity(0.5)), const SizedBox(width: 8), Text(katha.country, style: const TextStyle(fontSize: 16))])),
                        Expanded(flex: 1, child: Text(katha.language.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
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
                Row(children: [Text(katha.location.toUpperCase(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 1.5)), const SizedBox(width: 25), Container(width: 50, height: 2, color: accentBrown)]),
                const SizedBox(height: 10),
                Text('${katha.dates} | ${katha.year}', style: TextStyle(color: accentBrown, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                Text(katha.description.isNotEmpty ? katha.description : 'Details for this katha will be updated soon.', style: const TextStyle(fontSize: 18, height: 1.8, color: Colors.black87)),
                const SizedBox(height: 50),
                OutlinedButton.icon(onPressed: () => _launchUrl(katha.youtubePlaylistUrl), icon: const Icon(Icons.play_arrow, size: 24), label: const Text('WATCH ON YOUTUBE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(foregroundColor: primaryTeal, side: BorderSide(color: primaryTeal, width: 2), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25))),
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
            if (pageNum == 4) return Text('...'.tr());
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
      child: Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 44, height: 44, decoration: BoxDecoration(color: active ? primaryTeal : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: active ? primaryTeal : Colors.grey[200]!, width: 2)), child: Center(child: Text(num.toString(), style: TextStyle(color: active ? Colors.white : Colors.black87, fontSize: 16, fontWeight: active ? FontWeight.bold : FontWeight.w500)))),
    );
  }

  Widget _colHeader(String title, {required int flex, bool center = false}) {
    return Expanded(flex: flex, child: Text(title, textAlign: center ? TextAlign.center : TextAlign.start, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTeal.withOpacity(0.7), letterSpacing: 1.5)));
  }

  Widget _circleId(String id) {
    return Container(width: 40, height: 40, decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryTeal.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3))]), child: Center(child: Text(id, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))));
  }
}

