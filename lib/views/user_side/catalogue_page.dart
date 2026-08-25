import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';

class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final productController = Provider.of<ProductController>(context);
    final cartController = Provider.of<CartController>(context, listen: false);

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
          _buildProductGrid(context, productController, cartController),
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: prod.categories.map((cat) {
              bool isSelected = prod.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => prod.selectCategory(cat),
                  child: Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (filterIcons[cat] != null) ...[Text(filterIcons[cat]!), const SizedBox(width: 6)],
                        Text(cat),
                      ],
                    ),
                    backgroundColor: isSelected ? const Color(0xFF0F4C5C) : Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                    side: BorderSide(color: isSelected ? const Color(0xFF0F4C5C) : Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsRow(BuildContext context, ProductController prod) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Search Bar
            Container(
              width: 300,
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
            // Sort Dropdown
            Row(
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
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductController prod, CartController cart) {
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
            return _enhancedProductCard(context, prod.filteredProducts[index], cart);
          },
        ),
      ),
    );
  }

  Widget _enhancedProductCard(BuildContext context, ProductModel product, CartController cart) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/product_details');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey.shade100,
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade50,
                          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Consumer<ProductController>(
                    builder: (context, prodCtrl, child) {
                      bool isLiked = prodCtrl.isLiked(product.id);
                      return Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => prodCtrl.toggleLike(product.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isLiked ? Colors.redAccent : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.category,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFC89A5B), size: 12),
                            const SizedBox(width: 4),
                            Text('4.8 (24)', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.title,
                      style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF2B2B2B)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹ ${product.price.toStringAsFixed(2)}',
                      style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F4C5C)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        cart.addToCart(product, 1);
                        Scaffold.of(context).openEndDrawer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C5C),
                        minimumSize: const Size(double.infinity, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text('ADD TO CART', style: AppTypography.bodyStyle(context, color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
