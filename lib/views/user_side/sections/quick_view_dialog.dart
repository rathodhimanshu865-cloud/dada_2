import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dada_2/controllers/cart_controller.dart';
import 'package:dada_2/controllers/auth_controller.dart';
import 'package:dada_2/controllers/product_controller.dart';
import 'package:dada_2/models/product_model.dart';
import 'package:dada_2/utils/app_typography.dart';

class QuickViewDialog extends StatefulWidget {
  final ProductModel product;

  const QuickViewDialog({super.key, required this.product});

  @override
  State<QuickViewDialog> createState() => _QuickViewDialogState();
}

class _QuickViewDialogState extends State<QuickViewDialog> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;

  late List<String> _productImages;
  final List<Color> _availableColors = [
    const Color(0xFFE8DCC4),
    const Color(0xFF0F4C5C),
    const Color(0xFFC89A5B),
  ];
  final List<String> _availableSizes = ['Standard Pocket Size', 'Large Keyring Size'];

  @override
  void initState() {
    super.initState();
    _productImages = widget.product.imageUrls.isNotEmpty 
      ? widget.product.imageUrls 
      : ['https://via.placeholder.com/600x800/FAF8F4/0F4C5C?text=No+Image'];
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0F4C5C);
    const Color accentGold = Color(0xFFC89A5B);
    final cartController = Provider.of<CartController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.white,
      child: Container(
        width: 1000,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(primaryTeal, accentGold),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildImageSection(primaryTeal, accentGold)),
                    const SizedBox(width: 40),
                    Expanded(flex: 5, child: _buildInfoSection(context, primaryTeal, accentGold, cartController, authController)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(Color teal, Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: teal.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: teal.withOpacity(0.1))), child: Text('QUICK VIEW', style: AppTypography.bodyStyle(context, color: teal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
          const SizedBox(width: 16),
          Text('SKU: DADA-PROD-${widget.product.id.substring(0, 4).toUpperCase()}', style: AppTypography.bodyStyle(context, color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 24, color: Colors.grey), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }

  Widget _buildImageSection(Color teal, Color gold) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 480, 
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _productImages[_selectedImageIndex],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            if (widget.product.salesCount > 50)
              Positioned(top: 20, left: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: gold, borderRadius: const BorderRadius.horizontal(right: Radius.circular(20))), child: const Text('BESTSELLER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: _productImages.asMap().entries.map((e) => GestureDetector(
            onTap: () => setState(() => _selectedImageIndex = e.key), 
            child: Container(
              margin: const EdgeInsets.only(right: 12), 
              width: 70, 
              height: 70, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), 
                border: Border.all(color: _selectedImageIndex == e.key ? teal : Colors.grey.shade200, width: 2), 
              ), 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: e.value,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            )
          )).toList()
        ),
        const SizedBox(height: 30),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: gold.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: gold.withOpacity(0.1))), child: Row(children: [Icon(Icons.auto_awesome, size: 18, color: gold), const SizedBox(width: 12), Expanded(child: Text('100% Consecrated • Vedic Haridwar Gangajal & Puja Cleansed', style: AppTypography.bodyStyle(context, fontSize: 11, fontWeight: FontWeight.w700, color: gold)))])),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Color teal, Color gold, CartController cart, AuthController auth) {
    final p = widget.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: teal.withOpacity(0.05), borderRadius: BorderRadius.circular(4)), child: Text(p.categoryId.toUpperCase(), style: AppTypography.bodyStyle(context, color: teal, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5))),
        const SizedBox(height: 15),
        Text(p.name, style: AppTypography.headingStyle(context, fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Text(p.shortSummary.isNotEmpty ? p.shortSummary : 'Sacred Consecrated spiritual offering to bring positive energy and spiritual upliftment.', style: AppTypography.bodyStyle(context, color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
        const SizedBox(height: 20),
        Row(children: [Row(children: List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_half, size: 18, color: gold))), const SizedBox(width: 10), Text(p.rating.toString(), style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(width: 6), Text('(${p.reviewCount} devotee reviews)', style: AppTypography.bodyStyle(context, color: Colors.grey.shade500, fontSize: 13))]),
        const SizedBox(height: 25),
        Row(children: [if (p.comparePrice != null) ...[Text('₹${p.price.toInt()}', style: AppTypography.headingStyle(context, fontSize: 32, color: teal, fontWeight: FontWeight.w900)), const SizedBox(width: 12), Text('₹${p.comparePrice!.toInt()}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey.shade400, fontSize: 18)), const SizedBox(width: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.green.shade100)), child: Text('${p.discountPercentage}% OFF', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 11)))] else Text('₹${p.price.toInt()}', style: AppTypography.headingStyle(context, fontSize: 32, color: teal, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: (p.isActive && p.stock > 0) ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6), border: Border.all(color: (p.isActive && p.stock > 0) ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2))), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: (p.isActive && p.stock > 0) ? const Color(0xFF10B981) : Colors.red, shape: BoxShape.circle)), const SizedBox(width: 8), Text((p.isActive && p.stock > 0) ? 'In Stock (${p.stock} available) • Fast Dispatch' : 'Out of Stock', style: AppTypography.bodyStyle(context, color: (p.isActive && p.stock > 0) ? const Color(0xFF065F46) : Colors.red.shade900, fontSize: 12, fontWeight: FontWeight.bold))])),
        const SizedBox(height: 30),
        Text('Finish:', style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: _availableColors.asMap().entries.map((e) => GestureDetector(onTap: () => setState(() => _selectedColorIndex = e.key), child: Container(margin: const EdgeInsets.only(right: 12), width: 32, height: 32, decoration: BoxDecoration(color: e.value, shape: BoxShape.circle, border: Border.all(color: _selectedColorIndex == e.key ? teal : Colors.white, width: 2), boxShadow: [if (_selectedColorIndex == e.key) BoxShadow(color: teal.withOpacity(0.3), blurRadius: 8)])))).toList()),
        const SizedBox(height: 25),
        Text('Size / Edition:', style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(spacing: 12, children: _availableSizes.asMap().entries.map((e) { bool sel = _selectedSizeIndex == e.key; return ChoiceChip(label: Text(e.value, style: AppTypography.bodyStyle(context, color: sel ? teal : Colors.black87, fontWeight: sel ? FontWeight.w800 : FontWeight.w600, fontSize: 13)), selected: sel, onSelected: (s) => setState(() => _selectedSizeIndex = e.key), backgroundColor: Colors.white, selectedColor: teal.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: sel ? teal : Colors.grey.shade300, width: sel ? 1.5 : 1)), showCheckmark: false); }).toList()),
        const SizedBox(height: 40),
        Row(children: [_buildQuantitySelector(teal), const SizedBox(width: 15), Expanded(child: _buildAddButton(context, teal, cart)), const SizedBox(width: 12), _buildWishlistIcon(teal)]),
        const SizedBox(height: 15),
        _buildBuyNowButton(context, teal, gold, auth, cart),
      ],
    );
  }

  Widget _buildQuantitySelector(Color teal) => Container(height: 55, padding: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8), color: const Color(0xFFF9F9F9)), child: Row(children: [IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 16)), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$_quantity', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w800, fontSize: 15))), IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 16))]));
  Widget _buildAddButton(BuildContext context, Color teal, CartController cart) {
    return SizedBox(height: 55, child: ElevatedButton(onPressed: (widget.product.isActive && widget.product.stock > 0) ? () { 
      if (Provider.of<AuthController>(context, listen: false).isAuthenticated) {
        cart.addToCart(widget.product, _quantity); 
        Navigator.pop(context); 
        Scaffold.of(context).openEndDrawer(); 
      } else {
        Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true);
      }
    } : null, style: ElevatedButton.styleFrom(backgroundColor: teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.shopping_bag_outlined, size: 18), const SizedBox(width: 12), Text((widget.product.isActive && widget.product.stock > 0) ? 'ADD TO BAG • ₹${(widget.product.price * _quantity).toInt()}' : 'OUT OF STOCK', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5, color: Colors.white))])));
  }
  Widget _buildWishlistIcon(Color teal) => Consumer<ProductController>(builder: (context, prodCtrl, child) { 
    bool liked = prodCtrl.isLiked(widget.product.id); 
    return InkWell(onTap: () {
      if (Provider.of<AuthController>(context, listen: false).isAuthenticated) {
        prodCtrl.toggleLike(widget.product.id);
      } else {
        Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true);
      }
    }, child: Container(height: 55, width: 55, decoration: BoxDecoration(border: Border.all(color: liked ? Colors.redAccent.withOpacity(0.2) : Colors.grey.shade200), borderRadius: BorderRadius.circular(8)), child: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.redAccent : Colors.black, size: 22))); 
  });
  Widget _buildBuyNowButton(BuildContext context, Color teal, Color gold, AuthController auth, CartController cart) => SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { if (auth.isAuthenticated) { cart.addToCart(widget.product, _quantity); Navigator.pop(context); Navigator.pushNamed(context, '/checkout'); } else { Navigator.pop(context); Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true); } }, style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.bolt, size: 18), const SizedBox(width: 8), Text('Buy Now with Cash on Delivery / UPI', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white))])));
}
