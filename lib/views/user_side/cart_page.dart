import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/cart_controller.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final cartController = Provider.of<CartController>(context);

    return ProductCartLayout(
      controller: homeController,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Shopping Bag',
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F4C5C),
                  ),
                ),
                const SizedBox(height: 40),
                if (cartController.isLoading && cartController.items.isEmpty)
                   const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()))
                else if (cartController.errorMessage != null)
                   _buildErrorState(context, cartController)
                else if (cartController.items.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildCartContent(context, cartController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, CartController cart) {
    return Container(
      height: 400,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
          const SizedBox(height: 24),
          Text(cart.errorMessage!, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: cart.clearError, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'Your bag is currently empty.',
            style: AppTypography.bodyStyle(context, fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/catalogue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text('EXPLORE CATALOGUE'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartController cart) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              _buildCartItemsList(context, cart),
              const SizedBox(height: 40),
              _buildOrderSummary(context, cart),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildCartItemsList(context, cart)),
            const SizedBox(width: 40),
            Expanded(flex: 1, child: _buildOrderSummary(context, cart)),
          ],
        );
      }
    );
  }

  Widget _buildCartItemsList(BuildContext context, CartController cart) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cart.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl.isNotEmpty 
                  ? Image.network(item.imageUrl, width: 100, height: 100, fit: BoxFit.cover)
                  : Container(width: 100, height: 100, color: Colors.grey.shade50, child: const Icon(Icons.image_outlined)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('₹ ${item.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ),
              _buildQuantitySelector(context, cart, item),
              const SizedBox(width: 40),
              Text('₹ ${(item.price * item.quantity).toStringAsFixed(2)}', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () => cart.removeItem(item.productId),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantitySelector(BuildContext context, CartController cart, item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(onPressed: () => cart.updateQuantity(item.productId, -1), icon: const Icon(Icons.remove, size: 16)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(onPressed: () => cart.updateQuantity(item.productId, 1), icon: const Icon(Icons.add, size: 16)),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartController cart) {
    final Color teal = const Color(0xFF0F4C5C);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _summaryRow('Subtotal', '₹ ${cart.subtotal.toStringAsFixed(2)}'),
          _summaryRow('Shipping', '₹ ${cart.shippingFee.toStringAsFixed(2)}'),
          _summaryRow('Estimated Taxes (5%)', '₹ ${cart.tax.toStringAsFixed(2)}'),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 20)),
              Text('₹ ${cart.total.toStringAsFixed(2)}', style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: teal)),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              style: ElevatedButton.styleFrom(backgroundColor: teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('PROCEED TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
