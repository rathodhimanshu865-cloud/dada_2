import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
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
    name: "Dada's Photo Keychain",
    categoryId: 'Keychains',
    price: 99.00,
    comparePrice: 499.00,
    imageUrls: ['https://via.placeholder.com/600x800/E8DCC4/0F4C5C?text=Main+Image'],
  );

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
    final productController = Provider.of<ProductController>(context);
    
    final Color primaryTeal = const Color(0xFF0F4C5C);
    final Color accentGold = const Color(0xFFC89A5B);

    final String? productId = ModalRoute.of(context)?.settings.arguments as String?;

    return ProductCartLayout(
      controller: homeController,
      child: StreamBuilder<ProductModel?>(
        stream: productId != null ? productController.getProductDetails(productId) : Stream.value(_demoProduct),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 600,
              child: Center(child: CircularProgressIndicator(color: Color(0xFF0F4C5C))),
            );
          }
          
          final product = snapshot.data ?? _demoProduct;
          final productImages = product.imageUrls.isNotEmpty ? product.imageUrls : [product.imageUrl];

          if (_selectedImageIndex >= productImages.length) {
            _selectedImageIndex = 0;
          }

          return SingleChildScrollView(
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
                          _buildBreadcrumbs(context, product.category),
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
                                      onTap: () => _showLargeImage(context, productImages[_selectedImageIndex]),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 700,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: productImages[_selectedImageIndex].isNotEmpty
                                                ? Image.network(
                                                    productImages[_selectedImageIndex],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      color: Colors.grey.shade50,
                                                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.grey.shade50,
                                                    child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                                                  ),
                                            ),
                                          ),
                                          if (product.isFeatured)
                                            Positioned(
                                              top: 20,
                                              left: 20,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                                                child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    if (productImages.length > 1)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: productImages.asMap().entries.map((e) {
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
                                                image: e.value.isNotEmpty ? DecorationImage(image: NetworkImage(e.value), fit: BoxFit.cover) : null,
                                              ),
                                              child: e.value.isEmpty ? const Icon(Icons.image_outlined, color: Colors.grey) : null,
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
                                      product.name,
                                      style: AppTypography.headingStyle(context, fontSize: 36, fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Row(children: List.generate(5, (i) => Icon(Icons.star, size: 18, color: accentGold))),
                                        const SizedBox(width: 10),
                                        const Text('4.9 Rating', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 25),
                                    Row(
                                      children: [
                                        if (product.comparePrice != null) ...[
                                          Text('₹ ${product.price.toInt()}', style: AppTypography.headingStyle(context, fontSize: 32, color: primaryTeal, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 15),
                                          Text('₹ ${product.comparePrice!.toInt()}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 20)),
                                          const SizedBox(width: 15),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                                            child: Text(
                                              'SAVE ${product.discountPercentage}%', 
                                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12)
                                            ),
                                          ),
                                        ] else
                                          Text('₹ ${product.price.toInt()}', style: AppTypography.headingStyle(context, fontSize: 32, color: primaryTeal, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: product.isAvailable ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2), 
                                        borderRadius: BorderRadius.circular(6), 
                                        border: Border.all(color: product.isAvailable ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2))
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(width: 8, height: 8, decoration: BoxDecoration(color: product.isAvailable ? const Color(0xFF10B981) : Colors.red, shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Text(
                                            product.isAvailable ? 'In Stock (${product.stock} available) • Fast Dispatch' : 'Currently Unavailable', 
                                            style: AppTypography.bodyStyle(context, color: product.isAvailable ? const Color(0xFF065F46) : Colors.red.shade900, fontSize: 12, fontWeight: FontWeight.bold)
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 50),
                                    // Actions row
                                    Row(
                                      children: [
                                        _buildQuantitySelector(context),
                                        const SizedBox(width: 20),
                                        Expanded(child: _buildAddToCartButton(context, cartController, primaryTeal, product)),
                                        const SizedBox(width: 15),
                                        _buildDetailsWishlistButton(context, product.id),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    _buildBuyItNowButton(context, accentGold, product),
                                    const SizedBox(height: 30),
                                    _buildTrustIndicators(context),
                                    const SizedBox(height: 40),
                                    _buildDetailedTabs(context, primaryTeal, product),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Recommendation Grids
                _buildProductGrid(context, "More From ${product.category}", primaryTeal, product.categoryId),
                
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, String category) {
    return Row(
      children: [
        Text('HOME / ', style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
        Text('PRODUCT / ', style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
        Text(category.toUpperCase(), style: AppTypography.bodyStyle(context, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  Widget _buildAddToCartButton(BuildContext context, CartController cart, Color color, ProductModel product) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: product.isAvailable ? () {
          cart.addToCart(product, _quantity);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Bag!'), duration: Duration(seconds: 2)));
          Scaffold.of(context).openEndDrawer();
        } : null,
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), elevation: 0),
        child: Text('ADD TO BAG', style: AppTypography.bodyStyle(context, color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildDetailsWishlistButton(BuildContext context, String productId) {
    return Consumer<ProductController>(
      builder: (context, prodCtrl, child) {
        bool isLiked = prodCtrl.isLiked(productId);
        return GestureDetector(
          onTap: () => prodCtrl.toggleLike(productId),
          child: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              border: Border.all(color: isLiked ? Colors.redAccent : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.redAccent : Colors.black,
              size: 22,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuyItNowButton(BuildContext context, Color gold, ProductModel product) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: product.isAvailable ? () {
          final auth = Provider.of<AuthController>(context, listen: false);
          if (auth.isAuthenticated) {
            Provider.of<CartController>(context, listen: false).addToCart(product, _quantity);
            Navigator.pushNamed(context, '/checkout');
          } else {
            Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please login to proceed to checkout'),
                backgroundColor: Color(0xFF0F4C5C),
              ),
            );
          }
        } : null,
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
        _trustItem(Icons.local_shipping_outlined, 'Safe Dispatch'),
        _trustItem(Icons.assignment_return_outlined, 'Devotional Item'),
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

  Widget _buildDetailedTabs(BuildContext context, Color teal, ProductModel product) {
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
                Text(product.description.isNotEmpty ? product.description : "This divine spiritual item is encased in premium materials.", style: AppTypography.bodyStyle(context, color: Colors.grey.shade700, height: 1.8)),
                Text("Consecrated items are processed within 24 hours. We ensure safe and respectful delivery to your doorstep.", style: AppTypography.bodyStyle(context, color: Colors.grey.shade700, height: 1.8)),
                const Text("Due to the sacred nature of our products, we typically accept returns only for transit-damaged goods.", style: TextStyle(height: 1.8)),
                const Text("Devotees from around the world have cherished this item for their home altars.", style: TextStyle(height: 1.8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, String title, Color teal, String categoryId) {
    final productController = Provider.of<ProductController>(context, listen: false);
    final products = productController.allProducts.where((p) => p.categoryId == categoryId).take(4).toList();
    if (products.isEmpty) return const SizedBox.shrink();

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
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/catalogue', arguments: categoryId),
                    child: Text('VIEW ALL >', style: AppTypography.bodyStyle(context, color: teal, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, 
                  childAspectRatio: 0.7, 
                  crossAxisSpacing: 25, 
                  mainAxisSpacing: 25
                ),
                itemCount: products.length,
                itemBuilder: (context, index) => ProductCard(product: products[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
