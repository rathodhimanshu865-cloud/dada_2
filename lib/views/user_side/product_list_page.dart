import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/product_model.dart';
import 'components/product_card.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // Theme Tokens
  final Color _teal = const Color(0xFF0F4C5C);
  final Color _gold = const Color(0xFFC19A6B);
  final Color _darkTeal = const Color(0xFF07303D);

  String _searchQuery = '';
  String _selectedCategory = 'All Sacred Products';
  String _sortBy = 'Featured First';
  bool _inStockOnly = false;
  bool _sortAscending = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All Sacred Products', 'icon': Icons.grid_view_rounded},
    {'name': 'Keychain', 'icon': Icons.vpn_key_rounded},
    {'name': 'Acrylic Photo Frame', 'icon': Icons.filter_frames_rounded},
    {'name': 'Temple', 'icon': Icons.account_balance_rounded},
    {'name': 'Footprints / Paduka', 'icon': Icons.pets_rounded},
    {'name': 'Sticker', 'icon': Icons.label_important_rounded},
    {'name': 'Pouch / Pocket Pin', 'icon': Icons.shopping_bag_rounded},
    {'name': 'Rakshasutra / Sacred Thread', 'icon': Icons.gesture_rounded},
    {'name': 'Other Products', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handle category passed from header/navigation
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args != 'All Products') {
      // Map 'All Products' (from header) to 'All Sacred Products' (from this page's list)
      if (args == 'All Products') {
         _selectedCategory = 'All Sacred Products';
      } else {
         _selectedCategory = args;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomePageController>(context);
    final productCtrl = Provider.of<ProductController>(context);
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final bool isMob = MediaQuery.of(context).size.width < 900;

    // Filtering & Sorting Logic
    List<Product> products = productCtrl.visibleProducts.where((p) {
      bool matchesCat = _selectedCategory == 'All Sacred Products' || p.category == _selectedCategory;
      bool matchesSearch = p.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesStock = !_inStockOnly || p.stockQuantity > 0;
      return matchesCat && matchesSearch && matchesStock;
    }).toList();

    // Sort
    if (_sortBy == 'Newest') {
      products.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    } else if (_sortBy == 'Price: Low to High') {
      products.sort((a, b) => (a.salePrice ?? a.price ?? 0).compareTo(b.salePrice ?? b.price ?? 0));
    } else if (_sortBy == 'Price: High to Low') {
      products.sort((a, b) => (b.salePrice ?? b.price ?? 0).compareTo(a.salePrice ?? a.price ?? 0));
    }
    
    if (!_sortAscending) {
      products = products.reversed.toList();
    }

    final filteredCount = products.length;

    return UserPageLayout(
      controller: home,
      child: Column(
        children: [
          // 1. HERO BANNER
          _buildHero(home, lang, isMob),

          // 2. CATEGORY FILTER CHIPS
          _buildCategoryChips(isMob),

          // 3. SEARCH & SORT BAR
          _buildSearchAndSort(isMob, filteredCount),

          // 4. PRODUCT GRID
          _buildProductGrid(context, products, isMob),

          UserFooter(controller: home),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products, bool isMob) {
    if (products.isEmpty) {
      return Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No products match your filters', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMob ? 24 : 80, vertical: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 1400 ? 4 : (MediaQuery.of(context).size.width > 1000 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1)),
          crossAxisSpacing: 24,
          mainAxisSpacing: 32,
          childAspectRatio: 0.68,
        ),
        itemCount: products.length,
        itemBuilder: (context, i) => ProductCard(product: products[i]),
      ),
    );
  }

  Widget _buildHero(HomePageController home, String lang, bool isMob) {
    String storeName = home.websiteSettings.name.isEmpty ? "DADA" : home.websiteSettings.name;
    String heading = _selectedCategory == 'All Sacred Products' ? 'Sacred Devotional Catalog' : _selectedCategory;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(isMob ? 24 : 80, isMob ? 160 : 220, isMob ? 24 : 80, 80),
      decoration: BoxDecoration(
        color: _darkTeal,
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, color: _gold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "$storeName Sacred Devotional Catalog".toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Heading
              Text(
                heading,
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: isMob ? 40 : 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                "Experience the divine essence through our handpicked collection of spiritual items.",
                textAlign: TextAlign.center,
                style: AppTypography.bodyStyle(context, color: Colors.white.withOpacity(0.7), fontSize: isMob ? 14 : 18),
              ),
              const SizedBox(height: 48),
              // Trust Indicators
              _buildTrustIndicators(home, isMob),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIndicators(HomePageController home, bool isMob) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _trustItem(Icons.circle, Colors.green, "In-Stock & Ready to Ship"),
        _dotDivider(),
        _trustItem(Icons.circle, _gold, "Official Digital Receipts"),
        _dotDivider(),
        _trustItem(Icons.circle, Colors.blueAccent, "Fast Delivery Across India"),
      ],
    );
  }

  Widget _trustItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 8),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _dotDivider() {
    return Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle));
  }

  Widget _buildCategoryChips(bool isMob) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isMob ? 24 : 80),
        child: Row(
          children: _categories.map((cat) {
            bool isActive = _selectedCategory == cat['name'];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat['icon'], size: 16, color: isActive ? Colors.white : _teal),
                    const SizedBox(width: 8),
                    Text(cat['name']),
                  ],
                ),
                selected: isActive,
                onSelected: (val) => setState(() => _selectedCategory = cat['name']),
                selectedColor: _darkTeal,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isActive ? Colors.white : _darkTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: isActive ? _darkTeal : Colors.grey[300]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: isActive ? 4 : 0,
                pressElevation: 0,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchAndSort(bool isMob, int count) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMob ? 24 : 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Search Input
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Search by name, SKU, or keyword...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  ),
                ),
              ),
              if (!isMob) const SizedBox(width: 24),
              if (!isMob) _buildSortControls(),
            ],
          ),
          if (isMob) ...[
            const SizedBox(height: 16),
            _buildSortControls(),
          ],
          const SizedBox(height: 24),
          Text(
            "Showing $count sacred items in ${_selectedCategory == 'All Sacred Products' ? 'All Collections' : _selectedCategory}",
            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
          ),
          const Divider(height: 40),
        ],
      ),
    );
  }

  Widget _buildSortControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // In-Stock Checkbox
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: _inStockOnly, 
              onChanged: (v) => setState(() => _inStockOnly = v ?? false),
              activeColor: _teal,
            ),
            const Text("In-Stock Only", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(width: 16),
        // Sort Direction
        IconButton(
          onPressed: () => setState(() => _sortAscending = !_sortAscending),
          icon: Icon(_sortAscending ? Icons.south_rounded : Icons.north_rounded, size: 20),
          tooltip: "Sort Direction",
        ),
        // Sort Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
            items: ['Featured First', 'Newest', 'Price: Low to High', 'Price: High to Low']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _sortBy = v!),
          ),
        ),
      ],
    );
  }

}
