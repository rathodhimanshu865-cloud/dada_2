import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
import '../../utils/app_typography.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? categoryId = ModalRoute.of(context)?.settings.arguments as String?;
      final prodController = Provider.of<ProductController>(context, listen: false);
      
      prodController.selectCategory(categoryId ?? 'all');
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final productController = Provider.of<ProductController>(context);

    final List<ProductModel> displayProducts = productController.searchQuery.isEmpty 
        ? (productController.browsingProducts.isNotEmpty ? productController.browsingProducts : productController.filteredProducts)
        : productController.searchResults;

    return ProductCartLayout(
      controller: homeController,
      slivers: [
        SliverToBoxAdapter(child: _buildHeroBanner(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        SliverToBoxAdapter(child: _buildFilterRow(context, productController, displayProducts)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        
        if (productController.isBrowsingLoading && displayProducts.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0F4C5C)),
                  SizedBox(height: 16),
                  Text('Loading sacred products...', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          )
        else if (displayProducts.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade200),
                  const SizedBox(height: 24),
                  const Text('No products found in this category.', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        else
          _buildProductGrid(context, productController, displayProducts),
          
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final settings = Provider.of<HomePageController>(context).websiteSettings;
    return Container(
      width: double.infinity,
      color: const Color(0xFF07404C),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('SACRED CATALOGUE', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 24),
              Text(
                settings.localizedCatalogueHeading(lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 56,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                settings.catalogueSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.5), fontSize: 16, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, ProductController prod, List<ProductModel> displayProducts) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    // 1. Static map of icons for known categories
    final Map<String, IconData> iconMap = {
      'keychain': Icons.vpn_key_outlined,
      'acrylic_photo_frame': Icons.crop_original,
      'temple': Icons.temple_hindu_outlined,
      'footprints_paduka': Icons.pets_outlined,
      'sticker': Icons.sticky_note_2_outlined,
      'pouch_pocket_pin': Icons.wallet_outlined,
      'rakshasutra_sacred_thread': Icons.gesture,
      'other': Icons.more_horiz_outlined,
    };

    // 2. Use real categories from database if available
    final List<Map<String, dynamic>> uiCategories = [
      {'name': 'All Products', 'id': 'all', 'icon': null},
      ...prod.categoryObjects.map((c) => {
        'name': c.localizedName(lang),
        'id': c.id,
        'icon': iconMap[c.id.toLowerCase()] ?? Icons.auto_awesome_outlined,
      }),
    ];

    if (prod.categoryObjects.isEmpty) {
        // Fallback to static if not loaded yet
        uiCategories.addAll([
          {'name': 'Acrylic Photo Frame', 'id': 'acrylic_photo_frame', 'icon': iconMap['acrylic_photo_frame']},
          {'name': 'Footprints / Paduka', 'id': 'footprints_paduka', 'icon': iconMap['footprints_paduka']},
          {'name': 'Keychain', 'id': 'keychain', 'icon': iconMap['keychain']},
          {'name': 'Other Products', 'id': 'other', 'icon': iconMap['other']},
          {'name': 'Pouch / Pocket Pin', 'id': 'pouch_pocket_pin', 'icon': iconMap['pouch_pocket_pin']},
          {'name': 'Rakshasutra / Sacred Thread', 'id': 'rakshasutra_sacred_thread', 'icon': iconMap['rakshasutra_sacred_thread']},
          {'name': 'Sticker', 'id': 'sticker', 'icon': iconMap['sticker']},
          {'name': 'Temple', 'id': 'temple', 'icon': iconMap['temple']},
        ]);
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: uiCategories.map((cat) {
                    bool isSelected = prod.selectedCategoryId.toLowerCase() == cat['id'].toString().toLowerCase();
                    return InkWell(
                      onTap: () => prod.selectCategory(cat['id']!),
                      borderRadius: BorderRadius.circular(30),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF07404C) : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF07404C) : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (cat['icon'] != null) ...[
                              Icon(
                                cat['icon'] as IconData,
                                size: 16,
                                color: isSelected ? Colors.amber.shade200 : const Color(0xFF07404C),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              cat['name']!.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              
              // Search and Sort Bar as per image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 18, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                onChanged: (v) => prod.performSearch(v),
                                decoration: const InputDecoration(
                                  hintText: 'Search by name, SKU, or keyword...',
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: prod.sortBy == 'name' ? 'A-Z' : (prod.sortBy == 'price' ? 'Price: Low to High' : 'Latest Arrival'),
                          items: const [
                            DropdownMenuItem(value: 'A-Z', child: Text('A-Z', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Latest Arrival', child: Text('Latest Arrival', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) {
                            if (v == 'A-Z') {
                              prod.updateSort('name', false);
                            } else if (v == 'Price: Low to High') {
                              prod.updateSort('price', false);
                            } else if (v == 'Latest Arrival') {
                              prod.updateSort('createdAt', true);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Text(
                      'Showing ${displayProducts.length} sacred items in ',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    Text(
                      prod.selectedCategory,
                      style: const TextStyle(color: Color(0xFFAD8B63), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductController prod, List<ProductModel> products) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.72,
          crossAxisSpacing: 24,
          mainAxisSpacing: 40,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProductCard(product: products[index]);
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
