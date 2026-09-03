import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'package:dada_2/controllers/product_controller.dart';
import 'package:dada_2/controllers/cart_controller.dart';
import 'package:dada_2/controllers/auth_controller.dart';
import 'package:dada_2/controllers/language_controller.dart';
import 'package:dada_2/models/product_model.dart';
import 'package:dada_2/utils/app_typography.dart';
import 'package:dada_2/utils/animation_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_quick_view.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with TickerProviderStateMixin {
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color discountBrown = const Color(0xFFAD8B63);
  final Color starGold = const Color(0xFFC89A5B);
  bool _isHovered = false;
  bool _isAdded = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: false);
    final p = widget.product;
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    final isOutOfStock = p.stock <= 2;
    final hasDiscount = p.comparePrice != null && p.comparePrice! > p.price;
    final double percentOff = hasDiscount ? ((p.comparePrice! - p.price) / p.comparePrice! * 100) : 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isOutOfStock ? null : () => Navigator.pushNamed(context, '/product_details', arguments: p.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F4),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.02), 
                blurRadius: _isHovered ? 30 : 10, 
                offset: Offset(0, _isHovered ? 15 : 4)
              ),
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
                          ? AnimatedScale(
                              duration: const Duration(milliseconds: 600),
                              scale: _isHovered ? 1.08 : 1.0,
                              child: CachedNetworkImage(
                                imageUrl: p.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF07404C))),
                                errorWidget: (context, url, error) => const Icon(Icons.image_outlined, color: Colors.grey, size: 48),
                              ),
                            )
                          : const Icon(Icons.image_outlined, color: Colors.grey, size: 48),
                      ),
                    ),

                    if (isOutOfStock)
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                              child: Text(l10n.outOfStock.toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                            ),
                          ),
                        ),
                      ),

                    if (hasDiscount && !isOutOfStock)
                      Positioned(
                        top: 24, left: 24,
                        child: ElasticIn(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: const Color(0xFFC19A6B), borderRadius: BorderRadius.circular(4)),
                            child: Text("${percentOff.toInt()}% OFF", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ),

                  Positioned.fill(
                    child: Center(
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset: _isHovered ? Offset.zero : const Offset(0, 0.2),
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
                            child: Text(l10n.quickView, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ),
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: liked ? Colors.red.shade50 : Colors.white, 
                              shape: BoxShape.circle, 
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                            ),
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
                    p.localizedName(lang),
                    style: AppTypography.headingStyle(context, fontWeight: FontWeight.w700, fontSize: 18, color: const Color(0xFF07404C)),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.localizedShortSummary(lang),
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
                          if (hasDiscount) ...[
                            const SizedBox(width: 8),
                            Text('₹${p.comparePrice!.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
                          ],
                        ],
                      ),
                      _CartActionButton(
                        isAdded: _isAdded,
                        isOutOfStock: isOutOfStock,
                        onTap: () {
                          if (Provider.of<AuthController>(context, listen: false).isAuthenticated) {
                            cart.addToCart(p, 1);
                            setState(() => _isAdded = true);
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) setState(() => _isAdded = false);
                            });
                            Scaffold.of(context).openEndDrawer();
                          } else {
                            Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
}

class _CartActionButton extends StatelessWidget {
  final bool isAdded;
  final bool isOutOfStock;
  final VoidCallback onTap;

  const _CartActionButton({
    required this.isAdded,
    required this.isOutOfStock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: isAdded ? 12 : 16, vertical: 10),
        decoration: BoxDecoration(
          color: isOutOfStock 
            ? Colors.grey.shade400 
            : (isAdded ? Colors.green : const Color(0xFF07404C)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isAdded
            ? const Row(
                key: ValueKey('added'),
                children: [
                  Icon(Icons.check, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text("ADDED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              )
            : Row(
                key: const ValueKey('add'),
                children: [
                  Icon(!isOutOfStock ? Icons.shopping_bag_outlined : Icons.do_not_disturb_on_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(!isOutOfStock ? "ADD" : "SOLD", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
        ),
      ),
    );
  }
}

}
