import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
import '../../utils/app_typography.dart';

class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final productController = Provider.of<ProductController>(context);

    return ProductCartLayout(
      controller: homeController,
      child: Column(
        children: [
          _buildHeroBanner(context),
          const SizedBox(height: 30),
          _buildFilterRow(context, productController),
          const SizedBox(height: 20),
          _buildControlsRow(context, productController),
          const SizedBox(height: 30),
          _buildProductGrid(context, productController),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F4C5C), // Dark Teal
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Breadcrumb / Tag
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
              // Main Heading
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
              // Subtitle
              Text(
                'Authentic handcrafted and consecrated items from Pu. Dada\'s ashram to grace your space.\nAll proceeds support charitable causes and ashram activities.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyStyle(
                  context,
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              // Checkmarks row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _checkMarkItem('100% Quality Checked'),
                  const SizedBox(width: 24),
                  _checkMarkItem('Handcrafted by skilled artisans'),
                  const SizedBox(width: 24),
                  _checkMarkItem('Consecrated with Vedic Mantras'),
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
        const Icon(Icons.check_circle, color: Color(0xFFC89A5B), size: 16), // Temple Gold
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFilterRow(BuildContext context, ProductController prod) {
    final Map<String, String?> filterIcons = {
      'All Sacred Products': null,
      'Keychains': '🔑',
      'Acrylic Photo Frames': '🖼️',
      'Temple': '⛩️',
      'Yantras & Malas': '📿',
      'Idols': '🕉️',
      'Puja Items': '🪔',
      'Books & Granths': '📚',
      'Apparel': '👕',
    };

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
                  avatar: filterIcons[cat] != null
                      ? Text(filterIcons[cat]!)
                      : null,
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) prod.selectCategory(cat);
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
              // Search Bar
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
                    Icon(Icons.search, color: Colors.grey.shade500, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products by name...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMobile) const SizedBox(height: 16),
              // Sort Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${prod.filteredProducts.length} items found', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Text('Sort By:', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        const SizedBox(width: 8),
                        Text('Featured', style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
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
    if (prod.filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Text('No products found in this category.', style: AppTypography.bodyStyle(context, color: Colors.grey)),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.6,
            crossAxisSpacing: 20,
            mainAxisSpacing: 30,
          ),
          itemCount: prod.filteredProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: prod.filteredProducts[index]);
          },
        ),
      ),
    );
  }
}
