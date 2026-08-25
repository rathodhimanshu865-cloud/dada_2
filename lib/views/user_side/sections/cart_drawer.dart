import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/cart_controller.dart';
import '../../../utils/app_typography.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0F4C5C);
    const Color templeGold = Color(0xFFC89A5B);
    final cartController = Provider.of<CartController>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = screenWidth > 600 ? 450 : screenWidth * 0.85;

    return Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header: Icon | Title | Count | Close (Fixed at top)
            _buildHeader(context, cartController, primaryTeal),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Scrollable Content
            Expanded(
              child: cartController.items.isEmpty
                  ? _buildEmptyState(context, primaryTeal)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildShippingProgress(context, cartController, primaryTeal, templeGold),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                          _buildCartItems(context, cartController, primaryTeal),
                          _buildSummary(context, cartController, primaryTeal),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartController cart, Color teal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 22, color: teal),
          const SizedBox(width: 12),
          Text(
            'Your Shopping Bag',
            style: AppTypography.headingStyle(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${cart.totalItems}',
              style: AppTypography.bodyStyle(
                context,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: teal,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingProgress(BuildContext context, CartController cart, Color teal, Color gold) {
    double progress = (cart.subtotal / 499).clamp(0.0, 1.0);
    double remaining = 499 - cart.subtotal;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF0F4C5C)),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bodyStyle(context, fontSize: 13, color: Colors.black87),
                    children: [
                      if (cart.subtotal < 499) ...[
                        const TextSpan(text: 'Add '),
                        TextSpan(
                          text: '₹${remaining.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.w800, color: teal),
                        ),
                        const TextSpan(text: ' more for Free Express Shipping'),
                      ] else
                        const TextSpan(text: 'You have qualified for Free Express Shipping!', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(gold),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color teal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: teal.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag_outlined, size: 44, color: teal.withOpacity(0.3)),
          ),
          const SizedBox(height: 30),
          Text(
            'Your bag is empty',
            style: AppTypography.headingStyle(context, fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(height: 15),
          Text(
            'Discover handcrafted timepieces, bespoke ceramics, fine merino knitwear, and leather goods.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyStyle(context, fontSize: 14, color: Colors.grey.shade500, height: 1.6),
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/catalogue');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: Text(
                'EXPLORE CATALOG',
                style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, CartController cart, Color teal) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cart.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.product.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image_outlined, size: 20, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.product.title,
                            style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => cart.removeItem(item.product.id),
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Color: Standard • Size: Medium',
                      style: AppTypography.bodyStyle(context, fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuantityToggle(context, cart, item),
                        Text(
                          '₹${(item.product.price * item.quantity).toStringAsFixed(2)}',
                          style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityToggle(BuildContext context, CartController cart, item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => cart.updateQuantity(item.product.id, -1),
            icon: const Icon(Icons.remove, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text('${item.quantity}', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 13)),
          IconButton(
            onPressed: () => cart.updateQuantity(item.product.id, 1),
            icon: const Icon(Icons.add, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartController cart, Color teal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'PROMO CODE (E.G. DADA10)',
                      hintStyle: AppTypography.bodyStyle(context, fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Apply', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _summaryRow(context, 'Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          _summaryRow(context, 'Insured Express Shipping', '₹${cart.shippingFee.toStringAsFixed(2)}'),
          _summaryRow(context, 'Estimated Taxes (5%)', '₹${cart.tax.toStringAsFixed(2)}'),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Total', style: AppTypography.headingStyle(context, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('₹${cart.total.toStringAsFixed(2)}', style: AppTypography.headingStyle(context, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/checkout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF071C21),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('PROCEED TO SECURE CHECKOUT', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 14, color: Colors.green),
              const SizedBox(width: 8),
              Text('256-bit Encrypted SSL Guarantee', style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyStyle(context, fontSize: 14, color: Colors.grey.shade600)),
          Text(value, style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}
