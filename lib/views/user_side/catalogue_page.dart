import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
      
      if (categoryId != null) {
        prodController.selectCategory(categoryId);
      } else {
        prodController.fetchBrowsingProducts(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final productController = Provider.of<ProductController>(context);

    return ProductCartLayout(
      controller: homeController,
      slivers: [
        SliverToBoxAdapter(child: _buildHeroBanner(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        SliverToBoxAdapter(child: _buildFilterRow(context, productController)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        
        if (productController.isBrowsingLoading && productController.browsingProducts.isEmpty)
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
        else if (productController.browsingProducts.isEmpty)
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
          _buildProductGrid(context, productController),
          
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
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
                'Sacred Offerings of Pu. Dada',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 56,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Explore authentic handcrafted and consecrated items added directly from the ashram.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.5), fontSize: 16, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, ProductController prod) {
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

    // 2. Build the list of categories to display
    final List<Map<String, dynamic>> uiCategories = [
      {'name': 'All Sacred Products', 'id': 'all', 'icon': null},
      // Map database categories to their icons, ensuring correct IDs
      ...prod.categoryObjects.map((c) => {
        'name': c.name,
        'id': c.id,
        'icon': iconMap[c.id.toLowerCase()] ?? iconMap[c.name.toLowerCase().replaceAll(' ', '_')] ?? Icons.category_outlined,
      }),
    ];

    // 3. Ensure 'Other Products' is always present if not already in DB
    if (!uiCategories.any((cat) => cat['id'].toString().toLowerCase() == 'other')) {
      uiCategories.add({
        'name': 'Other Products',
        'id': 'other',
        'icon': Icons.more_horiz_outlined,
      });
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: uiCategories.map((cat) {
                    bool isSelected = prod.selectedCategoryId.toLowerCase() == cat['id'].toString().toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => prod.selectCategory(cat['id']!),
                        borderRadius: BorderRadius.circular(30),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                const SizedBox(width: 8),
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
                    Row(
                      children: [
                        Checkbox(
                          value: prod.onlyInStock,
                          onChanged: (v) => prod.updateFilters(inStock: v),
                          activeColor: const Color(0xFF07404C),
                        ),
                        const Text('In-Stock Only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
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
                          value: prod.sortBy,
                          items: const [
                            DropdownMenuItem(value: 'createdAt', child: Text('Latest Arrival', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'price', child: Text('Price: Low to High', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'name', child: Text('Name: A-Z', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) {
                            if (v != null) prod.updateSort(v, true);
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
                      'Showing ${prod.browsingProducts.length} sacred items in ',
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

  Widget _buildProductGrid(BuildContext context, ProductController prod) {
    // 1. Prioritize browsingProducts (paged)
    // 2. If empty, fall back to filteredProducts (cached/local)
    final List<ProductModel> products = prod.searchQuery.isEmpty 
        ? (prod.browsingProducts.isNotEmpty ? prod.browsingProducts : prod.filteredProducts)
        : prod.searchResults;

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
