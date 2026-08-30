import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../../utils/invoice_helper.dart';

class OrderDispatchView extends StatefulWidget {
  const OrderDispatchView({super.key});

  @override
  State<OrderDispatchView> createState() => _OrderDispatchViewState();
}

class _OrderDispatchViewState extends State<OrderDispatchView> {
  String selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Provider.of<OrderController>(context);

    return StreamBuilder<List<OrderModel>>(
      stream: orderCtrl.allOrders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data ?? [];
        final filteredOrders = selectedFilter == 'ALL' 
            ? orders 
            : orders.where((o) => o.orderStatus.toUpperCase() == selectedFilter).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Orders & Consecration Dispatch', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Track devotee orders, manage shipping carriers, and generate GST invoices.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                  _buildFilterToggle(),
                ],
              ),
              const SizedBox(height: 32),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredOrders.length,
                separatorBuilder: (context, i) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  return _buildOrderCard(context, filteredOrders[i], orderCtrl);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterToggle() {
    final filters = ['ALL', 'PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: filters.map((f) => InkWell(
          onTap: () => setState(() => selectedFilter = f),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selectedFilter == f ? const Color(0xFF8B4513) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selectedFilter == f ? Colors.white : Colors.grey.shade600)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, OrderController orderCtrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory_2_outlined, color: Colors.amber, size: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(order.orderId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(4)),
                          child: Text(order.orderStatus.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.teal)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Placed on ${order.createdAt != null ? DateFormat('dd MMM yyyy').format(order.createdAt!) : 'N/A'} • Payment: ${order.paymentMethod} (${order.paymentStatus})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: order.orderStatus,
                    underline: const SizedBox(),
                    items: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) orderCtrl.updateOrder(order.copyWith(orderStatus: val));
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          
          // Order Items
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: order.items.map((item) => Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(item['imageUrl'] ?? '', width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 40, color: Colors.grey))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['productName'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Qty: ${item['quantity']} × ₹${item['price']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('${order.address}, ${order.city}, ${order.state} - ${order.pincode} (${order.phone})', style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'DTDC Express / Blue Dart: DADA-ID-123',
                          hintStyle: const TextStyle(fontSize: 11),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                        controller: TextEditingController(text: order.trackingId != null ? '${order.trackingCarrier}: ${order.trackingId}' : ''),
                        onSubmitted: (val) {
                          final parts = val.split(':');
                          if (parts.length == 2) {
                            orderCtrl.updateOrder(order.copyWith(trackingCarrier: parts[0].trim(), trackingId: parts[1].trim()));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {}, 
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87, elevation: 0),
                      child: const Text('Update Tracking', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => InvoiceHelper.generateAndShowInvoice(order),
                icon: const Icon(Icons.print, size: 16),
                label: const Text('PRINT INVOICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4513), foregroundColor: Colors.white, elevation: 0),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => InvoiceHelper.shareInvoiceWhatsApp(order),
                icon: const Icon(Icons.share, color: Colors.teal),
                tooltip: 'Share on WhatsApp',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
