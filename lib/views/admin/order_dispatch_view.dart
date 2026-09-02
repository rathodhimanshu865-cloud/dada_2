import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dada_2/l10n/app_localizations.dart';
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
                      Text(AppLocalizations.of(context)!.ordersConsecrationDispatch, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(AppLocalizations.of(context)!.trackDevoteeOrders, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                  _buildFilterToggle(context),
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

  Widget _buildFilterToggle(BuildContext context) {
    final filters = [
      {'label': AppLocalizations.of(context)!.allFilter, 'value': 'ALL'},
      {'label': AppLocalizations.of(context)!.pendingFilter, 'value': 'PENDING'},
      {'label': AppLocalizations.of(context)!.processingFilter, 'value': 'PROCESSING'},
      {'label': AppLocalizations.of(context)!.shippedFilter, 'value': 'SHIPPED'},
      {'label': AppLocalizations.of(context)!.deliveredFilter, 'value': 'DELIVERED'},
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: filters.map((f) => InkWell(
          onTap: () => setState(() => selectedFilter = f['value']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selectedFilter == f['value'] ? const Color(0xFF8B4513) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(f['label']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selectedFilter == f['value'] ? Colors.white : Colors.grey.shade600)),
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
                    Text('${AppLocalizations.of(context)!.placedOnDate(order.createdAt != null ? DateFormat('dd MMM yyyy').format(order.createdAt!) : 'N/A')} • ${AppLocalizations.of(context)!.paymentStatusPrefix(order.paymentMethod, order.paymentStatus)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _priceBubble('${AppLocalizations.of(context)!.subtotal}: ₹${order.subtotal.toInt()}', Colors.grey),
                      if (order.discount > 0) _priceBubble('${AppLocalizations.of(context)!.discount}: -₹${order.discount.toInt()}', Colors.green),
                      _priceBubble('${AppLocalizations.of(context)!.tax}: ₹${order.tax.toInt()}', Colors.blueGrey),
                      _priceBubble(AppLocalizations.of(context)!.netReceived(order.totalAmount.toInt()), const Color(0xFF0F4C5C)),
                    ],
                  ),
                  const SizedBox(height: 8),
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
          if (order.couponCode != null)
            Padding(
              padding: const EdgeInsets.only(left: 60, top: 8),
              child: Text(AppLocalizations.of(context)!.couponAppliedLabel(order.couponCode!), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
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
                        Text(AppLocalizations.of(context)!.qtyTimesPrice(item['quantity'], item['price']), style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                child: _TrackingUpdateField(order: order, orderCtrl: orderCtrl),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => InvoiceHelper.generateAndShowInvoice(order),
                icon: const Icon(Icons.print, size: 16),
                label: Text(AppLocalizations.of(context)!.printInvoice, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4513), foregroundColor: Colors.white, elevation: 0),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => InvoiceHelper.shareInvoiceOnWhatsApp(order),
                icon: const Icon(Icons.share, color: Colors.teal),
                tooltip: AppLocalizations.of(context)!.shareWhatsAppTooltip,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _priceBubble(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _TrackingUpdateField extends StatefulWidget {
  final OrderModel order;
  final OrderController orderCtrl;
  const _TrackingUpdateField({required this.order, required this.orderCtrl});

  @override
  State<_TrackingUpdateField> createState() => _TrackingUpdateFieldState();
}

class _TrackingUpdateFieldState extends State<_TrackingUpdateField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.order.trackingId != null ? '${widget.order.trackingCarrier}: ${widget.order.trackingId}' : '');
  }

  @override
  void didUpdateWidget(_TrackingUpdateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.order.trackingId != oldWidget.order.trackingId) {
      _ctrl.text = widget.order.trackingId != null ? '${widget.order.trackingCarrier}: ${widget.order.trackingId}' : '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _update() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    
    final parts = val.split(':');
    if (parts.length == 2) {
      widget.orderCtrl.updateOrder(widget.order.copyWith(
        trackingCarrier: parts[0].trim(), 
        trackingId: parts[1].trim()
      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.trackingUpdated), behavior: SnackBarBehavior.floating));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.invalidTrackingFormat), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.trackingHint,
              hintStyle: const TextStyle(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.blue.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            ),
            controller: _ctrl,
            onSubmitted: (_) => _update(),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _update, 
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87, elevation: 0),
          child: Text(AppLocalizations.of(context)!.updateTracking, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
        ),
      ],
    );
  }
}
