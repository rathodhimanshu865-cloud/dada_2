import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../utils/app_typography.dart';
import 'package:intl/intl.dart';

class ProductManagementView extends StatefulWidget {
  const ProductManagementView({super.key});

  @override
  State<ProductManagementView> createState() => _ProductManagementViewState();
}

class _ProductManagementViewState extends State<ProductManagementView> {
  int _selectedSubMenu = 0; 
  // 0: Dashboard, 1: Products, 2: Categories, 3: Inventory, 4: Orders, 5: Payments, 6: Users, 7: Coupons, 8: Reviews, 9: Settings

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color templeGold = const Color(0xFFC89A5B);
  final Color bgCream = const Color(0xFFFDFBF7);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgCream,
      child: Column(
        children: [
          _buildTopBrandingBar(),
          Expanded(
            child: Row(
              children: [
                _buildNestedSidebar(),
                Expanded(
                  child: _buildSubContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBrandingBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_mosaic, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pu. Jignesh Dada Admin',
                        style: AppTypography.headingStyle(context, fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: templeGold.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('V3.0', style: TextStyle(color: templeGold, fontSize: 9, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  Text(
                    'Sacred Catalog Management',
                    style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/product'),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('Public Store', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(foregroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 12)),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _selectedSubMenu = 1),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add Item', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: templeGold, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNestedSidebar() {
    final items = [
      {'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'title': 'Products', 'icon': Icons.inventory_2_outlined, 'count': '27'},
      {'title': 'Categories', 'icon': Icons.category_outlined, 'count': '8'},
      {'title': 'Inventory', 'icon': Icons.analytics_outlined},
      {'title': 'Orders', 'icon': Icons.local_shipping_outlined, 'count': '2'},
      {'title': 'Payments', 'icon': Icons.payments_outlined},
      {'title': 'Devotees', 'icon': Icons.people_outline, 'count': '5'},
      {'title': 'Coupons', 'icon': Icons.local_offer_outlined},
      {'title': 'Reviews', 'icon': Icons.star_outline},
      {'title': 'Settings', 'icon': Icons.settings_outlined},
    ];

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _buildAdminProfileSnippet(),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                bool isSelected = _selectedSubMenu == i;
                return InkWell(
                  onTap: () => setState(() => _selectedSubMenu = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryTeal.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: isSelected ? primaryTeal : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['title'] as String,
                            style: AppTypography.bodyStyle(context, 
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? primaryTeal : Colors.black87,
                              fontSize: 13),
                          ),
                        ),
                        if (item.containsKey('count'))
                          Text(
                            item['count'] as String,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? primaryTeal : Colors.grey),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfileSnippet() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: templeGold.withOpacity(0.1),
            child: Text('HR', style: TextStyle(color: templeGold, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Panel', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Sacred Seva', style: AppTypography.bodyStyle(context, fontSize: 10, color: templeGold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubContent() {
    switch (_selectedSubMenu) {
      case 0: return _buildDevotionalDashboard();
      case 1: return _buildProductsView();
      default: return Center(child: Text('Section Coming Soon...'));
    }
  }

  Widget _buildDevotionalDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDashboardHeader(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 32),
          _buildMainGrid(),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operations Dashboard', style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Real-time overview of sacred orders and stock.', style: AppTypography.bodyStyle(context, color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 12, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text('Today: ${DateFormat('d MMM').format(DateTime.now())}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - (3 * 16)) / 4;
        if (constraints.maxWidth < 800) itemWidth = (constraints.maxWidth - 16) / 2;
        if (constraints.maxWidth < 450) itemWidth = constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard('DEVOTEE OFFERINGS', '₹2,793.42', '+18%', Icons.currency_rupee, Colors.green, itemWidth),
            _buildStatCard('TOTAL ORDERS', '4', '1 pending', Icons.shopping_bag_outlined, Colors.indigo, itemWidth),
            _buildStatCard('SACRED PRODUCTS', '27', '8 Categories', Icons.auto_awesome, templeGold, itemWidth),
            _buildStatCard('STOCK ALERTS', '0', 'Restock required', Icons.warning_amber_rounded, Colors.orange, itemWidth),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String label, String value, String sub, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 0.5), overflow: TextOverflow.ellipsis)),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(sub, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton('+ ADD PRODUCT', templeGold),
        _buildActionButton('Restock Inventory', primaryTeal.withOpacity(0.05), textColor: primaryTeal, icon: Icons.inventory_2_outlined),
        _buildActionButton('Create Coupon', primaryTeal.withOpacity(0.05), textColor: primaryTeal, icon: Icons.confirmation_number_outlined),
        _buildActionButton('Dispatch Orders', primaryTeal.withOpacity(0.05), textColor: primaryTeal, icon: Icons.local_shipping_outlined),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, {Color? textColor, IconData? icon}) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: icon != null ? Icon(icon, size: 14) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor ?? Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildMainGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRecentOrders()),
              const SizedBox(width: 24),
              Expanded(child: _buildLowStockWatch()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildRecentOrders(),
              const SizedBox(height: 24),
              _buildLowStockWatch(),
            ],
          );
        }
      }
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                TextButton(onPressed: () {}, child: Text('View All →', style: TextStyle(color: templeGold, fontWeight: FontWeight.bold, fontSize: 11))),
              ],
            ),
            const SizedBox(height: 12),
            _buildOrderRow('DADA-89661', 'PROCESSING', 'Himanshu Rathod', '₹383', Colors.orange),
            _buildOrderRow('DADA-89662', 'SHIPPED', 'Priya Sharma', '₹627', Colors.blue),
            _buildOrderRow('DADA-89663', 'DELIVERED', 'Amit Patel', '₹522', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(String id, String status, String devotee, String amt, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(status, style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                Text(devotee, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
              ],
            ),
          ),
          Text(amt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLowStockWatch() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Low Stock Watch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 40, color: Colors.green.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text('All items stocked!', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsView() {
    final prodCtrl = Provider.of<ProductController>(context);
    final products = prodCtrl.allProducts;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('SACRED CATALOG', style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 14),
                label: const Text('NEW PRODUCT', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (context, i) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = products[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(image: NetworkImage(p.imageUrl), fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                    subtitle: Text(p.category, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    trailing: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('₹${p.price}', style: TextStyle(fontWeight: FontWeight.w900, color: primaryTeal, fontSize: 13)),
                        const SizedBox(width: 12),
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
