import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/order_model.dart';
import '../../../utils/app_typography.dart';
import '../sections/user_page_layout.dart';
import '../sections/user_footer.dart';
import 'package:intl/intl.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  final Color _teal = const Color(0xFF0F4C5C);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
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
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MY ORDERS', style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.bold, color: _teal)),
                    const SizedBox(height: 40),
                    if (!auth.isAuthenticated)
                      const Center(child: Text('Please login to view your orders.'))
                    else
                      _buildOrdersList(auth.user!.uid),
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

  Widget _buildOrdersList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final orders = snapshot.data!.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('No orders found.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 24),
          itemBuilder: (context, i) => _OrderCard(order: orders[i]),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
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
                    Text('ORDER #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                _statusBadge(order.orderStatus),
              ],
            ),
            const Divider(height: 40),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.grey[100]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(item.image, fit: BoxFit.cover)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text('${item.productTitle} x ${item.quantity}', style: const TextStyle(fontSize: 14))),
                  Text('₹${item.price * item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F4C5C))),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
