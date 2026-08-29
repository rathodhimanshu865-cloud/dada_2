import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color discountBrown = const Color(0xFFAD8B63);
  final Color starGold = const Color(0xFFC89A5B);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: false);
    final p = widget.product;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0), 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image & Overlays Section
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                // Product Image
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/product_details', arguments: p.id),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      image: p.imageUrl.isNotEmpty 
                        ? DecorationImage(image: NetworkImage(p.imageUrl), fit: BoxFit.cover)
                        : null,
                    ),
                    child: p.imageUrl.isEmpty ? const Icon(Icons.image_outlined, color: Colors.grey, size: 48) : null,
                  ),
                ),

                // Top Left Badges
                Positioned(
                  top: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.consecrationBadge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(4)),
                          child: Text(p.consecrationBadge.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                      if (p.discountPercentage > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: discountBrown, borderRadius: BorderRadius.circular(4)),
                          child: Text('${p.discountPercentage}% OFF', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ],
                  ),
                ),

                // Top Right Actions
                Positioned(
                  top: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Consumer<ProductController>(
                        builder: (context, prodCtrl, _) {
                          bool liked = prodCtrl.isLiked(p.id);
                          return _actionCircle(
                            icon: liked ? Icons.favorite : Icons.favorite_border,
                            color: liked ? Colors.red : Colors.black38,
                            onTap: () => prodCtrl.toggleLike(p.id),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _actionCircle(
                        icon: Icons.chat_bubble_outline,
                        color: Colors.green,
                        onTap: () async {
                          final url = "https://wa.me/910000000000?text=I am interested in ${p.name}";
                          await launchUrl(Uri.parse(url));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Content Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: primaryTeal.withOpacity(0.05), borderRadius: BorderRadius.circular(4), border: Border.all(color: primaryTeal.withOpacity(0.1))),
                      child: Text(p.categoryId.toUpperCase(), style: TextStyle(color: primaryTeal, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: starGold, size: 12),
                        const SizedBox(width: 4),
                        Text(p.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        Text(' (${p.reviewCount})', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  p.name,
                  style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 14, color: const Color(0xFF2B2B2B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Short Summary
                Text(
                  p.shortSummary,
                  style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Price & Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('₹${p.price.toInt()}', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 18, color: primaryTeal)),
                        if (p.comparePrice != null && p.comparePrice! > p.price) ...[
                          const SizedBox(width: 6),
                          Text('₹${p.comparePrice!.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
                        ],
                      ],
                    ),
                    InkWell(
                      onTap: p.stock > 0 ? () {
                        cart.addToCart(p, 1);
                        Scaffold.of(context).openEndDrawer();
                      } : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryTeal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.local_mall_outlined, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCircle({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
