import 'package:flutter/material.dart';
import '../../utils/app_typography.dart';

class ProductManagementView extends StatefulWidget {
  const ProductManagementView({super.key});

  @override
  State<ProductManagementView> createState() => _ProductManagementViewState();
}

class _ProductManagementViewState extends State<ProductManagementView> {
  int _activeSubMenu = 0;
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color templeGold = const Color(0xFFC89A5B);
  final Color bgCream = const Color(0xFFFDFBF7);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgCream,
      child: Row(
        children: [
          // Nested Sidebar for Product Management
          _buildNestedSidebar(),
          // Main Dashboard Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: _buildActiveView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNestedSidebar() {
    final items = [
      {'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'title': 'Products', 'icon': Icons.shopping_bag_outlined, 'badge': '27'},
      {'title': 'Categories', 'icon': Icons.category_outlined, 'badge': '8'},
      {'title': 'Inventory & Stock', 'icon': Icons.inventory_2_outlined},
      {'title': 'Orders & Dispatch', 'icon': Icons.local_shipping_outlined},
      {'title': 'Payments & COD', 'icon': Icons.payments_outlined},
      {'title': 'Devotees / Users', 'icon': Icons.people_outline, 'badge': '5'},
      {'title': 'Coupons & Offers', 'icon': Icons.local_offer_outlined, 'badge': '3'},
      {'title': 'Reviews & Blessings', 'icon': Icons.star_outline},
      {'title': 'Store & Seva Settings', 'icon': Icons.settings_outlined},
    ];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0), // Matches image better than pure white
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildAdminProfile(),
          const Divider(height: 40),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                bool active = _activeSubMenu == i;
                return ListTile(
                  onTap: () => setState(() => _activeSubMenu = i),
                  leading: Icon(items[i]['icon'] as IconData, color: active ? Colors.white : Colors.grey, size: 20),
                  title: Text(
                    items[i]['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active ? Colors.white : Colors.black87,
                    ),
                  ),
                  trailing: items[i]['badge'] != null 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.2) : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                        child: Text(items[i]['badge'] as String, style: TextStyle(fontSize: 10, color: active ? Colors.white : Colors.grey)),
                      )
                    : null,
                  selected: active,
                  selectedTileColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                );
              },
            ),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildAdminProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: primaryTeal, radius: 18, child: const Text('HR', style: TextStyle(color: Colors.white, fontSize: 12))),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Himanshu Rathod', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Chief Seva Admin', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('Reset Demo Seed Data', style: TextStyle(fontSize: 11)),
        style: TextButton.styleFrom(foregroundColor: Colors.grey),
      ),
    );
  }

  Widget _buildActiveView() {
    if (_activeSubMenu == 0) return _buildDashboard();
    return Center(child: Text('Section: $_activeSubMenu coming soon'));
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(), // The top-most helpline/store header
        const SizedBox(height: 20),
        _buildAdminBanner(), // The teal "Admin Portal" bar
        const SizedBox(height: 32),
        _buildDashboardTitle(), // "Devotional Operations Dashboard"
        const SizedBox(height: 32),
        _buildStatsGrid(),
        const SizedBox(height: 24),
        _buildActionButtons(),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1000) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRecentOrders()),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildStockWatch()),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildRecentOrders(),
                  const SizedBox(height: 24),
                  _buildStockWatch(),
                ],
              );
            }
          }
        ),
      ],
    );
  }

  Widget _buildSiteHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          _siteHeaderItem(Icons.phone_in_talk_outlined, 'Helpline: +91 98765 43210'),
          const Spacer(),
          _siteHeaderItem(Icons.local_shipping_outlined, 'Track Order'),
          const SizedBox(width: 24),
          _siteHeaderItem(Icons.message_outlined, 'Whatsapp Seva'),
        ],
      ),
    );
  }

  Widget _siteHeaderItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: primaryTeal),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 11, color: primaryTeal, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAdminBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: templeGold, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.temple_hindu, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Pu. Jignesh Dada Official Admin Portal',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: const Text('SEVA V3.0', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(
                  'Inventory, Orders, Devotee Relations & Sacred Catalog Management',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.public, size: 16),
            label: const Text('Public Store', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Sacred Item', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: templeGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Devotional Operations Dashboard', 
              style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Real-time overview of sacred orders, live stock, and devotee engagement.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Today: 23 Aug 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildStatCard('DEVOTEE OFFERINGS', '₹173.95', '+18.4% this month', Icons.currency_rupee, Colors.green),
            _buildStatCard('TOTAL ORDERS', '3', '0 in consecration', Icons.receipt_long_outlined, Colors.blue),
            _buildStatCard('SACRED PRODUCTS', '27', 'Across 8 holy categories', Icons.auto_awesome_mosaic_outlined, Colors.brown),
            _buildStatCard('STOCK ATTENTION', '0', 'Requires restocking', Icons.warning_amber_rounded, Colors.orange),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String label, String value, String sub, IconData icon, Color iconColor) {
    return Container(
      width: 250, // Fixed width for alignment like in the image
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1)),
              Icon(icon, color: iconColor.withOpacity(0.5), size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(sub, style: TextStyle(fontSize: 12, color: iconColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _actionBtn('+ ADD PRODUCT', templeGold, Icons.add),
        _actionBtn('Restock Inventory', Colors.white, Icons.inventory, isOutlined: true),
        _actionBtn('Create Coupon', Colors.white, Icons.confirmation_number_outlined, isOutlined: true),
        _actionBtn('Dispatch Orders', Colors.white, Icons.local_shipping_outlined, isOutlined: true),
      ],
    );
  }

  Widget _actionBtn(String label, Color color, IconData icon, {bool isOutlined = false}) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : color,
        foregroundColor: isOutlined ? Colors.brown : Colors.white,
        elevation: 0,
        side: isOutlined ? BorderSide(color: Colors.brown.withOpacity(0.2)) : null,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildRecentOrders() {
    final orders = [
      {'id': 'DADA-2026-58107', 'status': 'DELIVERED', 'statusColor': Colors.green, 'devotee': 'Himanshu Rathod • Ahmedabad, Gujarat', 'amount': '₹173.95'},
      {'id': 'DADA-2026-34355', 'status': 'CANCELLED', 'statusColor': Colors.red, 'devotee': 'Himanshu Rathod • Ahmedabad, Gujarat', 'amount': '₹202.95'},
      {'id': 'DADA-2026-89661', 'status': 'CANCELLED', 'statusColor': Colors.red, 'devotee': 'Himanshu Rathod • Ahmedabad, Gujarat', 'amount': '₹383.67'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Devotee Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text('View All Orders (3) →', style: TextStyle(fontSize: 12, color: Colors.brown))),
            ],
          ),
          const SizedBox(height: 20),
          ...orders.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(o['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: (o['statusColor'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(o['status'] as String, style: TextStyle(color: o['statusColor'] as Color, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(o['devotee'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(o['amount'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Text('Invoice', style: TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.underline)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStockWatch() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Low Stock Watch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('0 Items', style: TextStyle(color: templeGold, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.inventory_outlined, size: 48, color: Colors.grey.shade200),
                const SizedBox(height: 16),
                const Text('No items currently low on stock.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
