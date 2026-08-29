import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
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
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
        SliverToBoxAdapter(child: _buildFilterRow(context, productController)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(child: _buildControlsRow(context, productController)),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
        
        if (productController.isBrowsingLoading && productController.browsingProducts.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0F4C5C)),
                  SizedBox(height: 16),
                  Text('Loading sacred products...')
                ],
              ),
            ),
          )
        else if (productController.browsingErrorMessage != null && productController.browsingProducts.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(productController.browsingErrorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => productController.fetchBrowsingProducts(refresh: true), child: const Text('Try Again'))
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
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No products found in this category.'),
                ],
              ),
            ),
          )
        else
          _buildProductGrid(context, productController),
          
        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
      child: const SizedBox.shrink(), // Required by constructor but not used when slivers is present
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F4C5C),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Home > Product Catalogue',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sacred Photo Keychains, Temples, Padukas & Holy Granths',
                textAlign: TextAlign.center,
                style: AppTypography.headingStyle(
                  context,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Authentic handcrafted and consecrated items from Pu. Dada\'s ashram to grace your space.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyStyle(
                  context,
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _checkMarkItem('100% Quality Checked'),
                  const SizedBox(width: 24),
                  _checkMarkItem('Handcrafted by artisans'),
                  const SizedBox(width: 24),
                  _checkMarkItem('Vedic Consecrated'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkMarkItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFFC89A5B), size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFilterRow(BuildContext context, ProductController prod) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: prod.categories.map((cat) {
              bool isSelected = prod.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) prod.updateFilters(category: cat);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF0F4C5C),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0F4C5C) : Colors.grey.shade300,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsRow(BuildContext context, ProductController prod) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Container(
                width: isMobile ? double.infinity : 300,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.search, color: Colors.grey, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => prod.performSearch(v),
                        decoration: const InputDecoration(
                          hintText: 'Search products by name...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMobile) const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${prod.filteredProducts.length} items found', style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: const Row(
                      children: [
                        Text('Sort By:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        SizedBox(width: 8),
                        Text('Featured', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductController prod) {
    final products = prod.searchQuery.isEmpty ? prod.browsingProducts : prod.searchResults;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : (MediaQuery.of(context).size.width < 900 ? 3 : 4),
              childAspectRatio: 0.65,
              crossAxisSpacing: 20,
              mainAxisSpacing: 30,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ProductCard(product: products[index]);
              },
              childCount: products.length,
            ),
          ),
        ),
      ),
    );
  }
}
