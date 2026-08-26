import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_typography.dart';
import 'quick_view_dialog.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool showBadge;

  const ProductCard({super.key, required this.product, this.showBadge = true});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  bool _isQuickViewOpen = false;

  void _openQuickView() async {
    if (_isQuickViewOpen) return;
    
    setState(() => _isQuickViewOpen = true);
    
    await showDialog(
      context: context,
      barrierDismissible: true, // Ensures clicking outside closes the dialog
      builder: (context) => QuickViewDialog(product: widget.product),
    );
    
    if (mounted) {
      setState(() => _isQuickViewOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: false);
    final Color primaryTeal = const Color(0xFF0F4C5C);

    return Container(
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
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Stack(
                children: [
                  // Clicking the Image now opens the Full Product Details Page
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/product_details');
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        color: Colors.grey.shade50,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade50,
                            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Quick View Button Overlay (Triggers AUTOMATICALLY on Cursor Move/Hover)
                  if (_isHovered)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: MouseRegion(
                        onEnter: (_) => _openQuickView(),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            child: Text(
                              'QUICK VIEW',
                              style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: primaryTeal),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (widget.showBadge && widget.product.isNew)
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
                      bool isLiked = prodCtrl.isLiked(widget.product.id);
                      return Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => prodCtrl.toggleLike(widget.product.id),
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
                        widget.product.category,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFC89A5B), size: 12),
                          const SizedBox(width: 4),
                          const Text('4.8 (24)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/product_details'),
                    child: Text(
                      widget.product.title,
                      style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF2B2B2B)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹ ${widget.product.price.toStringAsFixed(2)}',
                    style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 18, color: primaryTeal),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      cart.addToCart(widget.product, 1);
                      Scaffold.of(context).openEndDrawer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
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
    );
  }
}
