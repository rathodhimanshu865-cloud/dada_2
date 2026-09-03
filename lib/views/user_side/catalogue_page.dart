import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../../controllers/language_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/animation_utils.dart';

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
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    final List<ProductModel> displayProducts = productController.searchQuery.isEmpty 
        ? (productController.browsingProducts.isNotEmpty ? productController.browsingProducts : productController.filteredProducts)
        : productController.searchResults;

    return ProductCartLayout(
      controller: homeController,
      slivers: [
        SliverToBoxAdapter(
          child: FadeIn(
            duration: const Duration(milliseconds: 800),
            child: _buildHeroBanner(context, isMobile),
          ),
        ),
        
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyFilterDelegate(
            child: _buildFilterRow(context, productController, displayProducts, isMobile),
          ),
        ),

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
                  FadeIn(
                    child: Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade200),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    child: Text(AppLocalizations.of(context)!.noProductsFound, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
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
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(AppLocalizations.of(context)!.sacredCatalogue.toUpperCase(), style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  settings.localizedCatalogueHeading(lang),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: isMobile ? 40 : 64,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: Text(
                  settings.localizedCatalogueSubtitle(lang),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.5), fontSize: 16, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, ProductController prod, List<ProductModel> displayProducts, bool isMobile) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
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
      color: Colors.white.withOpacity(0.95),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
                    child: SiteFilterTabBar(
                      compact: true,
                      tabs: uiCategories.map((c) => c['name'] as String).toList(),
                      activeIndex: uiCategories.indexWhere((c) => prod.selectedCategoryId.toLowerCase() == c['id'].toString().toLowerCase()) != -1 
                          ? uiCategories.indexWhere((c) => prod.selectedCategoryId.toLowerCase() == c['id'].toString().toLowerCase()) 
                          : 0,
                      onTabSelected: (index) {
                        prod.selectCategory(uiCategories[index]['id'] as String);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Search and Sort Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
                    child: Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(
                          flex: isMobile ? 0 : 1,
                          child: Container(
                            height: 44,
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
                                    style: const TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!.searchProductPlaceholder,
                                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMobile) const SizedBox(height: 12),
                        if (!isMobile) const SizedBox(width: 16),
                        Container(
                          height: 44,
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
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                              items: [
                                DropdownMenuItem(value: 'A-Z', child: Text(AppLocalizations.of(context)!.sortByAz)),
                                DropdownMenuItem(value: 'Price: Low to High', child: Text(AppLocalizations.of(context)!.sortByPriceLow)),
                                DropdownMenuItem(value: 'Latest Arrival', child: Text(AppLocalizations.of(context)!.sortByLatest)),
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
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductController prod, List<ProductModel> products, bool isMobile) {
    final bool isTablet = Responsive.isTablet(context);
    final bool isDesktop = Responsive.isDesktop(context);
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(isMobile ? 12 : 40, 20, isMobile ? 12 : 40, 0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
          childAspectRatio: isDesktop ? 0.72 : (isTablet ? 0.7 : 0.6),
          crossAxisSpacing: isMobile ? 12 : 24,
          mainAxisSpacing: isMobile ? 16 : 40,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return SiteCardEntrance(
              key: ValueKey('${products[index].id}_$index'),
              index: index,
              child: ProductCard(product: products[index]),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyFilterDelegate({required this.child});

  @override
  double get minExtent => 165;
  @override
  double get maxExtent => 165;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: overlapsContent ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) => true;
}
