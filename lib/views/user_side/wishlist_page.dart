import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

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
          const SizedBox(height: 60),
          _buildProductGrid(context, productController, cartController),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity, color: const Color(0xFF0F4C5C), padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(children: [Text('Your Sacred Wishlist', style: AppTypography.headingStyle(context, fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 10), Text('Sacred items you have cherished and saved for your divine collection.', style: AppTypography.bodyStyle(context, fontSize: 16, color: Colors.white.withOpacity(0.8)))]),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductController prod, CartController cart) {
    final wishlist = prod.wishlistProducts;
    if (wishlist.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 100), child: Column(children: [Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300), const SizedBox(height: 24), Text('Your wishlist is currently empty.', style: AppTypography.bodyStyle(context, fontSize: 18, color: Colors.grey.shade600)), const SizedBox(height: 30), ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/catalogue'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)), child: const Text('EXPLORE CATALOGUE'))])));
    }
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1200), child: GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.6, crossAxisSpacing: 25, mainAxisSpacing: 35), itemCount: wishlist.length, itemBuilder: (context, index) => _wishlistProductCard(context, wishlist[index], prod, cart))));
  }

  Widget _wishlistProductCard(BuildContext context, ProductModel product, ProductController prod, CartController cart) {
    final Color teal = const Color(0xFF0F4C5C);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product_details', arguments: product.id),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), 
                      child: product.imageUrls.isNotEmpty 
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrls[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (c, e, s) => Container(color: Colors.grey.shade50, child: const Icon(Icons.broken_image_outlined, color: Colors.grey)),
                          )
                        : Container(color: Colors.grey.shade50, child: const Icon(Icons.image_outlined, color: Colors.grey)),
                    ),
                  ), 
                  Positioned(top: 10, right: 10, child: GestureDetector(onTap: () => prod.toggleLike(product.id), child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white), child: const Icon(Icons.favorite, size: 18, color: Colors.redAccent))))
                ]
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.categoryId.toUpperCase(), style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 8), Text(product.name, style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 10), Text('₹ ${product.price.toStringAsFixed(2)}', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 18, color: teal)), const SizedBox(height: 15), ElevatedButton(onPressed: () { cart.addToCart(product, 1); Scaffold.of(context).openEndDrawer(); }, style: ElevatedButton.styleFrom(backgroundColor: teal, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: const Text('ADD TO CART', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))]),
            ),
          ],
        ),
      ),
    );
  }
}
