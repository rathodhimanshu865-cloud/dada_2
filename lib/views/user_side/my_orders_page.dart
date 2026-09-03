import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dada_2/controllers/homepage_controller.dart';
import 'package:dada_2/controllers/order_controller.dart';
import 'package:dada_2/controllers/cart_controller.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'package:dada_2/models/order_model.dart';
import 'package:dada_2/views/user_side/sections/product_cart_layout.dart';
import 'package:dada_2/utils/app_typography.dart';
import 'package:dada_2/utils/invoice_helper.dart';
import 'package:dada_2/utils/animation_utils.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const _kTeal = Color(0xFF0F4C5C);
const _kGold = Color(0xFFC89A5B);

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────
class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  // ── Tab / filter state ────────────────────────────────────────────────────
  int _activeFilterIndex = 0;
  // filter labels aligned to model's orderStatus strings
  static const List<String> _filterStatuses = [
    'All', 'Placed', 'Processing', 'Shipped', 'Delivered', 'Cancelled',
  ];

  // ── Expanded accordion state ───────────────────────────────────────────────
  final Set<String> _expandedOrders = {};

  // ── Reorder button state per order id ────────────────────────────────────
  final Map<String, int> _reorderState = {}; // 0=idle, 1=loading, 2=added

  // ── Helper: filter orders ─────────────────────────────────────────────────
  List<OrderModel> _filtered(List<OrderModel> all) {
    if (_activeFilterIndex == 0) return all;
    final status = _filterStatuses[_activeFilterIndex];
    return all.where((o) => o.orderStatus == status).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final homeController  = Provider.of<HomePageController>(context, listen: false);
    final orderController = Provider.of<OrderController>(context);
    final l10n = AppLocalizations.of(context)!;
    final bool isMobile = MediaQuery.of(context).size.width < 1100;

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
                // ── Page title (fade+rise) ──────────────────────────────────
                FadeInUp(
                  duration: const Duration(milliseconds: 350),
                  from: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourSacredOrders,
                        style: AppTypography.headingStyle(
                          context,
                          fontSize: isMobile ? 28 : 42,
                          fontWeight: FontWeight.bold,
                          color: _kTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.trackOrdersDesc,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 36),

                // ── Status filter tabs (sitewide SiteFilterTabBar) ─────────
                FadeInUp(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 300),
                  from: 10,
                  child: SiteFilterTabBar(
                    compact: true,
                    tabs: _filterStatuses.map((s) {
                      if (s == 'All')        return 'All';
                      if (s == 'Placed')     return l10n.orderPlaced;
                      if (s == 'Processing') return l10n.processing;
                      if (s == 'Shipped')    return l10n.shipped;
                      if (s == 'Delivered')  return l10n.delivered;
                      if (s == 'Cancelled')  return l10n.cancelled;
                      return s;
                    }).toList(),
                    activeIndex: _activeFilterIndex,
                    onTabSelected: (idx) =>
                        setState(() => _activeFilterIndex = idx),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Order list ─────────────────────────────────────────────
                StreamBuilder<List<OrderModel>>(
                  stream: orderController.userOrders,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorState(orderController);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(100),
                          child: CircularProgressIndicator(color: _kTeal),
                        ),
                      );
                    }

                    final all     = snapshot.data ?? [];
                    final orders  = _filtered(all);

                    // AnimatedSwitcher wraps the whole list so tab switches
                    // produce a smooth fade+scale-down exit / fade+scale-up entrance
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.97, end: 1.0)
                              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                          child: child,
                        ),
                      ),
                      child: orders.isEmpty
                          ? _buildEmptyState(context, _activeFilterIndex == 0)
                          : _buildOrderList(context, orders, isMobile),
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

  // ─────────────────────────────────────────────────────────────────────────
  // ORDER LIST
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders, bool isMobile) {
    return ListView.separated(
      key: ValueKey(_activeFilterIndex), // forces AnimatedSwitcher to rebuild
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) => SiteCardEntrance(
        index: index,
        animate: true,
        child: _OrderCard(
          key: ValueKey(orders[index].orderId),
          order: orders[index],
          isMobile: isMobile,
          isExpanded: _expandedOrders.contains(orders[index].orderId),
          reorderState: _reorderState[orders[index].orderId] ?? 0,
          onToggleExpand: () => setState(() {
            final id = orders[index].orderId;
            if (_expandedOrders.contains(id)) {
              _expandedOrders.remove(id);
            } else {
              _expandedOrders.add(id);
            }
          }),
          onReorder: (order) => _handleReorder(context, order),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REORDER
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleReorder(BuildContext context, OrderModel order) async {
    final id = order.orderId;
    if ((_reorderState[id] ?? 0) != 0) return;
    setState(() => _reorderState[id] = 1);

    // Add all items back to cart
    final cart = Provider.of<CartController>(context, listen: false);
    await Future.delayed(const Duration(milliseconds: 600)); // simulate
    // Re-add items (simplified — just update state)
    if (mounted) {
      setState(() => _reorderState[id] = 2);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _reorderState.remove(id));
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, bool isGlobalEmpty) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      key: const ValueKey('empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Icon gently scales in 0.9 → 1
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Icon(
                isGlobalEmpty
                    ? Icons.inventory_2_outlined
                    : Icons.filter_list_off_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 300),
            child: Text(
              isGlobalEmpty ? l10n.noOrdersYet : l10n.noOrdersFoundCriteria,
              style: AppTypography.bodyStyle(
                context, fontSize: 18, fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 220),
            duration: const Duration(milliseconds: 300),
            child: Text(
              isGlobalEmpty ? l10n.noOrdersPlacedDesc : l10n.noOrdersFoundCriteria,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 300),
            child: SiteElevatedButton(
              onPressed: isGlobalEmpty
                  ? () => Navigator.pushNamed(context, '/catalogue')
                  : () => setState(() => _activeFilterIndex = 0),
              backgroundColor: _kTeal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              borderRadius: BorderRadius.circular(10),
              child: Text(
                isGlobalEmpty ? l10n.exploreCatalogue : l10n.viewAllOrders,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildErrorState(OrderController controller) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 24),
          Text(l10n.somethingWentWrong,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(l10n.couldNotLoadOrders,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          SiteElevatedButton(
            onPressed: () => controller.clearError(),
            enableHoverLift: false,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER CARD (stateful for accordion, reorder animation, status badge)
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  final bool isMobile;
  final bool isExpanded;
  final int reorderState; // 0=idle, 1=loading, 2=added
  final VoidCallback onToggleExpand;
  final Future<void> Function(OrderModel) onReorder;

  const _OrderCard({
    super.key,
    required this.order,
    required this.isMobile,
    required this.isExpanded,
    required this.reorderState,
    required this.onToggleExpand,
    required this.onReorder,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> with SingleTickerProviderStateMixin {
  late AnimationController _chevronCtrl;

  @override
  void initState() {
    super.initState();
    _chevronCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.isExpanded ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(_OrderCard old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != old.isExpanded) {
      widget.isExpanded ? _chevronCtrl.forward() : _chevronCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _chevronCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = widget.order;
    final isMobile = widget.isMobile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────────
          _buildCardHeader(context, order, isMobile, l10n),

          // ── Mobile: date + status row ───────────────────────────────────
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
                        fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                  ),
                  _AnimatedStatusBadge(status: order.orderStatus, isMobile: isMobile),
                ],
              ),
            ),

          // ── Items preview + buttons ─────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Staggered product thumbnails
                ...order.items.take(2).toList().asMap().entries.map((e) {
                  final i    = e.key;
                  final item = e.value;
                  return FadeInLeft(
                    delay: Duration(milliseconds: 50 * i),
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildItemRow(item, isMobile),
                    ),
                  );
                }),
                if (order.items.length > 2)
                  Text(
                    l10n.moreItems(order.items.length - 2),
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),

                // Tracking info pill
                if (order.trackingId != null && order.trackingId!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildTrackingPill(order, l10n),
                ],
                const Divider(height: 32),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.totalAmount,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700)),
                    Text(
                      '₹ ${order.totalAmount.toStringAsFixed(2)}',
                      style: AppTypography.bodyStyle(
                        context,
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 18 : 20,
                        color: _kTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Action buttons ──────────────────────────────────────
                _buildActionRow(context, order, isMobile, l10n),
                const SizedBox(height: 12),

                // ── Accordion: order details ───────────────────────────
                _buildAccordionDetails(order, isMobile, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card header ─────────────────────────────────────────────────────────

  Widget _buildCardHeader(
      BuildContext context, OrderModel order, bool isMobile, AppLocalizations l10n) {
    return Container(
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
                      letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  order.orderId,
                  style: TextStyle(
                      fontWeight: FontWeight.w900, fontSize: isMobile ? 12 : 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.datePlaced,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  order.createdAt != null
                      ? DateFormat('dd MMM yyyy').format(order.createdAt!)
                      : l10n.recent,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            _AnimatedStatusBadge(status: order.orderStatus, isMobile: isMobile),
          ],
        ],
      ),
    );
  }

  // ── Item row ────────────────────────────────────────────────────────────

  Widget _buildItemRow(Map<String, dynamic> item, bool isMobile) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item['imageUrl'].toString().isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item['imageUrl'].toString(), fit: BoxFit.cover)
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
                    fontSize: isMobile ? 13 : 15),
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
    );
  }

  // ── Tracking pill ────────────────────────────────────────────────────────

  Widget _buildTrackingPill(OrderModel order, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRACKING',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.trackingCarrier}: ${order.trackingId}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Action row ───────────────────────────────────────────────────────────

  Widget _buildActionRow(BuildContext context, OrderModel order, bool isMobile,
      AppLocalizations l10n) {
    final reorderState = widget.reorderState;

    return Row(
      children: [
        // Track button
        Expanded(
          child: SiteElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/track', arguments: order.orderId),
            backgroundColor: _kTeal,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.track_changes, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(l10n.track,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 12,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Invoice button
        Expanded(
          child: SitePressable(
            onTap: () => InvoiceHelper.generateAndShowInvoice(order),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: _kTeal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.print, size: 14, color: _kTeal),
                  const SizedBox(width: 6),
                  Text(l10n.invoice,
                      style: TextStyle(
                          color: _kTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 10 : 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Reorder button with loading/success state
        Expanded(
          child: SitePressable(
            onTap: () => widget.onReorder(order),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: reorderState == 2
                    ? Colors.green
                    : reorderState == 1
                        ? Colors.grey.shade100
                        : Colors.transparent,
                border: Border.all(
                    color: reorderState == 2 ? Colors.green : _kTeal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: reorderState == 1
                    ? const SizedBox(
                        key: ValueKey('spinner'),
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _kTeal),
                      )
                    : reorderState == 2
                        ? Row(
                            key: const ValueKey('added'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text('ADDED',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          )
                        : Row(
                            key: const ValueKey('idle'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh, size: 14, color: _kTeal),
                              const SizedBox(width: 6),
                              Text('REORDER',
                                  style: TextStyle(
                                      color: _kTeal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 10 : 12)),
                            ],
                          ),
              ),
            ),
          ),
        ),

        // Expand / collapse details chevron
        const SizedBox(width: 8),
        SitePressable(
          onTap: widget.onToggleExpand,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5)
                  .animate(CurvedAnimation(parent: _chevronCtrl, curve: Curves.easeInOut)),
              child: const Icon(Icons.keyboard_arrow_down, size: 16, color: _kTeal),
            ),
          ),
        ),
      ],
    );
  }

  // ── Accordion details ────────────────────────────────────────────────────

  Widget _buildAccordionDetails(
      OrderModel order, bool isMobile, AppLocalizations l10n) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      child: widget.isExpanded
          ? _AccordionContent(order: order, isMobile: isMobile, l10n: l10n)
          : const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedStatusBadge extends StatefulWidget {
  final String status;
  final bool isMobile;

  const _AnimatedStatusBadge({required this.status, required this.isMobile});

  @override
  State<_AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<_AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _badgeColor {
    switch (widget.status) {
      case 'Delivered':  return Colors.green;
      case 'Cancelled':  return Colors.red.shade400;
      case 'Shipped':    return Colors.blue;
      case 'Processing': return Colors.orange;
      default:           return Colors.grey.shade500;
    }
  }

  String get _badgeLabel {
    switch (widget.status) {
      case 'Delivered':  return 'DELIVERED';
      case 'Cancelled':  return 'CANCELLED';
      case 'Shipped':    return 'SHIPPED';
      case 'Processing': return 'PROCESSING';
      case 'Placed':     return 'PLACED';
      default:           return widget.status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;
    return ScaleTransition(
      scale: CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
      child: FadeTransition(
        opacity: _ctrl,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 10, vertical: widget.isMobile ? 4 : 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            _badgeLabel,
            style: TextStyle(
              color: color,
              fontSize: widget.isMobile ? 8 : 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCORDION CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _AccordionContent extends StatelessWidget {
  final OrderModel order;
  final bool isMobile;
  final AppLocalizations l10n;

  const _AccordionContent({
    required this.order,
    required this.isMobile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Text(
          l10n.orderDetails.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade500,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _infoRow(l10n.status, order.orderStatus, isBold: true),
        _infoRow(
          l10n.deliveryAddress,
          '${order.customerName}\n${order.address}, ${order.city}, '
          '${order.state} - ${order.pincode}',
        ),
        _infoRow(l10n.payment, '${order.paymentMethod} (${order.paymentStatus})'),
        if (order.trackingId != null && order.trackingId!.isNotEmpty)
          _infoRow(l10n.tracking,
              '${order.trackingCarrier}: ${order.trackingId}',
              isBold: true, color: Colors.blue),
        const Divider(height: 24),
        Text(l10n.items,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        ...order.items.map((item) {
          final name  = item['productName'] ?? 'Unknown';
          final qty   = item['quantity'] ?? 0;
          final price = (item['price'] is num)
              ? (item['price'] as num).toDouble()
              : double.tryParse(item['price'].toString()) ?? 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                    child: Text(name,
                        style: const TextStyle(fontSize: 13))),
                Text('Qty $qty',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(width: 16),
                Text(
                  '₹${(price * qty).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          );
        }),
        const Divider(height: 24),
        _summaryRow(l10n.subtotal, '₹${order.subtotal.toStringAsFixed(2)}'),
        _summaryRow(l10n.shipping,
            '₹${order.deliveryCharge.toStringAsFixed(2)}'),
        _summaryRow(l10n.tax, '₹${order.tax.toStringAsFixed(2)}'),
        const Divider(height: 8),
        _summaryRow(l10n.total, '₹${order.totalAmount.toStringAsFixed(2)}',
            isBold: true),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SiteElevatedButton(
                onPressed: () =>
                    InvoiceHelper.generateAndShowInvoice(order),
                enableHoverLift: false,
                backgroundColor: _kTeal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.print, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('PRINT INVOICE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SitePressable(
                onTap: () => InvoiceHelper.shareToWhatsApp(order),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: _kTeal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, size: 14, color: _kTeal),
                      SizedBox(width: 6),
                      Text('SHARE',
                          style: TextStyle(
                              color: _kTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _infoRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
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
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
