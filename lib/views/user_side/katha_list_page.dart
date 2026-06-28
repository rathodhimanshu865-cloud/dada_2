import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class KathaListPage extends StatefulWidget {
  const KathaListPage({super.key});

  @override
  State<KathaListPage> createState() => _KathaListPageState();
}

class _KathaListPageState extends State<KathaListPage> {
  int activeTab = 0; // 0 for All Kathas, 1 for Upcoming Kathas
  int? expandedIndex;
  
  // Pagination State
  int currentPage = 1;
  final int itemsPerPage = 10;

  // Search State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }

    // 1. Filtering Logic based on Search Query
    List<KathaRecord> filteredKathas = controller.allKathas.where((katha) {
      final query = _searchQuery.toLowerCase();
      return katha.topic.toLowerCase().contains(query) || 
             katha.location.toLowerCase().contains(query) ||
             katha.kathaNumber.toLowerCase().contains(query) ||
             katha.year.contains(query);
    }).toList();

    // 2. Systematic Sorting: Arrange by Katha Number (Descending - latest first)
    filteredKathas.sort((a, b) {
      int idA = int.tryParse(a.kathaNumber) ?? 0;
      int idB = int.tryParse(b.kathaNumber) ?? 0;
      return idB.compareTo(idA); 
    });

    // 3. Pagination Logic
    final int totalItems = filteredKathas.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();
    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;
    
    final List<KathaRecord> pagedKathas = filteredKathas.isEmpty ? [] : filteredKathas.sublist(
      startIndex, 
      endIndex > totalItems ? totalItems : endIndex
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            
            // Full-size rectangle banner image above the title
            if (controller.kathaListPageData.bannerImageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.network(
                  controller.kathaListPageData.bannerImageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
              ),
            
            const SizedBox(height: 40),
            const Text(
              'Kathas List',
              style: TextStyle(fontSize: 36, fontFamily: 'serif', color: Color(0xFF444444)),
            ),
            const Text('Home > Kathas List', style: TextStyle(color: Colors.grey, fontSize: 12)),
            
            const SizedBox(height: 60),
            
            // Tab Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabButton('All Kathas', true, () => setState(() {
                  currentPage = 1;
                  expandedIndex = null;
                })),
                const SizedBox(width: 80),
                _tabLink('Upcoming Kathas', () => Navigator.pushNamed(context, '/upcoming_ram_kathas')),
              ],
            ),
            
            const SizedBox(height: 40),
            
            _buildAllKathasView(pagedKathas, totalItems, totalPages),

            const SizedBox(height: 80),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.brown[300] : Colors.black87,
            ),
          ),
          if (isActive)
            Container(height: 2, width: 40, color: Colors.brown[300], margin: const EdgeInsets.only(top: 4)),
        ],
      ),
    );
  }

  Widget _tabLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          Container(height: 2, width: 40, color: Colors.transparent, margin: const EdgeInsets.only(top: 4)),
        ],
      ),
    );
  }

  Widget _buildAllKathasView(List<KathaRecord> kathas, int totalItems, int totalPages) {
    return Column(
      children: [
        // Search & Filter Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) => setState(() {
                    _searchQuery = value;
                    currentPage = 1;
                  }),
                  decoration: InputDecoration(
                    hintText: 'Enter Katha title or Keywords here',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _filterDropdown('Year'),
              const SizedBox(width: 10),
              _filterDropdown('City'),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => setState(() {
                  _searchQuery = _searchController.text;
                  currentPage = 1;
                  expandedIndex = null;
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF444444), 
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Search Kathas', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        Text('$totalItems Kathas Found', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
        const SizedBox(height: 30),
        
        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
            child: Row(
              children: [
                _colHeader('KATHA #', flex: 1),
                _colHeader('YEAR', flex: 1),
                _colHeader('DATES', flex: 2),
                _colHeader('KATHA TOPIC / HEADING', flex: 4),
                _colHeader('LOCATION', flex: 3),
                _colHeader('COUNTRY', flex: 2),
                _colHeader('LANGUAGE', flex: 1),
                _colHeader('PLAYLIST', flex: 1),
                _colHeader('LINK', flex: 1),
              ],
            ),
          ),
        ),
        
        // Katha List
        if (kathas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(50.0),
            child: Text('No Kathas found matching your search term.', style: TextStyle(color: Colors.grey)),
          ),
        ...kathas.asMap().entries.map((entry) {
          int index = entry.key;
          KathaRecord katha = entry.value;
          bool isExpanded = expandedIndex == index;
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: _circleId(katha.kathaNumber)),
                    Expanded(flex: 1, child: Text(katha.year, style: const TextStyle(fontSize: 12))),
                    Expanded(flex: 2, child: Text(katha.dates, style: const TextStyle(fontSize: 11, color: Colors.brown))),
                    Expanded(flex: 4, child: Text(katha.topic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 3, child: Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.brown), const SizedBox(width: 4), Text(katha.location, style: const TextStyle(fontSize: 12))])),
                    Expanded(flex: 2, child: Row(children: [const Icon(Icons.flag_outlined, size: 14, color: Colors.green), const SizedBox(width: 4), Text(katha.country, style: const TextStyle(fontSize: 12))])),
                    Expanded(flex: 1, child: Text(katha.language, style: const TextStyle(fontSize: 12))),
                    Expanded(
                      flex: 1, 
                      child: IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: Colors.red, size: 20),
                        onPressed: () => _launchUrl(katha.youtubePlaylistUrl), 
                        tooltip: 'Open YouTube Playlist',
                      ),
                    ),
                    Expanded(
                      flex: 1, 
                      child: InkWell(
                        onTap: () {
                          setState(() => expandedIndex = isExpanded ? null : index);
                        },
                        child: const Text('More >', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpanded) _buildExpandedDetails(katha),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 100),
                child: Divider(height: 1),
              ),
            ],
          );
        }).toList(),

        const SizedBox(height: 40),
        if (totalItems > 0) _buildPagination(totalPages),
      ],
    );
  }

  Widget _buildExpandedDetails(KathaRecord katha) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      padding: const EdgeInsets.all(30),
      color: const Color(0xFFFDF9F6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(katha.location, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('${katha.dates} ${katha.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
                Text(katha.description, style: const TextStyle(fontSize: 13, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _launchUrl(katha.youtubePlaylistUrl),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.network(katha.imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[300], height: 200)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: const Icon(Icons.open_in_new, color: Colors.white, size: 16),
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

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: currentPage > 1 ? Colors.black : Colors.grey,
          onPressed: currentPage > 1 
            ? () => setState(() {
              currentPage--;
              expandedIndex = null;
            }) 
            : null,
        ),
        ...List.generate(totalPages, (index) {
          int pageNum = index + 1;
          if (totalPages > 5 && (pageNum > 3 && pageNum < totalPages)) {
            if (pageNum == 4) return const Text(' ... ');
            return const SizedBox.shrink();
          }
          return _pageCircle(pageNum.toString(), currentPage == pageNum);
        }),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: currentPage < totalPages ? Colors.black : Colors.grey,
          onPressed: currentPage < totalPages 
            ? () => setState(() {
              currentPage++;
              expandedIndex = null;
            }) 
            : null,
        ),
        const SizedBox(width: 40),
        const Text('Show ', style: TextStyle(fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
          child: Row(children: [Text(itemsPerPage.toString(), style: const TextStyle(fontSize: 12)), const Icon(Icons.keyboard_arrow_down, size: 14)]),
        ),
      ],
    );
  }

  Widget _pageCircle(String num, bool active) {
    return InkWell(
      onTap: () => setState(() {
        currentPage = int.parse(num);
        expandedIndex = null;
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF444444) : Colors.white,
          shape: BoxShape.circle,
          border: active ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Center(child: Text(num, style: TextStyle(color: active ? Colors.white : Colors.black, fontSize: 12))),
      ),
    );
  }

  Widget _filterDropdown(String label) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)), const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey)],
      ),
    );
  }

  Widget _circleId(String id) {
    return Container(
      width: 30, height: 30,
      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      child: Center(child: Text(id, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
    );
  }

  static Widget _colHeader(String title, {required int flex}) {
    return Expanded(flex: flex, child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)));
  }

  Widget _buildUpcomingKathasPlaceholder() {
    return const Center(child: Padding(padding: EdgeInsets.all(100), child: Text('Upcoming Kathas Page Content will be built next.')));
  }
}
