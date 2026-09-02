import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/controllers/homepage_controller.dart';
import 'package:dada_2/controllers/order_controller.dart';
import 'package:dada_2/controllers/language_controller.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'package:dada_2/models/order_model.dart';
import 'package:dada_2/views/user_side/sections/product_cart_layout.dart';
import 'package:dada_2/utils/app_typography.dart';
import 'package:dada_2/utils/invoice_helper.dart';
import 'package:intl/intl.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final orderController = Provider.of<OrderController>(context);
    final l10n = AppLocalizations.of(context)!;
    final Color primaryTeal = const Color(0xFF0F4C5C);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return ProductCartLayout(
      controller: homeController,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 30 : 60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.yourSacredOrders,
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: isMobile ? 28 : 42,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.trackOrdersDesc,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 40),
                StreamBuilder<List<OrderModel>>(
                  stream: orderController.userOrders,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorState(context, orderController);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(100),
                          child: CircularProgressIndicator(),
                        ),
                      );
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
                      itemBuilder: (context, index) =>
                          _buildOrderCard(context, orders[index], isMobile),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 24),
          Text(
            l10n.somethingWentWrong,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.couldNotLoadOrders,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => controller.clearError(),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            l10n.noOrdersYet,
            style: AppTypography.bodyStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noOrdersPlacedDesc,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/catalogue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: Text(l10n.exploreCatalogue),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, bool isMobile) {
    final Color primaryTeal = const Color(0xFF0F4C5C);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Order Header
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderIdTitle,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderId,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: isMobile ? 12 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 40),
                if (!isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.datePlaced,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.createdAt != null
                            ? DateFormat('dd MMM yyyy').format(order.createdAt!)
                            : l10n.recent,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                if (!isMobile) const Spacer(),
                _buildStatusBadge(context, order.orderStatus, isMobile),
              ],
            ),
          ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.createdAt != null
                        ? DateFormat('dd MMM yyyy').format(order.createdAt!)
                        : l10n.recent,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  _buildStatusBadge(context, order.orderStatus, isMobile),
                ],
              ),
            ),
          // Order Items Preview
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              children: [
                ...order.items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item['imageUrl'].toString().isNotEmpty
                                  ? Image.network(item['imageUrl'], fit: BoxFit.cover)
                                  : const Icon(Icons.image_outlined, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['productName'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 13 : 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${item['quantity']} • ₹${item['price']}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                if (order.items.length > 2)
                  Text(
                    l10n.moreItems(order.items.length - 2),
                    style: TextStyle(
                      color: Colors.grey.shade50,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Divider(height: 32),
                if (order.trackingId != null && order.trackingId!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.trackingInformation,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.trackingCarrier}: ${order.trackingId}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalAmount,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '₹ ${order.totalAmount.toStringAsFixed(2)}',
                      style: AppTypography.bodyStyle(
                        context,
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 18 : 20,
                        color: primaryTeal,
                      ),
                    ),
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
                        icon: const Icon(Icons.track_changes, size: 14),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        label: Text(
                          l10n.track,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => InvoiceHelper.generateAndShowInvoice(order),
                        icon: const Icon(Icons.print, size: 14),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryTeal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        label: Text(
                          l10n.invoice,
                          style: TextStyle(
                            color: primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 10 : 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showOrderDetails(context, order),
                        icon: const Icon(Icons.visibility_outlined, size: 14),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryTeal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        label: Text(
                          l10n.view,
                          style: TextStyle(
                            color: primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 10 : 12,
                          ),
                        ),
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

  Widget _buildStatusBadge(BuildContext context, String status, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    Color color = Colors.orange;
    String statusText = status;
    
    if (status == 'Delivered') {
      color = Colors.green;
      statusText = l10n.delivered;
    } else if (status == 'Cancelled') {
      color = Colors.red;
      statusText = l10n.cancelled;
    } else if (status == 'Shipped') {
      color = Colors.blue;
      statusText = l10n.shipped;
    } else if (status == 'Placed') {
      statusText = l10n.orderPlaced;
    } else if (status == 'Processing') {
      statusText = l10n.processing;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: isMobile ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: isMobile ? 8 : 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * (isMobile ? 0.95 : 0.85),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.orderDetails,
                  style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(context, l10n.status, order.orderStatus, isBold: true),
                    if (order.trackingId != null && order.trackingId!.isNotEmpty)
                      _infoRow(
                        context,
                        l10n.tracking,
                        '${order.trackingCarrier}: ${order.trackingId}',
                        isBold: true,
                        color: Colors.blue,
                      ),
                    _infoRow(context, l10n.payment, '${order.paymentMethod} (${order.paymentStatus})'),
                    _infoRow(
                      context,
                      l10n.deliveryAddress,
                      '${order.customerName}\n${order.address}, ${order.city}, ${order.state} - ${order.pincode}',
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.items, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    ...order.items.map((item) {
                      final name = item['productName'] ?? 'Unknown Product';
                      final qty = item['quantity'] ?? 0;
                      final price = (item['price'] is num)
                          ? (item['price'] as num).toDouble()
                          : double.tryParse(item['price'].toString()) ?? 0.0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(name, style: const TextStyle(fontSize: 14)),
                        subtitle: Text('Qty: $qty', style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          '₹${(price * qty).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      );
                    }),
                    const Divider(height: 40),
                    _summaryRow(l10n.subtotal, '₹${order.subtotal.toStringAsFixed(2)}'),
                    _summaryRow(l10n.shipping, '₹${order.deliveryCharge.toStringAsFixed(2)}'),
                    _summaryRow(l10n.tax, '₹${order.tax.toStringAsFixed(2)}'),
                    const Divider(),
                    _summaryRow(l10n.total, '₹${order.totalAmount.toStringAsFixed(2)}', isBold: true),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => InvoiceHelper.generateAndShowInvoice(order),
                            icon: const Icon(Icons.print),
                            label: Text(l10n.printInvoice),
                            style:
                                ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => InvoiceHelper.shareToWhatsApp(order),
                            icon: const Icon(Icons.share),
                            label: Text(l10n.shareInvoice),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
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
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
