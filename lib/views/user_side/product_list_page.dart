import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../utils/app_typography.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final Color _teal = const Color(0xFF0F4C5C);
  final Color _gold = const Color(0xFFC19A6B);
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context);
    final productController = Provider.of<ProductController>(context);
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    final bool isDesktop = MediaQuery.of(context).size.width > 1100;

    final categories = ['All', ...productController.visibleProducts.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()];
    final filteredProducts = _selectedCategory == 'All' 
        ? productController.visibleProducts 
        : productController.visibleProducts.where((p) => p.category == _selectedCategory).toList();

    return UserPageLayout(
      controller: homeController,
      child: Column(
        children: [
          // --- HERO HEADER ---
          _buildHero(isMobile, lang),

          // --- FILTERS & GRID ---
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : (isDesktop ? 100 : 60), vertical: 60),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    // Category Tabs
                    if (categories.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: categories.map((cat) => _CategoryChip(
                            label: cat, 
                            isSelected: _selectedCategory == cat,
                            onTap: () => setState(() => _selectedCategory = cat),
                          )).toList(),
                        ),
                      ),

                    // Product Grid
                    if (productController.isLoading)
                      const Center(child: CircularProgressIndicator(color: Color(0xFF0F4C5C)))
                    else if (filteredProducts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(100.0),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No products available at the moment.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : (isDesktop ? 3 : 2),
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 40,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, i) => _ProductCard(product: filteredProducts[i]),
                      ),
                  ],
                ),
              ),
            ),
          ),

          UserFooter(controller: homeController),
        ],
      ),
    );
  }

  Widget _buildHero(bool isMobile, String lang) {
    String title = lang == 'hi' ? 'संग्रह' : lang == 'gu' ? 'સંગ્રહ' : 'OUR COLLECTION';
    String subtitle = lang == 'hi' ? 'पवित्र और आध्यात्मिक उत्पाद' : lang == 'gu' ? 'પવિત્ર અને આધ્યાત્મિક ઉત્પાદનો' : 'Sacred & Spiritual Offerings';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(isMobile ? 24 : 80, isMobile ? 140 : 200, isMobile ? 24 : 80, 80),
      color: const Color(0xFFF9F3EA),
      child: Center(
        child: Column(
          children: [
            Text(title, style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.bold, color: _gold, letterSpacing: 4)),
            const SizedBox(height: 15),
            Text(subtitle, textAlign: TextAlign.center, style: AppTypography.headingStyle(context, fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.bold, color: _teal)),
            const SizedBox(height: 25),
            Container(height: 3, width: 60, color: _gold),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F4C5C) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? const Color(0xFF0F4C5C) : Colors.grey[300]!),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0F4C5C).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/products/${widget.product.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.04),
                      blurRadius: _isHovered ? 30 : 15,
                      offset: Offset(0, _isHovered ? 15 : 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.product.images.isNotEmpty ? widget.product.images.first : 'https://via.placeholder.com/400x500',
                        fit: BoxFit.cover,
                      ),
                      if (_isHovered)
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          child: const Center(
                            child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      if (widget.product.featured)
                        Positioned(
                          top: 15, left: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: const Color(0xFFC19A6B), borderRadius: BorderRadius.circular(4)),
                            child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.product.category.toUpperCase(),
              style: const TextStyle(color: Color(0xFFC19A6B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.title,
              style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C5C)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.product.price != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '₹${widget.product.price}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                IconButton(
                  onPressed: () {
                    Provider.of<CartController>(context, listen: false).addToCart(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.title} added to cart'),
                        action: SnackBarAction(label: 'VIEW CART', onPressed: () => Navigator.pushNamed(context, '/cart')),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF0F4C5C)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
