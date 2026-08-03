import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../utils/app_typography.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  final Color _teal = const Color(0xFF0F4C5C);
  final Color _gold = const Color(0xFFC19A6B);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context);
    final home = Provider.of<HomePageController>(context);
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return UserPageLayout(
      controller: home,
      child: Column(
        children: [
          const SizedBox(height: 120),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOUR SHOPPING CART', style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.bold, color: _teal)),
                    const SizedBox(height: 40),
                    if (cart.items.isEmpty)
                      _buildEmptyCart(context)
                    else
                      isMobile ? _buildMobileCart(context, cart) : _buildDesktopCart(context, cart),
                  ],
                ),
              ),
            ),
          ),
          UserFooter(controller: home),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            style: ElevatedButton.styleFrom(backgroundColor: _teal, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
            child: const Text('BROWSE PRODUCTS'),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCart(BuildContext context, CartController cart) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: cart.items.values.map((item) => _CartItemRow(item: item)).toList(),
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: _OrderSummary(cart: cart),
        ),
      ],
    );
  }

  Widget _buildMobileCart(BuildContext context, CartController cart) {
    return Column(
      children: [
        ...cart.items.values.map((item) => _CartItemRow(item: item)).toList(),
        const SizedBox(height: 40),
        _OrderSummary(cart: cart),
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final dynamic item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE9E4DE)))),
      child: Row(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(item.product.images.isNotEmpty ? item.product.images.first : '', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F4C5C))),
                const SizedBox(height: 8),
                Text('₹${item.product.price}', style: const TextStyle(color: Color(0xFFC19A6B), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              _qtyBtn(Icons.remove, () => cart.updateQuantity(item.product.id, item.quantity - 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _qtyBtn(Icons.add, () => cart.updateQuantity(item.product.id, item.quantity + 1)),
            ],
          ),
          const SizedBox(width: 40),
          Text('₹${item.total}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 24),
          IconButton(onPressed: () => cart.removeFromCart(item.product.id), icon: const Icon(Icons.close, color: Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartController cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFFFAF8F4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9E4DE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ORDER SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 24),
          _row('Subtotal', '₹${cart.subtotal}'),
          _row('Shipping', 'Calculated at checkout'),
          const Divider(height: 40),
          _row('Total', '₹${cart.subtotal}', isTotal: true),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/checkout'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 60)),
            child: const Text('PROCEED TO CHECKOUT'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.bold, fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}
