import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/language_controller.dart';
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
    final bool isMobile = MediaQuery.of(context).size.width < 1100;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity, color: const Color(0xFF0F4C5C), padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 60, horizontal: 20),
      child: Column(children: [Text(l10n.yourSacredWishlist, textAlign: TextAlign.center, style: AppTypography.headingStyle(context, fontSize: isMobile ? 28 : 42, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 10), Text(l10n.sacredWishlistDesc, textAlign: TextAlign.center, style: AppTypography.bodyStyle(context, fontSize: isMobile ? 14 : 16, color: Colors.white.withOpacity(0.8)))]),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductController prod, CartController cart) {
    final wishlist = prod.wishlistProducts;
    final l10n = AppLocalizations.of(context)!;
    if (wishlist.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 100), child: Column(children: [Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300), const SizedBox(height: 24), Text(l10n.yourWishlistIsEmpty, style: AppTypography.bodyStyle(context, fontSize: 18, color: Colors.grey.shade600)), const SizedBox(height: 30), ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/catalogue'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)), child: Text(l10n.exploreCatalogue))])));
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200), 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int cols = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 700 ? 3 : 2);
              return GridView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols, 
                  childAspectRatio: 0.62, 
                  crossAxisSpacing: 20, 
                  mainAxisSpacing: 20
                ), 
                itemCount: wishlist.length, 
                itemBuilder: (context, index) => _wishlistProductCard(context, wishlist[index], prod, cart)
              );
            }
          ),
        )
      )
    );
  }

  Widget _wishlistProductCard(BuildContext context, ProductModel product, ProductController prod, CartController cart) {
    final Color teal = const Color(0xFF0F4C5C);
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.categoryId.toUpperCase(), style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 8), Text(product.localizedName(lang), style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 10), Text('₹ ${product.price.toStringAsFixed(2)}', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 18, color: teal)), const SizedBox(height: 15), ElevatedButton(onPressed: () { cart.addToCart(product, 1); Scaffold.of(context).openEndDrawer(); }, style: ElevatedButton.styleFrom(backgroundColor: teal, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: Text(l10n.addToBag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))]),
            ),
          ],
        ),
      ),
    );
  }
}
