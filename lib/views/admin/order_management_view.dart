import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/notification_controller.dart';
import '../../repositories/order_repository.dart';
import '../../models/order_model.dart';
import '../../utils/app_typography.dart';
import 'package:intl/intl.dart';

class OrderManagementView extends StatefulWidget {
  const OrderManagementView({super.key});

  @override
  State<OrderManagementView> createState() => _OrderManagementViewState();
}

class _OrderManagementViewState extends State<OrderManagementView> {
  final OrderRepository _repository = OrderRepository();
  final Color primaryTeal = const Color(0xFF0F4C5C);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orders & Consecration Management', 
          style: AppTypography.headingStyle(context, fontSize: 28, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 10),
        const Text('Manage devotee orders, update dispatch status, and handle sacred item consecration flow.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 40),
        StreamBuilder<List<OrderModel>>(
          stream: _repository.getAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final orders = snapshot.data ?? [];
            if (orders.isEmpty) {
              return const Center(child: Text('No orders found in the system.'));
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) => _buildAdminOrderCard(orders[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdminOrderCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Placed by ${order.customerName} on ${order.createdAt != null ? DateFormat('dd MMM yyyy HH:mm').format(order.createdAt!) : 'Recent'}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              _buildStatusDropdown(order),
            ],
          ),
          const Divider(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('• ${item['quantity']}x ${item['productName']} (₹${item['price']})', style: const TextStyle(fontSize: 13)),
                    )),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DELIVERY ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text(order.address, style: const TextStyle(fontSize: 13)),
                    Text('${order.city}, ${order.state} - ${order.pincode}', style: const TextStyle(fontSize: 13)),
                    Text('Phone: ${order.phone}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text('₹${order.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTeal)),
                    Text(order.paymentMethod, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(OrderModel order) {
    final statuses = ['Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(order.orderStatus).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(order.orderStatus).withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statuses.contains(order.orderStatus) ? order.orderStatus : 'Pending',
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: _getStatusColor(order.orderStatus)),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(order.orderStatus)),
          items: statuses.map((String s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
          onChanged: (newStatus) async {
            if (newStatus != null) {
              await _repository.updateOrderStatus(order.orderId, newStatus);
              
              // Send Notification
              if (mounted) {
                await Provider.of<NotificationController>(context, listen: false)
                    .sendOrderNotification(
                  userId: order.userId,
                  orderId: order.orderId,
                  status: newStatus,
                );
              }
            }
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.green;
      case 'Shipped': return Colors.blue;
      case 'Cancelled': return Colors.red;
      case 'Processing': return Colors.orange;
      case 'Confirmed': return Colors.teal;
      default: return Colors.grey;
    }
  }
}
