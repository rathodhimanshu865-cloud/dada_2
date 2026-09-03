import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../../utils/app_typography.dart';
import '../../utils/invoice_helper.dart';
import '../../utils/site_interactions.dart';
import 'sections/product_cart_layout.dart';

class TrackShipmentPage extends StatefulWidget {
  const TrackShipmentPage({super.key});

  @override
  State<TrackShipmentPage> createState() => _TrackShipmentPageState();
}

class _TrackShipmentPageState extends State<TrackShipmentPage> {
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color goldAccent = const Color(0xFFC89A5B);
  final TextEditingController _trackingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  OrderModel? _trackedOrder;
  bool _isSearching = false;
  String? _error;
  bool _shakeError = false;

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
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerShake() {
    setState(() => _shakeError = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _shakeError = false);
    });
  }

  Future<void> _handleTrack() async {
    final query = _trackingController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    
    if (query.isEmpty) {
      _triggerShake();
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
      _trackedOrder = null;
    });

    try {
      final orderController = Provider.of<OrderController>(context, listen: false);
      final order = await orderController.getOrderDetails(query).first;
      
      await Future.delayed(const Duration(milliseconds: 600)); // Minimal artificial delay for smooth UX
      
      if (mounted) {
        setState(() {
          if (order != null) {
            _trackedOrder = order;
          } else {
            _error = l10n.noOrderFound;
            _triggerShake();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = l10n.trackingError;
          _triggerShake();
        });
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
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
            child: SiteCardEntrance(
              index: 0,
              reducedMotion: true,
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
                        
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: _isSearching
                            ? const SizedBox(height: 100) // Space held while button spins
                            : _error != null
                              ? _buildErrorView()
                              : _trackedOrder != null
                                ? _buildOrderDetailsCard(_trackedOrder!, isMobile)
                                : _buildEmptyState(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        border: Border.all(color: goldAccent.withOpacity(0.1)),
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
          _AnimatedShake(
            shake: _shakeError,
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _AnimatedTrackingInput(
                    controller: _trackingController,
                    focusNode: _focusNode,
                    hintText: l10n.enterOrderIdHint,
                    onSubmitted: (_) => _handleTrack(),
                    goldAccent: goldAccent,
                    hasError: _error != null,
                  ),
                ),
                if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),
                _MorphingTrackButton(
                  isSearching: _isSearching,
                  onPressed: _handleTrack,
                  primaryTeal: primaryTeal,
                  text: l10n.trackNow,
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
          if (_error != null)
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              from: 10,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(height: 12),
          Text(l10n.findOrderIdDesc, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
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
      ),
    );
  }

  Widget _buildErrorView() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 20),
              Text("Order Not Found", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text("Please check the ID and try again.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(OrderModel order, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    
    // Total animation time for timeline is roughly (4 nodes * 200ms) = 800ms. 
    // We delay the details card by 1000ms.
    
    return Column(
      children: [
        const SizedBox(height: 40),
        SiteOrderTimeline(status: order.orderStatus, isMobile: isMobile),
        const SizedBox(height: 40),
        
        SiteCardEntrance(
          index: 1,
          reducedMotion: true,
          child: Container(
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
                        Text('â‚¹${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  children: [
                    Expanded(
                      child: SiteElevatedButton(
                        onPressed: () => InvoiceHelper.generateAndShowInvoice(order),
                        enableHoverLift: false,
                        backgroundColor: primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.print, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(l10n.printInvoice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                          ],
                        ),
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
                              Text('â‚¹${item['price']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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



class _AnimatedTrackingInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final Function(String) onSubmitted;
  final Color goldAccent;
  final bool hasError;

  const _AnimatedTrackingInput({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onSubmitted,
    required this.goldAccent,
    required this.hasError,
  });

  @override
  State<_AnimatedTrackingInput> createState() => _AnimatedTrackingInputState();
}

class _AnimatedTrackingInputState extends State<_AnimatedTrackingInput> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isFloating = _isFocused || widget.controller.text.isNotEmpty;
    final Color borderColor = widget.hasError 
      ? Colors.redAccent 
      : (_isFocused ? widget.goldAccent : Colors.grey.shade300);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: _isFocused ? 2 : 1),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: isFloating ? 8 : 20,
            left: 20,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: widget.hasError ? Colors.redAccent : (_isFocused ? widget.goldAccent : Colors.grey.shade500),
                fontSize: isFloating ? 10 : 14,
                fontWeight: isFloating ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(widget.hintText),
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0, top: isFloating ? 15 : 0,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onSubmitted: widget.onSubmitted,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MorphingTrackButton extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onPressed;
  final Color primaryTeal;
  final String text;
  final bool isMobile;

  const _MorphingTrackButton({
    required this.isSearching,
    required this.onPressed,
    required this.primaryTeal,
    required this.text,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: isSearching ? 60 : (isMobile ? double.infinity : 160),
      height: 60,
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(isSearching ? 30 : 8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSearching ? null : onPressed,
          borderRadius: BorderRadius.circular(isSearching ? 30 : 8),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isSearching
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedShake extends StatefulWidget {
  final Widget child;
  final bool shake;

  const _AnimatedShake({required this.child, required this.shake});

  @override
  State<_AnimatedShake> createState() => _AnimatedShakeState();
}

class _AnimatedShakeState extends State<_AnimatedShake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(covariant _AnimatedShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // 3 cycles of shake
        final dx = sin(_animation.value * pi * 6) * 4;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

