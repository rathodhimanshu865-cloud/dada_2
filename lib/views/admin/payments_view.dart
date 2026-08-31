import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

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
        
        double upiTotal = 0;
        double codTotal = 0;
        double cardsTotal = 0;

        for (var o in orders) {
          if (o.paymentStatus == 'Paid' || o.orderStatus == 'Delivered') {
            if (o.paymentMethod == 'UPI') {
              upiTotal += o.totalAmount;
            } else if (o.paymentMethod == 'COD') {
              codTotal += o.totalAmount;
            } else {
              cardsTotal += o.totalAmount;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payments & COD Settlement', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Reconcile UPI transfers, card gateways, and Cash on Delivery collections.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  _buildPaymentBox('UPI INSTANT TRANSFERS', '₹${upiTotal.toStringAsFixed(2)}', 'ID: dada.bhagwan@okhdfcbank', Icons.account_balance_wallet_outlined),
                  const SizedBox(width: 16),
                  _buildPaymentBox('CASH ON DELIVERY (COD)', '₹${codTotal.toStringAsFixed(2)}', 'Doorstep carrier collections', Icons.payments_outlined),
                  const SizedBox(width: 16),
                  _buildPaymentBox('ONLINE CARDS / NETBANKING', '₹${cardsTotal.toStringAsFixed(2)}', '100% Secure 256-bit Encrypted', Icons.credit_card_outlined),
                ],
              ),
              const SizedBox(height: 48),
              const Text('Recent Successful Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.where((o) => o.paymentStatus == 'Paid' || o.orderStatus == 'Delivered').length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (c, i) {
                    final paidOrders = orders.where((o) => o.paymentStatus == 'Paid' || o.orderStatus == 'Delivered').toList();
                    final o = paidOrders[i];
                    return ListTile(
                      dense: true,
                      leading: Icon(o.paymentMethod == 'COD' ? Icons.handshake_outlined : Icons.account_balance_wallet_outlined, size: 18),
                      title: Text(o.orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${o.customerName} via ${o.paymentMethod}'),
                          Text('Breakdown: ₹${o.subtotal.toInt()} (S) - ₹${o.discount.toInt()} (D) + ₹${o.tax.toInt()} (T)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${o.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                          Text(o.paymentStatus, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentBox(String title, String amount, String subtext, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
            const SizedBox(height: 16),
            Text(amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
            const SizedBox(height: 8),
            Text(subtext, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
