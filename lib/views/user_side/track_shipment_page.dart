import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/order_model.dart';
import '../../utils/app_typography.dart';
import '../../utils/invoice_helper.dart';
import 'sections/product_cart_layout.dart';
import 'package:intl/intl.dart';

class TrackShipmentPage extends StatefulWidget {
  const TrackShipmentPage({super.key});

  @override
  State<TrackShipmentPage> createState() => _TrackShipmentPageState();
}

class _TrackShipmentPageState extends State<TrackShipmentPage> {
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final TextEditingController _trackingController = TextEditingController();
  OrderModel? _trackedOrder;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? orderId = ModalRoute.of(context)?.settings.arguments as String?;
      if (orderId != null) {
        _trackingController.text = orderId;
        _handleTrack();
      }
    });
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _handleTrack() async {
    final query = _trackingController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
      _trackedOrder = null;
    });

    try {
      final orderController = Provider.of<OrderController>(context, listen: false);
      // For tracking, we listen to the stream once
      final order = await orderController.getOrderDetails(query).first;
      
      setState(() {
        if (order != null) {
          _trackedOrder = order;
        } else {
          _error = l10n.noOrderFound;
        }
      });
    } catch (e) {
      setState(() => _error = l10n.trackingError);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return ProductCartLayout(
      controller: homeController,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20, vertical: isMobile ? 20 : 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(isMobile),
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchSection(isMobile),
                        if (_isSearching)
                          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                        else if (_error != null)
                          _buildErrorView()
                        else if (_trackedOrder != null)
                          _buildOrderDetailsCard(_trackedOrder!, isMobile)
                        else
                          _buildEmptyState(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 24, color: primaryTeal),
          const SizedBox(width: 12),
          Text(l10n.officialOrderTracker, style: AppTypography.headingStyle(context, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 24, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSearchSection(bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC89A5B).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: primaryTeal, size: 20),
              const SizedBox(width: 10),
              Text(l10n.trackYourSacredOrder, style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.w900, color: primaryTeal, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: TextField(
                    controller: _trackingController,
                    onSubmitted: (_) => _handleTrack(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: l10n.enterOrderIdHint,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ),
              if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),
              SizedBox(
                width: isMobile ? double.infinity : 160,
                child: ElevatedButton(
                  onPressed: _handleTrack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal, 
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(l10n.trackNow, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.findOrderIdDesc, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.track_changes, size: 64, color: Colors.grey.shade200),
            const SizedBox(height: 20),
            Text(l10n.enterOrderIdStatusDesc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 20),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(OrderModel order, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            children: [
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(order.orderId, style: AppTypography.headingStyle(context, fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 12),
                          _statusBadge(context, order.orderStatus),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(l10n.placedOnDate(order.createdAt != null ? DateFormat('dd MMM yyyy').format(order.createdAt!) : l10n.recent), style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                  if (isMobile) const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                    children: [
                      Text(l10n.totalPaid, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
                      Text('₹${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              if (order.trackingId != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.shippingPartnerTrackingId, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Text('${order.trackingCarrier}: ${order.trackingId}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              _buildTrackingStepper(context, order.orderStatus, isMobile),
              const SizedBox(height: 40),
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => InvoiceHelper.generateAndShowInvoice(order),
                      icon: const Icon(Icons.print, size: 16),
                      label: Text(l10n.printInvoice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)),
                    ),
                  ),
                  if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => InvoiceHelper.shareToWhatsApp(order),
                      icon: const Icon(Icons.share, size: 16),
                      label: Text(l10n.shareOnWhatsApp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryTeal), foregroundColor: primaryTeal, padding: const EdgeInsets.symmetric(vertical: 20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isMobile ? 0 : 1,
                    child: _infoBox(l10n.shippingDestination, Icons.location_on_outlined, Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('${order.address}, ${order.city}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                        Text('${order.state} - ${order.pincode}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      ],
                    )),
                  ),
                  if (isMobile) const SizedBox(height: 20) else const SizedBox(width: 20),
                  Expanded(
                    flex: isMobile ? 0 : 1,
                    child: _infoBox(l10n.sacredItems, Icons.layers_outlined, Column(
                      children: order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item['quantity']}x ${item['productName']}', style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Text('₹${item['price']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )).toList(),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(statusText.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildTrackingStepper(BuildContext context, String status, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    int currentIdx = 0;
    if (status == 'Pending') currentIdx = 0;
    else if (status == 'Confirmed') currentIdx = 1;
    else if (status == 'Processing') currentIdx = 2;
    else if (status == 'Shipped') currentIdx = 3;
    else if (status == 'Delivered') currentIdx = 4;
    else if (status == 'Cancelled') currentIdx = -1;

    if (isMobile) {
      return Column(
        children: [
          _stepperNodeMobile(1, l10n.orderPlaced, isCompleted: currentIdx >= 0),
          _stepperConnectorMobile(isCompleted: currentIdx >= 1),
          _stepperNodeMobile(2, l10n.processing, isCompleted: currentIdx >= 2),
          _stepperConnectorMobile(isCompleted: currentIdx >= 3),
          _stepperNodeMobile(3, l10n.shipped, isCompleted: currentIdx >= 3),
          _stepperConnectorMobile(isCompleted: currentIdx >= 4),
          _stepperNodeMobile(4, l10n.delivered, isCompleted: currentIdx >= 4),
        ],
      );
    }

    return Row(
      children: [
        _stepperNode(1, l10n.orderPlaced, isCompleted: currentIdx >= 0),
        _stepperConnector(isCompleted: currentIdx >= 1),
        _stepperNode(2, l10n.processing, isCompleted: currentIdx >= 2),
        _stepperConnector(isCompleted: currentIdx >= 3),
        _stepperNode(3, l10n.shipped, isCompleted: currentIdx >= 3),
        _stepperConnector(isCompleted: currentIdx >= 4),
        _stepperNode(4, l10n.delivered, isCompleted: currentIdx >= 4),
      ],
    );
  }

  Widget _stepperNode(int index, String title, {bool isCompleted = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? primaryTeal : Colors.grey.shade100),
            child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : Center(child: Text('$index', style: const TextStyle(color: Colors.grey, fontSize: 10))),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _stepperConnector({required bool isCompleted}) {
    return Container(width: 30, height: 2, margin: const EdgeInsets.only(bottom: 40), color: isCompleted ? primaryTeal : Colors.grey.shade100);
  }

  Widget _stepperNodeMobile(int index, String title, {bool isCompleted = false}) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? primaryTeal : Colors.grey.shade100),
          child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 12) : Center(child: Text('$index', style: const TextStyle(color: Colors.grey, fontSize: 9))),
        ),
        const SizedBox(width: 16),
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCompleted ? Colors.black87 : Colors.grey)),
      ],
    );
  }

  Widget _stepperConnectorMobile({required bool isCompleted}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(width: 2, height: 20, margin: const EdgeInsets.only(left: 11), color: isCompleted ? primaryTeal : Colors.grey.shade100),
    );
  }

  Widget _infoBox(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 16, color: primaryTeal), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
