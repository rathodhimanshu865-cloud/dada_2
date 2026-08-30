import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dada_2/controllers/product_controller.dart';
import 'package:dada_2/controllers/cart_controller.dart';
import 'package:dada_2/controllers/auth_controller.dart';
import 'package:dada_2/models/product_model.dart';
import 'package:dada_2/utils/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_quick_view.dart';

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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: false);
    final p = widget.product;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/product_details', arguments: p.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF8F4), // Light beige as per Image 3
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Area
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: p.imageUrl.isNotEmpty 
                        ? CachedNetworkImage(
                            imageUrl: p.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF07404C))),
                            errorWidget: (context, url, error) => const Icon(Icons.image_outlined, color: Colors.grey, size: 48),
                          )
                        : const Icon(Icons.image_outlined, color: Colors.grey, size: 48),
                    ),
                  ),

                  if (p.consecrationBadge.isNotEmpty)
                    Positioned(
                      top: 24, left: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFF07404C), borderRadius: BorderRadius.circular(4)),
                        child: Text(p.consecrationBadge.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ),
                    ),

                  Positioned.fill(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _isHovered ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: () => _showQuickView(context, p),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryTeal,
                            elevation: 8,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Quick View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 24, right: 24,
                    child: Consumer<ProductController>(
                      builder: (context, prodCtrl, _) {
                        bool liked = prodCtrl.isLiked(p.id);
                        return GestureDetector(
                          onTap: () {
                            if (Provider.of<AuthController>(context, listen: false).isAuthenticated) {
                              prodCtrl.toggleLike(p.id);
                            } else {
                              Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                            child: Icon(liked ? Icons.favorite : Icons.favorite_border, size: 14, color: liked ? Colors.red : Colors.black45),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),

            // 2. Info Area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFC89A5B).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(p.categoryId.toUpperCase(), style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFC89A5B), size: 12),
                          const SizedBox(width: 4),
                          Text(p.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text(' (${p.reviewCount})', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.name,
                    style: AppTypography.headingStyle(context, fontWeight: FontWeight.w700, fontSize: 18, color: const Color(0xFF07404C)),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.shortSummary,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11, height: 1.4),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('₹${p.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF07404C))),
                          if (p.comparePrice != null && p.comparePrice! > p.price) ...[
                            const SizedBox(width: 8),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: const Color(0xFF07404C), borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
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
      ),
    ),
  );
}

void _showQuickView(BuildContext context, ProductModel product) {
  showDialog(
    context: context,
    builder: (context) => ProductQuickView(product: product),
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
