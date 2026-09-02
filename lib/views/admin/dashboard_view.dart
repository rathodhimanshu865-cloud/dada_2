import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/dashboard_controller.dart';
import 'product_dialog_helper.dart';

class DashboardView extends StatefulWidget {
  final Function(int)? onMenuChange;
  const DashboardView({super.key, this.onMenuChange});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.day != _currentTime.day) {
        // Midnight transition or day change
        Provider.of<DashboardController>(context, listen: false).loadDashboardData();
      }
      if (mounted) {
        setState(() {
          _currentTime = now;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = controller.stats;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, controller),
                  const SizedBox(height: 24),
                  
                  // Analytics Grid
                  if (isWide)
                    Row(
                      children: [
                        _buildStatBox(AppLocalizations.of(context)!.revenue, '₹${stats.totalRevenue.toStringAsFixed(1)}', Icons.currency_rupee, Colors.teal),
                        const SizedBox(width: 12),
                        _buildStatBox(AppLocalizations.of(context)!.orders, stats.totalOrders.toString(), Icons.shopping_bag, Colors.indigo),
                        const SizedBox(width: 12),
                        _buildStatBox(AppLocalizations.of(context)!.products, stats.totalProducts.toString(), Icons.description, Colors.orange),
                        const SizedBox(width: 12),
                        _buildStatBox(AppLocalizations.of(context)!.lowStock, controller.lowStockProducts.length.toString(), Icons.warning, Colors.red, isAlert: controller.lowStockProducts.isNotEmpty),
                      ],
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatBox(AppLocalizations.of(context)!.revenue, '₹${stats.totalRevenue.toStringAsFixed(0)}', Icons.currency_rupee, Colors.teal),
                        _buildStatBox(AppLocalizations.of(context)!.orders, stats.totalOrders.toString(), Icons.shopping_bag, Colors.indigo),
                        _buildStatBox(AppLocalizations.of(context)!.products, stats.totalProducts.toString(), Icons.description, Colors.orange),
                        _buildStatBox(AppLocalizations.of(context)!.lowStock, controller.lowStockProducts.length.toString(), Icons.warning, Colors.red, isAlert: controller.lowStockProducts.isNotEmpty),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  // Action Buttons (Scrollable on small screens)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _smallActionBtn(context, AppLocalizations.of(context)!.addProduct, Icons.add, () => ProductDialogHelper.showProductDialog(context)),
                        const SizedBox(width: 12),
                        _smallActionBtn(context, AppLocalizations.of(context)!.restockInventory, Icons.inventory, () => widget.onMenuChange?.call(3)),
                        const SizedBox(width: 12),
                        _smallActionBtn(context, AppLocalizations.of(context)!.discountCoupons, Icons.confirmation_number, () => widget.onMenuChange?.call(7)),
                        const SizedBox(width: 12),
                        _smallActionBtn(context, AppLocalizations.of(context)!.viewAllOrders, Icons.list_alt, () => widget.onMenuChange?.call(4)),
                        const SizedBox(width: 12),
                        _smallActionBtn(context, AppLocalizations.of(context)!.orderDispatch, Icons.local_shipping, () => widget.onMenuChange?.call(4), isNew: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  // Recent Orders Table
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.recentOrders, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => widget.onMenuChange?.call(4), child: Text(AppLocalizations.of(context)!.viewAll, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRecentOrdersTable(controller),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DashboardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.devotionalOpsDashboard, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context)!.realTimeOverview, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C5C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(_currentTime),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('hh:mm:ss a').format(_currentTime),
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildPeriodSelector(controller),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(DashboardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: controller.selectedPeriodDays,
            underline: const SizedBox(),
            isDense: true,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
            items: [
              DropdownMenuItem(value: 1, child: Text(AppLocalizations.of(context)!.today)),
              DropdownMenuItem(value: 30, child: Text(AppLocalizations.of(context)!.thirtyDays)),
              DropdownMenuItem(value: 90, child: Text(AppLocalizations.of(context)!.threeMonths)),
              DropdownMenuItem(value: 365, child: Text(AppLocalizations.of(context)!.oneYear)),
            ],
            onChanged: (val) {
              if (val != null) controller.setPeriod(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color, {bool isAlert = false}) {
    return Expanded(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isAlert ? Colors.red.shade200 : Colors.grey.shade200, width: isAlert ? 1.5 : 1),
              boxShadow: isAlert ? [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 12),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (isAlert)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _smallActionBtn(BuildContext context, String label, IconData icon, VoidCallback onTap, {bool isNew = false}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isNew ? const Color(0xFF0F4C5C) : const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildRecentOrdersTable(DashboardController controller) {
    if (controller.recentOrders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
        child: Center(child: Text(AppLocalizations.of(context)!.noRecentOrders, style: const TextStyle(color: Colors.grey))),
      );
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentOrders.length,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (c, i) {
          final o = controller.recentOrders[i];
          return ListTile(
            dense: true,
            onTap: () => widget.onMenuChange?.call(4),
            title: Text(o.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('${o.customerName} - ${o.city}', style: const TextStyle(fontSize: 11)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${o.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(o.orderStatus, style: TextStyle(fontSize: 10, color: _getStatusColor(o.orderStatus), fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'pending': return Colors.orange;
      case 'shipped': return Colors.blue;
      default: return Colors.grey;
    }
  }
}

