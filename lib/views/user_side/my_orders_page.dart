import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';
import 'package:intl/intl.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final orderController = Provider.of<OrderController>(context);
    final Color primaryTeal = const Color(0xFF0F4C5C);

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
                  'Your Sacred Orders',
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Track your divine collections and blessings history.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                const SizedBox(height: 40),
                StreamBuilder<List<OrderModel>>(
                  stream: orderController.userOrders,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorState(context, orderController);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()));
                    }
                    
                    final orders = snapshot.data ?? [];
                    
                    if (orders.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 24),
                      itemBuilder: (context, index) => _buildOrderCard(context, orders[index]),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, OrderController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(80),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
          const SizedBox(height: 24),
          const Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('We could not load your orders. Please try again.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => controller.clearError(), // This will trigger a rebuild and retry
            child: const Text('RETRY'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(80),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text('No orders yet', style: AppTypography.bodyStyle(context, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('You haven\'t placed any sacred orders yet.', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/catalogue'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
            child: const Text('EXPLORE CATALOGUE'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final Color primaryTeal = const Color(0xFF0F4C5C);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORDER ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DATE PLACED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(order.createdAt != null ? DateFormat('dd MMM yyyy').format(order.createdAt!) : 'Recent', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Spacer(),
                _buildStatusBadge(order.orderStatus),
              ],
            ),
          ),
          // Order Items Preview
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade100)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item['imageUrl'].toString().isNotEmpty 
                            ? Image.network(item['imageUrl'], fit: BoxFit.cover)
                            : const Icon(Icons.image_outlined, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('Quantity: ${item['quantity']} • Price: ₹${item['price']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                if (order.items.length > 2)
                  Text('+ ${order.items.length - 2} more items', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                const Divider(height: 40),
                if (order.trackingId != null && order.trackingId!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TRACKING INFORMATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Text('${order.trackingCarrier}: ${order.trackingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL AMOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    Text('₹ ${order.totalAmount.toStringAsFixed(2)}', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 20, color: primaryTeal)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/track', arguments: order.orderId);
                        },
                        icon: const Icon(Icons.track_changes, size: 16),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        label: const Text('TRACK ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                           _showOrderDetails(context, order);
                        },
                        icon: const Icon(Icons.description_outlined, size: 16),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: primaryTeal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        label: Text('VIEW DETAILS', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Delivered') color = Colors.green;
    if (status == 'Cancelled') color = Colors.red;
    if (status == 'Shipped') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 40),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Status', order.orderStatus, isBold: true),
                    if (order.trackingId != null && order.trackingId!.isNotEmpty)
                       _infoRow('Tracking', '${order.trackingCarrier}: ${order.trackingId}', isBold: true, color: Colors.blue),
                    _infoRow('Payment', '${order.paymentMethod} (${order.paymentStatus})'),
                    _infoRow('Delivery Address', '${order.customerName}\n${order.address}, ${order.city}, ${order.state} - ${order.pincode}'),
                    const SizedBox(height: 30),
                    const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    ...order.items.map((item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item['productName']),
                      subtitle: Text('Qty: ${item['quantity']}'),
                      trailing: Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                    )),
                    const Divider(height: 40),
                    _summaryRow('Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
                    _summaryRow('Shipping', '₹${order.deliveryCharge.toStringAsFixed(2)}'),
                    _summaryRow('Tax', '₹${order.tax.toStringAsFixed(2)}'),
                    const Divider(),
                    _summaryRow('Total', '₹${order.totalAmount.toStringAsFixed(2)}', isBold: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
