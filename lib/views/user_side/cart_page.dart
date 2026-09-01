import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/coupon_controller.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final cartController = Provider.of<CartController>(context);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return ProductCartLayout(
      controller: homeController,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 30 : 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Shopping Bag',
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: isMobile ? 28 : 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F4C5C),
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 40),
                if (cartController.isLoading && cartController.items.isEmpty)
                   const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()))
                else if (cartController.errorMessage != null)
                   _buildErrorState(context, cartController)
                else if (cartController.items.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildCartContent(context, cartController, isMobile),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              'Your bag is currently empty.',
              textAlign: TextAlign.center,
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
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartController cart, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              _buildCartItemsList(context, cart, isMobile),
              const SizedBox(height: 40),
              _buildOrderSummary(context, cart, isMobile),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildCartItemsList(context, cart, isMobile)),
            const SizedBox(width: 40),
            Expanded(flex: 1, child: _buildOrderSummary(context, cart, isMobile)),
          ],
        );
      }
    );
  }

  Widget _buildCartItemsList(BuildContext context, CartController cart, bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cart.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return Container(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
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
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      width: isMobile ? 60 : 100, height: isMobile ? 60 : 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => const Icon(Icons.image_outlined, color: Colors.grey),
                    )
                  : Container(width: isMobile ? 60 : 100, height: isMobile ? 60 : 100, color: Colors.grey.shade50, child: const Icon(Icons.image_outlined)),
              ),
              SizedBox(width: isMobile ? 12 : 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 18)),
                    const SizedBox(height: 8),
                    Text('₹ ${item.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade600, fontSize: isMobile ? 12 : 14)),
                  ],
                ),
              ),
              _buildQuantitySelector(context, cart, item, isMobile),
              if(!isMobile) const SizedBox(width: 40),
              if(!isMobile) Text('₹ ${(item.price * item.quantity).toStringAsFixed(2)}', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(width: isMobile ? 8 : 20),
              IconButton(
                onPressed: () => cart.removeItem(item.productId),
                icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: isMobile ? 20 : 24),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantitySelector(BuildContext context, CartController cart, item, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () => cart.updateQuantity(item.productId, -1), icon: Icon(Icons.remove, size: isMobile ? 14 : 16), padding: isMobile ? EdgeInsets.zero : null, constraints: isMobile ? const BoxConstraints() : null),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 12),
            child: Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
          ),
          IconButton(onPressed: () => cart.updateQuantity(item.productId, 1), icon: Icon(Icons.add, size: isMobile ? 14 : 16), padding: isMobile ? EdgeInsets.zero : null, constraints: isMobile ? const BoxConstraints() : null),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartController cart, bool isMobile) {
    final Color teal = const Color(0xFF0F4C5C);
    final couponCtrl = Provider.of<CouponController>(context);

    return Column(
      children: [
        // Coupon Section
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_offer_outlined, size: 18, color: teal),
                  const SizedBox(width: 12),
                  const Text('Available Sacred Offers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),
              if (couponCtrl.isLoading) 
                const Center(child: CircularProgressIndicator())
              else if (couponCtrl.coupons.isEmpty)
                const Text('No coupons available at the moment.', style: TextStyle(fontSize: 12, color: Colors.grey))
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: couponCtrl.coupons.where((c) => c.isActive).map((c) {
                    bool isApplied = cart.appliedCoupon?.id == c.id;
                    return InkWell(
                      onTap: () async {
                        final success = await cart.applyCoupon(c);
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(cart.errorMessage ?? 'Could not apply coupon'), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                      child: Container(
                        width: isMobile ? double.infinity : 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isApplied ? const Color(0xFFFDFBF7) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isApplied ? teal : Colors.grey.shade200, width: isApplied ? 1.5 : 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(c.code, style: TextStyle(fontWeight: FontWeight.w900, color: teal, fontSize: 13, letterSpacing: 1)),
                                if (isApplied) const Icon(Icons.check_circle, color: Colors.green, size: 14),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.discountType == 'percentage' 
                                ? '${c.discountValue.toInt()}% OFF' 
                                : '₹${c.discountValue.toInt()} OFF',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(c.terms, style: TextStyle(fontSize: 9, color: Colors.grey.shade600, height: 1.3)),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isApplied ? Colors.green.shade50 : teal.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isApplied ? 'APPLIED' : 'APPLY COUPON',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isApplied ? Colors.green : teal, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (cart.appliedCoupon != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Coupon ${cart.appliedCoupon!.code} Applied Successfully!', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold))),
                    TextButton(onPressed: cart.removeCoupon, child: const Text('REMOVE', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
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
              if (cart.discountAmount > 0)
                _summaryRow('Promo Discount (${cart.appliedCoupon?.code})', '- ₹ ${cart.discountAmount.toStringAsFixed(2)}', color: Colors.green),
              _summaryRow('Shipping Seva Fee', '₹ ${cart.shippingFee.toStringAsFixed(2)}'),
              _summaryRow('Sacred Item Tax (5%)', '₹ ${cart.tax.toStringAsFixed(2)}'),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Final Total', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 18)),
                        if (cart.discountAmount > 0)
                          Text('You saved ₹${cart.discountAmount.toInt()}!', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text('₹ ${cart.total.toStringAsFixed(2)}', style: AppTypography.headingStyle(context, fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: teal)),
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
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color ?? Colors.grey.shade600, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        ],
      ),
    );
  }
}
