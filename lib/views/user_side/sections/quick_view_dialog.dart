import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_typography.dart';

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
  final List<String> _availableSizes = ['Standard Pocket Size (2 x 1.5 in)', 'Large Keyring Size (2.5 x 2 in)'];

  @override
  void initState() {
    super.initState();
    _productImages = [
      widget.product.imageUrl,
      'https://via.placeholder.com/600x800/FAF8F4/0F4C5C?text=Side+View',
      'https://via.placeholder.com/600x800/F0F0F0/0F4C5C?text=Detail+Shot',
    ];
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Bar
            _buildDialogHeader(primaryTeal, accentGold),
            const Divider(height: 1),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Images
                    Expanded(
                      flex: 4,
                      child: _buildImageSection(primaryTeal, accentGold),
                    ),
                    const SizedBox(width: 40),
                    // Right Column: Info & Actions
                    Expanded(
                      flex: 5,
                      child: _buildInfoSection(context, primaryTeal, accentGold, cartController, authController),
                    ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: teal.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: teal.withOpacity(0.1))),
            child: Text('QUICK VIEW', style: AppTypography.bodyStyle(context, color: teal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const SizedBox(width: 16),
          Text('SKU: DADA-KCH-001', style: AppTypography.bodyStyle(context, color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 24, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
                image: DecorationImage(
                  image: NetworkImage(_productImages[_selectedImageIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                ),
                child: const Text('BESTSELLER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _productImages.asMap().entries.map((e) {
            return GestureDetector(
              onTap: () => setState(() => _selectedImageIndex = e.key),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedImageIndex == e.key ? teal : Colors.grey.shade200,
                    width: 2,
                  ),
                  image: DecorationImage(image: NetworkImage(e.value), fit: BoxFit.cover),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: gold.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: gold.withOpacity(0.1))),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: gold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '100% Consecrated • Vedic Haridwar Gangajal & Puja Cleansed',
                  style: AppTypography.bodyStyle(context, fontSize: 11, fontWeight: FontWeight.w700, color: gold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Color teal, Color gold, CartController cart, AuthController auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: teal.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
          child: Text(widget.product.category.toUpperCase(), style: AppTypography.bodyStyle(context, color: teal, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 15),
        Text(widget.product.title, style: AppTypography.headingStyle(context, fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Text('Crystal Clear Acrylic with High-Definition Sacred Darshan & Heavy-Duty Golden Ring', style: AppTypography.bodyStyle(context, color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
        const SizedBox(height: 20),
        Row(
          children: [
            Row(children: List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_half, size: 18, color: gold))),
            const SizedBox(width: 10),
            Text('4.95', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(width: 6),
            Text('(218 devotee reviews)', style: AppTypography.bodyStyle(context, color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Text('₹${widget.product.price.toInt()}', style: AppTypography.headingStyle(context, fontSize: 32, color: teal, fontWeight: FontWeight.w900)),
            const SizedBox(width: 12),
            Text('₹${widget.product.originalPrice.toInt()}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey.shade400, fontSize: 18)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.green.shade100)),
              child: const Text('34% OFF', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFD1FAE5))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('In Stock (85 available) • Fast 24hr Dispatch', style: AppTypography.bodyStyle(context, color: const Color(0xFF065F46), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Color Finish Selector
        Text('Finish:', style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: _availableColors.asMap().entries.map((e) {
            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = e.key),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: e.value,
                  shape: BoxShape.circle,
                  border: Border.all(color: _selectedColorIndex == e.key ? teal : Colors.white, width: 2),
                  boxShadow: [if (_selectedColorIndex == e.key) BoxShadow(color: teal.withOpacity(0.3), blurRadius: 8)],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 25),
        // Size Selector
        Text('Size / Edition:', style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _availableSizes.asMap().entries.map((e) {
            bool sel = _selectedSizeIndex == e.key;
            return ChoiceChip(
              label: Text(e.value, style: AppTypography.bodyStyle(context, color: sel ? teal : Colors.black87, fontWeight: sel ? FontWeight.w800 : FontWeight.w600, fontSize: 13)),
              selected: sel,
              onSelected: (s) => setState(() => _selectedSizeIndex = e.key),
              backgroundColor: Colors.white,
              selectedColor: teal.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: sel ? teal : Colors.grey.shade300, width: sel ? 1.5 : 1)),
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        // Actions row
        Row(
          children: [
            _buildQuantitySelector(teal),
            const SizedBox(width: 15),
            Expanded(child: _buildAddButton(context, teal, cart)),
            const SizedBox(width: 12),
            _buildWishlistIcon(teal),
          ],
        ),
        const SizedBox(height: 15),
        _buildBuyNowButton(context, teal, gold, auth, cart),
        const SizedBox(height: 25),
        _buildDetailsLink(context, teal),
        const SizedBox(height: 30),
        _buildBottomTrustIcons(teal),
      ],
    );
  }

  Widget _buildQuantitySelector(Color teal) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8), color: const Color(0xFFF9F9F9)),
      child: Row(
        children: [
          IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 16)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$_quantity', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 16)),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, Color teal, CartController cart) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          cart.addToCart(widget.product, _quantity);
          Navigator.pop(context);
          Scaffold.of(context).openEndDrawer();
        },
        style: ElevatedButton.styleFrom(backgroundColor: teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 18),
            const SizedBox(width: 12),
            Text('ADD TO BAG • ₹${(widget.product.price * _quantity).toInt()}', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistIcon(Color teal) {
    return Consumer<ProductController>(
      builder: (context, prodCtrl, child) {
        bool liked = prodCtrl.isLiked(widget.product.id);
        return InkWell(
          onTap: () => prodCtrl.toggleLike(widget.product.id),
          child: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(border: Border.all(color: liked ? Colors.redAccent.withOpacity(0.2) : Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
            child: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.redAccent : Colors.black, size: 22),
          ),
        );
      },
    );
  }

  Widget _buildBuyNowButton(BuildContext context, Color teal, Color gold, AuthController auth, CartController cart) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (auth.isAuthenticated) {
            cart.addToCart(widget.product, _quantity);
            Navigator.pop(context);
            Navigator.pushNamed(context, '/checkout');
          } else {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/login');
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 18),
            const SizedBox(width: 8),
            Text('Buy Now with Cash on Delivery / UPI', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsLink(BuildContext context, Color teal) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/product_details');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade100),
          backgroundColor: const Color(0xFFF9F9F9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('View Complete Product Details Page', style: AppTypography.bodyStyle(context, color: Colors.grey.shade700, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTrustIcons(Color teal) {
    return Row(
      children: [
        Expanded(child: _trustMini(Icons.local_shipping_outlined, 'Cash on Delivery (COD) Eligible', teal)),
        const SizedBox(width: 20),
        Expanded(child: _trustMini(Icons.verified_user_outlined, '7-Day Replacement Guarantee', teal)),
      ],
    );
  }

  Widget _trustMini(IconData icon, String text, Color teal) {
    return Row(
      children: [
        Icon(icon, size: 16, color: teal),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
