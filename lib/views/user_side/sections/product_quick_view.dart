import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product_model.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/cart_controller.dart';

class ProductQuickView extends StatefulWidget {
  final ProductModel product;
  const ProductQuickView({super.key, required this.product});

  @override
  State<ProductQuickView> createState() => _ProductQuickViewState();
}

class _ProductQuickViewState extends State<ProductQuickView> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  int _selectedFinishIndex = 0;
  int _selectedSizeIndex = 0;
  final Color primaryTeal = const Color(0xFF07404C);
  final Color templeGold = const Color(0xFFC89A5B);

  final List<String> _availableFinishes = ['Glossy Crystal', 'Matte Finish', 'Premium Oak'];
  final List<String> _availableSizes = ['Standard Pocket Size (2 x 1.5 in)', 'Large Keyring Size (2.5 x 2 in)'];

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.imageUrls.isNotEmpty ? p.imageUrls : [p.imageUrl];
    final cart = Provider.of<CartController>(context, listen: false);

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 850),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFAF3E0), borderRadius: BorderRadius.circular(30)),
                    child: Text('QUICK VIEW', style: TextStyle(color: templeGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                  const SizedBox(width: 16),
                  Text('SKU: ${p.sku}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Images
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF8F4),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: images[_selectedImageIndex],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                if (p.isFeatured)
                                  Positioned(
                                    top: 16, left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: const Color(0xFFD42E2E), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('BESTSELLER', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: images.asMap().entries.map((e) => GestureDetector(
                              onTap: () => setState(() => _selectedImageIndex = e.key),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _selectedImageIndex == e.key ? primaryTeal : Colors.grey.shade200, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(imageUrl: e.value, fit: BoxFit.cover),
                                ),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(12), border: Border.all(color: templeGold.withOpacity(0.2))),
                            child: Row(
                              children: [
                                Icon(Icons.auto_awesome, color: templeGold, size: 20),
                                const SizedBox(width: 12),
                                const Expanded(child: Text('100% Consecrated • Vedic Haridwar Gangajal & Puja Cleansed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    // Right: Info
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: primaryTeal.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                              child: Text(p.categoryId.toUpperCase(), style: TextStyle(color: primaryTeal, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 12),
                            Text(p.name, style: GoogleFonts.cormorantGaramond(fontSize: 32, fontWeight: FontWeight.w700, color: primaryTeal)),
                            const SizedBox(height: 4),
                            Text(p.shortSummary, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Row(children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 14))),
                                const SizedBox(width: 8),
                                Text('${p.rating} (${p.reviewCount} devotee reviews)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text('₹${p.price.toInt()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                                const SizedBox(width: 12),
                                if (p.comparePrice != null) ...[
                                  Text('₹${p.comparePrice!.toInt()}', style: const TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(4)),
                                    child: Text('${p.discountPercentage}% OFF', style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w900)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(30)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text('In Stock (${p.stock} available) • Fast 24hr Dispatch', style: const TextStyle(color: Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text('Finish:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _variantCircle(const Color(0xFFE8E8E8), _selectedFinishIndex == 0, () => setState(() => _selectedFinishIndex = 0)),
                                _variantCircle(const Color(0xFFD4810D), _selectedFinishIndex == 1, () => setState(() => _selectedFinishIndex = 1)),
                                _variantCircle(const Color(0xFFE64A19), _selectedFinishIndex == 2, () => setState(() => _selectedFinishIndex = 2)),
                                const SizedBox(width: 12),
                                Text(_availableFinishes[_selectedFinishIndex], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text('Size / Edition:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              children: [
                                _variantChip(_availableSizes[0], _selectedSizeIndex == 0, () => setState(() => _selectedSizeIndex = 0)),
                                _variantChip(_availableSizes[1], _selectedSizeIndex == 1, () => setState(() => _selectedSizeIndex = 1)),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                _qtySelector(),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cart.addToCart(p, _quantity);
                                      Navigator.pop(context);
                                      Scaffold.of(context).openEndDrawer();
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                                        const SizedBox(width: 12),
                                        Text('ADD TO BAG • ₹${(p.price * _quantity).toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _favBtn(p.id),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5722),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text('⚡ Buy Now with Cash on Delivery / UPI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/product_details', arguments: p.id);
                                },
                                icon: const Text('View Complete Product Details Page', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                                label: const Icon(Icons.arrow_forward, size: 14, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _variantCircle(Color color, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? primaryTeal : Colors.transparent, width: 2)),
      child: Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    ),
  );

  Widget _variantChip(String label, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? primaryTeal : Colors.grey.shade200, width: selected ? 2 : 1),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? primaryTeal : Colors.black87)),
    ),
  );

  Widget _qtySelector() => Container(
    height: 58,
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 16)),
        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 16)),
      ],
    ),
  );

  Widget _favBtn(String id) => Consumer<ProductController>(
    builder: (context, prodCtrl, _) {
      bool isLiked = prodCtrl.isLiked(id);
      return GestureDetector(
        onTap: () => prodCtrl.toggleLike(id),
        child: Container(
          width: 58, height: 58,
          decoration: BoxDecoration(color: const Color(0xFFFFF1F1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFDEDE))),
          child: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFFF2D55), size: 20),
        ),
      );
    }
  );
}
