import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';

class OrderManagementView extends StatefulWidget {
  const OrderManagementView({super.key});

  @override
  State<OrderManagementView> createState() => _OrderManagementViewState();
}

class _OrderManagementViewState extends State<OrderManagementView> {
  final Color _teal = const Color(0xFF0F4C5C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ORDER MANAGEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.black));

          final orders = snapshot.data!.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderAdminCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderAdminCard extends StatelessWidget {
  final OrderModel order;
  const _OrderAdminCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: ExpansionTile(
        title: Row(
          children: [
            Text('ORDER #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            _statusBadge(order.orderStatus),
            const Spacer(),
            Text('₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C5C))),
          ],
        ),
        subtitle: Text('User ID: ${order.userId} • ${DateFormat('dd MMM yyyy').format(order.createdAt)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SHIPPING INFO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(order.shippingAddress),
                Text('Phone: ${order.contactNumber}'),
                const SizedBox(height: 24),
                const Text('ITEMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...order.items.map((it) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${it.productTitle} x ${it.quantity} (₹${it.price})'),
                )),
                const Divider(height: 40),
                const Text('UPDATE STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: ['processing', 'shipped', 'delivered', 'cancelled'].map((s) => ChoiceChip(
                    label: Text(s.toUpperCase(), style: const TextStyle(fontSize: 10)),
                    selected: order.orderStatus == s,
                    onSelected: (val) {
                      if (val) {
                        FirebaseFirestore.instance.collection('orders').doc(order.id).update({'orderStatus': s});
                      }
                    },
                  )).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'delivered': color = Colors.green; break;
      case 'shipped': color = Colors.blue; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
