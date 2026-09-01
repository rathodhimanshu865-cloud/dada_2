import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
import '../../utils/app_typography.dart';
import '../../utils/responsive_utils.dart';

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
    final bool isMobile = context.isMobile;
    final bool isTablet = context.isTablet;

    final List<ProductModel> displayProducts = productController.searchQuery.isEmpty 
        ? (productController.browsingProducts.isNotEmpty ? productController.browsingProducts : productController.filteredProducts)
        : productController.searchResults;

    return ProductCartLayout(
      controller: homeController,
      slivers: [
        SliverToBoxAdapter(child: _buildHeroBanner(context, isMobile)),
        SliverToBoxAdapter(child: SizedBox(height: isMobile ? 20 : 40)),
        SliverToBoxAdapter(child: _buildFilterRow(context, productController, displayProducts, isMobile)),
        SliverToBoxAdapter(child: SizedBox(height: isMobile ? 20 : 40)),
        
        if (productController.isBrowsingLoading && displayProducts.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF0F4C5C)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.loadingSacredProducts, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
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
                  Text(AppLocalizations.of(context)!.noProductsFound, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        else
          _buildProductGrid(context, productController, displayProducts, isMobile),
          
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isMobile) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final settings = Provider.of<HomePageController>(context).websiteSettings;
    return Container(
      width: double.infinity,
      color: const Color(0xFF07404C),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60, horizontal: 20),
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
                child: Text(AppLocalizations.of(context)!.sacredCatalogue, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 24),
              Text(
                settings.localizedCatalogueHeading(lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: isMobile ? 36 : 56,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                settings.localizedCatalogueSubtitle(lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.5), fontSize: 16, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, ProductController prod, List<ProductModel> displayProducts, bool isMobile) {
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
      {'name': AppLocalizations.of(context)!.allSacredProducts, 'id': 'all', 'icon': null},
      ...prod.categoryObjects.map((c) => {
        'name': c.localizedName(lang),
        'id': c.id,
        'icon': iconMap[c.id.toLowerCase()] ?? Icons.auto_awesome_outlined,
      }),
    ];

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
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                size: 14,
                                color: isSelected ? Colors.amber.shade200 : const Color(0xFF07404C),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              cat['name']!.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                fontSize: 9,
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
              
              // Search and Sort Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
                child: Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  children: [
                    Expanded(
                      flex: isMobile ? 0 : 1,
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
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.searchProductPlaceholder,
                                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isMobile) const SizedBox(height: 16),
                    if (!isMobile) const SizedBox(width: 24),
                    Container(
                      width: isMobile ? double.infinity : null,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: isMobile,
                          value: prod.sortBy == 'name' ? 'A-Z' : (prod.sortBy == 'price' ? 'Price: Low to High' : 'Latest Arrival'),
                          items: [
                            DropdownMenuItem(value: 'A-Z', child: Text(AppLocalizations.of(context)!.sortByAz, style: const TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Price: Low to High', child: Text(AppLocalizations.of(context)!.sortByPriceLow, style: const TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Latest Arrival', child: Text(AppLocalizations.of(context)!.sortByLatest, style: const TextStyle(fontSize: 13))),
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
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.showingSacredItems(displayProducts.length),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                    Text(
                      prod.selectedCategoryId == 'all' 
                        ? AppLocalizations.of(context)!.allSacredProducts 
                        : prod.localizedSelectedCategory(lang),
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

  Widget _buildProductGrid(BuildContext context, ProductController prod, List<ProductModel> products, bool isMobile) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          childAspectRatio: 0.72,
          crossAxisSpacing: isMobile ? 12 : 24,
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
