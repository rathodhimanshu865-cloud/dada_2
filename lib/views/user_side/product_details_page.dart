import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;

  final ProductModel _demoProduct = ProductModel(
    id: 'k-01',
    title: "Dada's Photo Keychain",
    category: 'Keychains',
    price: 99.00,
    originalPrice: 499.00,
    imageUrl: 'https://via.placeholder.com/600x800/E8DCC4/0F4C5C?text=Main+Image',
  );

  final List<String> _productImages = [
    'https://via.placeholder.com/600x800/E8DCC4/0F4C5C?text=Main+Image',
    'https://via.placeholder.com/600x800/FAF8F4/0F4C5C?text=Side+View',
    'https://via.placeholder.com/600x800/F0F0F0/0F4C5C?text=Detail+Shot',
  ];

  final List<Color> _availableColors = [
    const Color(0xFFE8DCC4),
    const Color(0xFF0F4C5C),
    const Color(0xFFC89A5B),
  ];

  final List<String> _availableSizes = ['Standard', 'Premium'];

  void _showLargeImage(BuildContext context, String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final cartController = Provider.of<CartController>(context, listen: false);
    
    final Color primaryTeal = const Color(0xFF0F4C5C);
    final Color accentGold = const Color(0xFFC89A5B);

    return ProductCartLayout(
      controller: homeController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBreadcrumbs(context),
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Side: Image Gallery
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _showLargeImage(context, _productImages[_selectedImageIndex]),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 700,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade200),
                                          image: DecorationImage(
                                            image: NetworkImage(_productImages[_selectedImageIndex]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 20,
                                        left: 20,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                                          child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _productImages.asMap().entries.map((e) {
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedImageIndex = e.key),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: _selectedImageIndex == e.key ? primaryTeal : Colors.grey.shade200,
                                            width: 2,
                                          ),
                                          image: DecorationImage(image: NetworkImage(e.value), fit: BoxFit.cover),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 50),
                          // Right Side: Product Info & Purchase
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: accentGold.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                      child: Text('OFFICIAL STORE', style: AppTypography.bodyStyle(context, color: accentGold, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
                                    ),
                                    const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  _demoProduct.title,
                                  style: AppTypography.headingStyle(context, fontSize: 36, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Row(children: List.generate(5, (i) => Icon(Icons.star, size: 18, color: accentGold))),
                                    const SizedBox(width: 10),
                                    Text('120 Reviews', style: AppTypography.bodyStyle(context, fontSize: 14, color: Colors.grey.shade600)),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  children: [
                                    Text('₹ ${_demoProduct.price}', style: AppTypography.headingStyle(context, fontSize: 32, color: primaryTeal, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 15),
                                    Text('₹ ${_demoProduct.originalPrice}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey.shade400, fontSize: 20)),
                                    const SizedBox(width: 15),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: const Text('SAVE 80%', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const Divider(height: 50),
                                // Color Selector
                                Text('COLOR', style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 15),
                                Row(
                                  children: _availableColors.asMap().entries.map((e) {
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedColorIndex = e.key),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 15),
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: e.value,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: _selectedColorIndex == e.key ? primaryTeal : Colors.grey.shade300, width: 2),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 30),
                                // Size Selector
                                Text('SIZE', style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 15),
                                Row(
                                  children: _availableSizes.asMap().entries.map((e) {
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedSizeIndex = e.key),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 15),
                                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _selectedSizeIndex == e.key ? primaryTeal : Colors.white,
                                          border: Border.all(color: _selectedSizeIndex == e.key ? primaryTeal : Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(e.value, style: AppTypography.bodyStyle(context, color: _selectedSizeIndex == e.key ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 40),
                                // Quantity and Add to Bag
                                Row(
                                  children: [
                                    _buildQuantitySelector(context),
                                    const SizedBox(width: 20),
                                    Expanded(child: _buildAddToCartButton(context, cartController, primaryTeal)),
                                    const SizedBox(width: 15),
                                    _buildWishlistButton(context),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                _buildBuyItNowButton(context, accentGold),
                                const SizedBox(height: 30),
                                _buildTrustIndicators(context),
                                const SizedBox(height: 40),
                                _buildDetailedTabs(context, primaryTeal),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      _buildBundleSection(context, primaryTeal),
                    ],
                  ),
                ),
              ),
            ),
            
            // Recommendation Grids
            _buildProductGrid(context, "Similar & Related Devotional Items", primaryTeal),
            _buildProductGrid(context, "More From Keychains", primaryTeal),
            _buildProductGrid(context, "Recently Viewed Sacred Products", primaryTeal),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      children: [
        Text('HOME / ', style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
        Text('PRODUCT / ', style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
        Text('KEYCHAINS', style: AppTypography.bodyStyle(context, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 18)),
          Text('$_quantity', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 18)),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, CartController cart, Color color) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          cart.addToCart(_demoProduct, _quantity);
          Scaffold.of(context).openEndDrawer();
        },
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), elevation: 0),
        child: Text('ADD TO BAG', style: AppTypography.bodyStyle(context, color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildWishlistButton(BuildContext context) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
      child: const Icon(Icons.favorite_border, color: Colors.black, size: 22),
    );
  }

  Widget _buildBuyItNowButton(BuildContext context, Color gold) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<CartController>(context, listen: false).addToCart(_demoProduct, _quantity);
          Navigator.pushNamed(context, '/checkout');
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), elevation: 0),
        child: Text('BUY IT NOW', style: AppTypography.bodyStyle(context, color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildTrustIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _trustItem(Icons.verified_user_outlined, '100% Consecrated'),
        _trustItem(Icons.local_shipping_outlined, 'Sacred Safe Dispatch'),
        _trustItem(Icons.assignment_return_outlined, 'Devotional Blessing'),
      ],
    );
  }

  Widget _trustItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(text, style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailedTabs(BuildContext context, Color teal) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: teal,
            indicatorWeight: 3,
            labelStyle: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'DESCRIPTION'),
              Tab(text: 'SHIPPING'),
              Tab(text: 'RETURNS'),
              Tab(text: 'REVIEWS'),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 150,
            child: TabBarView(
              children: [
                Text("This divine keychain features a high-definition photo of Pu. Jignesh Dada, encased in premium crystal-clear acrylic. It is designed to be a constant reminder of faith and devotion.", style: AppTypography.bodyStyle(context, color: Colors.grey.shade700, height: 1.8)),
                Text("Orders are processed within 24 hours. We use express air shipping to ensure your sacred items reach you as fast as possible.", style: AppTypography.bodyStyle(context, color: Colors.grey.shade700, height: 1.8)),
                Text("Due to the sacred nature of our products, we only accept returns for items damaged during transit.", style: AppTypography.bodyStyle(context, color: Colors.grey.shade700, height: 1.8)),
                Text("Join 100+ devotees who have shared their blessings.", style: AppTypography.bodyStyle(context, color: Colors.grey.shade700, height: 1.8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleSection(BuildContext context, Color teal) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FREQUENTLY CHERISHED TOGETHER', style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 30),
          Row(
            children: [
              _bundleProduct('https://via.placeholder.com/100', "Dada's Photo Keychain", "₹ 99.00"),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.add, color: Colors.grey, size: 20)),
              _bundleProduct('https://via.placeholder.com/100', "Sacred Bhagvat Granth", "₹ 899.00"),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Combined Price: ₹ 998.00', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: teal, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    child: Text('ADD BOTH TO BAG', style: AppTypography.bodyStyle(context, color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bundleProduct(String url, String title, String price) {
    return Row(
      children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover))),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(price, style: AppTypography.bodyStyle(context, color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context, String title, Color teal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('VIEW ALL >', style: AppTypography.bodyStyle(context, color: teal, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 40),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.7, crossAxisSpacing: 25, mainAxisSpacing: 25),
                itemCount: 4,
                itemBuilder: (context, index) => _gridCard(context, teal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridCard(BuildContext context, Color color) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade100), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Container(decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(8)), image: DecorationImage(image: NetworkImage('https://via.placeholder.com/300x400/E8DCC4/0F4C5C'), fit: BoxFit.cover)))),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Divine Sacred Product', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('₹ 299.00', style: AppTypography.bodyStyle(context, color: color, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    Text('₹ 499', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  child: const Text('ADD TO BAG', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
