import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
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
  
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.ordersConsecrationManagement, 
          style: AppTypography.headingStyle(context, fontSize: 28, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 10),
        Text(AppLocalizations.of(context)!.manageDevoteeOrders, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchOrdersHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _selectedFilter,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                items: [
                  DropdownMenuItem(value: 'All', child: Text(AppLocalizations.of(context)!.allFilter)),
                  DropdownMenuItem(value: 'Pending', child: Text(AppLocalizations.of(context)!.pendingFilter)),
                  DropdownMenuItem(value: 'Confirmed', child: Text(AppLocalizations.of(context)!.confirmedStatus)),
                  DropdownMenuItem(value: 'Processing', child: Text(AppLocalizations.of(context)!.processingFilter)),
                  DropdownMenuItem(value: 'Shipped', child: Text(AppLocalizations.of(context)!.shippedFilter)),
                  DropdownMenuItem(value: 'Delivered', child: Text(AppLocalizations.of(context)!.deliveredFilter)),
                  DropdownMenuItem(value: 'Cancelled', child: Text(AppLocalizations.of(context)!.cancelledStatus)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        StreamBuilder<List<OrderModel>>(
          stream: _repository.getAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var orders = snapshot.data ?? [];
            
            // Apply filtering
            if (_selectedFilter != 'All') {
              orders = orders.where((order) => order.orderStatus == _selectedFilter).toList();
            }

            // Apply search
            if (_searchQuery.isNotEmpty) {
              orders = orders.where((order) {
                return order.orderId.toLowerCase().contains(_searchQuery) ||
                       order.customerName.toLowerCase().contains(_searchQuery) ||
                       order.phone.toLowerCase().contains(_searchQuery);
              }).toList();
            }

            if (orders.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noOrdersFoundCriteria));
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
                    Text(AppLocalizations.of(context)!.placedByOn(order.customerName, order.createdAt != null ? DateFormat('dd MMM yyyy HH:mm').format(order.createdAt!) : 'Recent'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              _buildStatusDropdown(context, order),
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
                    Text(AppLocalizations.of(context)!.itemsHeader, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                    Text(AppLocalizations.of(context)!.deliveryAddressHeader, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text(order.address, style: const TextStyle(fontSize: 13)),
                    Text('${order.city}, ${order.state} - ${order.pincode}', style: const TextStyle(fontSize: 13)),
                    Text(AppLocalizations.of(context)!.phonePrefix(order.phone), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppLocalizations.of(context)!.totalAmountHeader, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
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

  Widget _buildStatusDropdown(BuildContext context, OrderModel order) {
    final statuses = [
      {'label': AppLocalizations.of(context)!.pendingFilter, 'value': 'Pending'},
      {'label': AppLocalizations.of(context)!.confirmedStatus, 'value': 'Confirmed'},
      {'label': AppLocalizations.of(context)!.processingFilter, 'value': 'Processing'},
      {'label': AppLocalizations.of(context)!.shippedFilter, 'value': 'Shipped'},
      {'label': AppLocalizations.of(context)!.deliveredFilter, 'value': 'Delivered'},
      {'label': AppLocalizations.of(context)!.cancelledStatus, 'value': 'Cancelled'},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(order.orderStatus).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(order.orderStatus).withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statuses.any((s) => s['value'] == order.orderStatus) ? order.orderStatus : 'Pending',
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: _getStatusColor(order.orderStatus)),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(order.orderStatus)),
          items: statuses.map((s) => DropdownMenuItem(value: s['value'], child: Text(s['label']!.toUpperCase()))).toList(),
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
