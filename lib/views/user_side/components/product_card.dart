import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../controllers/cart_controller.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  bool _isInWishlist = false; // Ideally synced with a WishlistProvider

  final Color _teal = const Color(0xFF0F4C5C);
  final Color _gold = const Color(0xFFC19A6B);

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = widget.product.salePrice != null && 
                            widget.product.salePrice! < (widget.product.price ?? 0);
    final int discountPct = hasDiscount 
        ? (((widget.product.price! - widget.product.salePrice!) / widget.product.price!) * 100).round()
        : 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/products/${widget.product.slug}'),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.02),
                blurRadius: _isHovered ? 24 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Expanded(
                child: Stack(
                  children: [
                    // Product Image
                    Positioned.fill(
                      child: Image.network(
                        widget.product.images.isNotEmpty ? widget.product.images.first : 'https://via.placeholder.com/400x500',
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // Quick View Overlay
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.15),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {}, // Quick View logic
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _teal,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('QUICK VIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),

                    // Badges (Top-Left)
                    Positioned(
                      top: 12, left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.product.badges.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                widget.product.badges.first.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                          if (hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF9F3EA), borderRadius: BorderRadius.circular(4), border: Border.all(color: _gold.withOpacity(0.3))),
                              child: Text(
                                "$discountPct% OFF",
                                style: TextStyle(color: _gold, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Action Buttons (Top-Right)
                    Positioned(
                      top: 12, right: 12,
                      child: Column(
                        children: [
                          _circleIconBtn(
                            _isInWishlist ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            _isInWishlist ? Colors.red : Colors.black87,
                            () => setState(() => _isInWishlist = !_isInWishlist),
                          ),
                          const SizedBox(height: 8),
                          _circleIconBtn(Icons.chat_bubble_outline_rounded, Colors.black87, () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Details Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            widget.product.category.toUpperCase(),
                            style: TextStyle(color: Colors.grey[600], fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            const Text("4.8", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(" (24)", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      widget.product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(fontSize: 19, fontWeight: FontWeight.bold, color: _teal, height: 1),
                    ),
                    const SizedBox(height: 6),
                    
                    // Description
                    Text(
                      widget.product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    
                    // Price & Add Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹${widget.product.salePrice ?? widget.product.price}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            if (hasDiscount)
                              Text(
                                "₹${widget.product.price}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough),
                              ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<CartController>(context, listen: false).addToCart(widget.product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.product.title} added to cart'),
                                action: SnackBarAction(label: 'VIEW CART', onPressed: () => Navigator.pushNamed(context, '/cart')),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('ADD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
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

  Widget _circleIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
