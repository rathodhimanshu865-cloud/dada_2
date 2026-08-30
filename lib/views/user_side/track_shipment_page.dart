import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../../utils/app_typography.dart';
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
          _error = "No order found with this ID.";
        }
      });
    } catch (e) {
      setState(() => _error = "An error occurred while tracking.");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);

    return ProductCartLayout(
      controller: homeController,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchSection(),
                        if (_isSearching)
                          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                        else if (_error != null)
                          _buildErrorView()
                        else if (_trackedOrder != null)
                          _buildOrderDetailsCard(_trackedOrder!)
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 24, color: primaryTeal),
          const SizedBox(width: 12),
          Text('Official Order Tracker', style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 24, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LOOKUP BY ORDER ID:', style: AppTypography.bodyStyle(context, fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: TextField(
                  controller: _trackingController,
                  onSubmitted: (_) => _handleTrack(),
                  decoration: const InputDecoration(
                    hintText: 'e.g. DADA-1724773821',
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _handleTrack,
              style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
              child: const Text('TRACK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.track_changes, size: 64, color: Colors.grey.shade200),
            const SizedBox(height: 20),
            Text('Enter your Order ID above to see live status.', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
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
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(OrderModel order) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(order.orderId, style: AppTypography.headingStyle(context, fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 12),
                          _statusBadge(order.orderStatus),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Placed on ${order.createdAt != null ? DateFormat('dd MMM yyyy').format(order.createdAt!) : 'Recent'}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('TOTAL PAID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SHIPPING PARTNER & TRACKING ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text('${order.trackingCarrier}: ${order.trackingId}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              _buildTrackingStepper(order.orderStatus),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _infoBox('Shipping Destination:', Icons.location_on_outlined, Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('${order.address}, ${order.city}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                        Text('${order.state} - ${order.pincode}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      ],
                    )),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _infoBox('Sacred Items:', Icons.layers_outlined, Column(
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

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Delivered') color = Colors.green;
    if (status == 'Cancelled') color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildTrackingStepper(String status) {
    int currentIdx = 0;
    if (status == 'Pending') currentIdx = 0;
    else if (status == 'Confirmed') currentIdx = 1;
    else if (status == 'Processing') currentIdx = 2;
    else if (status == 'Shipped') currentIdx = 3;
    else if (status == 'Delivered') currentIdx = 4;
    else if (status == 'Cancelled') currentIdx = -1;

    return Row(
      children: [
        _stepperNode(1, 'Order Placed', isCompleted: currentIdx >= 0),
        _stepperConnector(isCompleted: currentIdx >= 1),
        _stepperNode(2, 'Processing', isCompleted: currentIdx >= 2),
        _stepperConnector(isCompleted: currentIdx >= 3),
        _stepperNode(3, 'Shipped', isCompleted: currentIdx >= 3),
        _stepperConnector(isCompleted: currentIdx >= 4),
        _stepperNode(4, 'Delivered', isCompleted: currentIdx >= 4),
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
