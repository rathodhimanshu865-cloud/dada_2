import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
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
              Text(AppLocalizations.of(context)!.paymentsCodSettlement, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context)!.reconcileUpiCardCod, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  _buildPaymentBox(AppLocalizations.of(context)!.upiInstantTransfers, '₹${upiTotal.toStringAsFixed(2)}', AppLocalizations.of(context)!.upiIdSubtext, Icons.account_balance_wallet_outlined),
                  const SizedBox(width: 16),
                  _buildPaymentBox(AppLocalizations.of(context)!.codBoxTitle, '₹${codTotal.toStringAsFixed(2)}', AppLocalizations.of(context)!.codBoxSubtext, Icons.payments_outlined),
                  const SizedBox(width: 16),
                  _buildPaymentBox(AppLocalizations.of(context)!.onlineCardsBoxTitle, '₹${cardsTotal.toStringAsFixed(2)}', AppLocalizations.of(context)!.onlineCardsBoxSubtext, Icons.credit_card_outlined),
                ],
              ),
              const SizedBox(height: 48),
              Text(AppLocalizations.of(context)!.recentSuccessfulTransactions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          Text(AppLocalizations.of(context)!.paymentBreakdown(o.subtotal.toInt(), o.discount.toInt(), o.tax.toInt()), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${o.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                          Text(AppLocalizations.of(context)!.successfulStatus, style: const TextStyle(fontSize: 9, color: Colors.grey)),
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
