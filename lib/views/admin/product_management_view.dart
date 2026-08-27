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
    if (_activeSubMenu == 1) return _buildProductsList();
    if (_activeSubMenu == 2) return _buildCategoriesGrid();
    if (_activeSubMenu == 3) return _buildInventoryStockView();
    if (_activeSubMenu == 4) return _buildOrdersDispatchView();
    if (_activeSubMenu == 5) return _buildPaymentsSettlementView();
    if (_activeSubMenu == 6) return _buildDevoteesUserView();
    if (_activeSubMenu == 7) return _buildCouponsOffersView();
    if (_activeSubMenu == 8) return _buildReviewsBlessingsView();
    if (_activeSubMenu == 9) return _buildStoreSevaSettingsView();
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

  Widget _buildProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        _buildProductsHeader(),
        const SizedBox(height: 24),
        _buildFiltersRow(),
        const SizedBox(height: 24),
        _buildProductsTable(),
      ],
    );
  }

  Widget _buildProductsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Catalog Management', 
              style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Add, edit, adjust stock, and manage sacred product listings of Pu. Dada.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        _actionBtn('+ ADD NEW PRODUCT', templeGold, Icons.add),
      ],
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by title, SKU, or keyword...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'All Categories (27)',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: ['All Categories (27)', 'Keychain', 'Acrylic Photo Frame'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTable() {
    final products = [
      {
        'name': 'Dada\'s Photo Keychain',
        'desc': 'Crystal Clear Acrylic with High-Definition Sacred Darshan & Heavy-Duty Golden Ring',
        'category': 'Keychain',
        'sku': 'DADA-KCH-001',
        'price': '₹99',
        'oldPrice': '₹149',
        'stock': 84,
        'status': 'PUBLISHED',
      },
      {
        'name': 'Mobile Keychain',
        'desc': 'Sacred Phone Charm Strap with Dual-Sided Divine Emblem & Soft Braided Cord',
        'category': 'Keychain',
        'sku': 'DADA-KCH-002',
        'price': '₹119',
        'oldPrice': '₹179',
        'stock': 59,
        'status': 'PUBLISHED',
      },
      {
        'name': 'Dada\'s Photo + Radha Krishna Photo Round Keychain',
        'desc': 'Dual-Sided 360° Rotating Golden Circular Metallic Ring with Sacred Vrindavan Darshan',
        'category': 'Keychain',
        'sku': 'DADA-KCH-003',
        'price': '₹149',
        'oldPrice': '₹229',
        'stock': 95,
        'status': 'PUBLISHED',
      },
      {
        'name': 'Dada\'s Photo + Radha Krishna Photo + Radhe Radhe Keychain',
        'desc': 'Triple-Charm Divine Devotional Set with Embossed Sacred Script & Crystal Pendants',
        'category': 'Keychain',
        'sku': 'DADA-KCH-004',
        'price': '₹179',
        'oldPrice': '₹269',
        'stock': 50,
        'status': 'PUBLISHED',
      },
      {
        'name': 'Dada and Krishna Bhagwan\'s Keychain',
        'desc': 'Golden Embossed Divine Portrait with Sacred Flute (Murli) & Peacock Feather Inlay',
        'category': 'Keychain',
        'sku': 'DADA-KCH-005',
        'price': '₹139',
        'oldPrice': '₹209',
        'stock': 70,
        'status': 'PUBLISHED',
      },
      {
        'name': 'Dada\'s Photo Acrylic Photo Frame',
        'desc': 'Crystal Clear 4mm Glossy Acrylic Altar Frame with Golden Brass Stand & Free-Standing Design',
        'category': 'Acrylic Photo Frame',
        'sku': 'DADA-FRM-001',
        'price': '₹349',
        'oldPrice': '₹499',
        'stock': 45,
        'status': 'PUBLISHED',
      },
      {
        'name': 'Radha Krishna Bhagwan Acrylic Photo Frame',
        'desc': 'Vrindavan Divine Darshan with Gold Foil Embossing & 3D Depth Acrylic Prism',
        'category': 'Acrylic Photo Frame',
        'sku': 'DADA-FRM-002',
        'price': '₹399',
        'oldPrice': '₹599',
        'stock': 55,
        'status': 'PUBLISHED',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 4, child: _tableHeaderText('PRODUCT DETAILS')),
                Expanded(flex: 2, child: _tableHeaderText('CATEGORY & SKU')),
                Expanded(flex: 1, child: _tableHeaderText('PRICE')),
                Expanded(flex: 1, child: _tableHeaderText('STOCK LEVEL')),
                Expanded(flex: 1, child: _tableHeaderText('STATUS')),
                Expanded(flex: 1, child: _tableHeaderText('ACTIONS')),
              ],
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final p = products[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    // Product Details
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image_outlined, color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text(p['desc'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Category & SKU
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['category'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(p['sku'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade400, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    // Price
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['price'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(p['oldPrice'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade400, decoration: TextDecoration.lineThrough)),
                        ],
                      ),
                    ),
                    // Stock Level
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Text('${p['stock']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(width: 8),
                          _stockControl('-'),
                          _stockControl('+'),
                        ],
                      ),
                    ),
                    // Status
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text('PUBLISHED', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // Actions
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey), onPressed: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderText(String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 0.5));
  }

  Widget _stockControl(String op) {
    return Container(
      width: 18,
      height: 18,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(op, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {
        'name': 'Keychain',
        'desc': 'High-definition acrylic & gold finished sacred pocket keychains of Pu. Dada and Sri Radha Krishna.',
        'count': '5 Products',
        'icon': Icons.vpn_key_outlined,
      },
      {
        'name': 'Acrylic Photo Frame',
        'desc': 'Diamond polished crystal acrylic desktop and car dashboard frames with consecrated darshan.',
        'count': '3 Products',
        'icon': Icons.photo_outlined,
      },
      {
        'name': 'Temple',
        'desc': 'Handcrafted teakwood & polished brass home mandirs designed for serene puja rituals.',
        'count': '2 Products',
        'icon': Icons.temple_hindu_outlined,
      },
      {
        'name': 'Footprints / Paduka',
        'desc': 'Pure brass & gold embossed sacred Charan Paduka for temple altar and cash locker blessings.',
        'count': '3 Products',
        'icon': Icons.front_hand_outlined,
      },
      {
        'name': 'Sticker',
        'desc': 'Waterproof gold metallic & 3D acrylic stickers for laptops, vehicles, journals, and doors.',
        'count': '2 Products',
        'icon': Icons.stars_outlined,
      },
      {
        'name': 'Pouch / Pocket Pin',
        'desc': 'Embroidered velvet rosary pouches and gold-plated lapel pins for spiritual grace.',
        'count': '1 Products',
        'icon': Icons.wallet_outlined,
      },
      {
        'name': 'Rakshasutra / Sacred Thread',
        'desc': 'Traditional Vedic Kalava & Raksha threads sanctified with protection mantras and Chandan.',
        'count': '1 Products',
        'icon': Icons.linear_scale_outlined,
      },
      {
        'name': 'Other Products',
        'desc': 'Illuminated 3D LED illusion lamps, handwoven Khes prayer shawls, and holy scripture granths.',
        'count': '10 Products',
        'icon': Icons.wb_incandescent_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category Management', 
                  style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('Organize Pu. Dada sacred offerings into distinct store categories.', 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
            _actionBtn('+ ADD NEW CATEGORY', templeGold, Icons.add),
          ],
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, i) => _buildCategoryCard(categories[i]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: templeGold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(cat['icon'] as IconData, color: templeGold, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: templeGold.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                child: Text(cat['count'] as String, style: TextStyle(color: templeGold, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              cat['desc'] as String, 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {}, 
                child: const Text('View Products →', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStockView() {
    final inventory = [
      {'name': 'Dada\'s Photo Keychain', 'sku': 'DADA-KCH-001', 'stock': 84, 'safety': '10 units'},
      {'name': 'Mobile Keychain', 'sku': 'DADA-KCH-002', 'stock': 59, 'safety': '8 units'},
      {'name': 'Dada\'s Photo + Radha Krishna Photo Round Keychain', 'sku': 'DADA-KCH-003', 'stock': 95, 'safety': '12 units'},
      {'name': 'Dada\'s Photo + Radha Krishna Photo + Radhe Radhe Keychain', 'sku': 'DADA-KCH-004', 'stock': 50, 'safety': '6 units'},
      {'name': 'Dada and Krishna Bhagwan\'s Keychain', 'sku': 'DADA-KCH-005', 'stock': 70, 'safety': '10 units'},
      {'name': 'Dada\'s Photo Acrylic Photo Frame', 'sku': 'DADA-FRM-001', 'stock': 45, 'safety': '5 units'},
      {'name': 'Radha Krishna Bhagwan Acrylic Photo Frame', 'sku': 'DADA-FRM-002', 'stock': 55, 'safety': '8 units'},
      {'name': 'Krishna Bhagwan Acrylic Photo Frame', 'sku': 'DADA-FRM-003', 'stock': 40, 'safety': '5 units'},
      {'name': 'Dada\'s Photo Temple (Mandir)', 'sku': 'DADA-TMP-001', 'stock': 20, 'safety': '4 units'},
      {'name': 'Radha Krishna Bhagwan Temple (Mandir)', 'sku': 'DADA-TMP-002', 'stock': 18, 'safety': '3 units'},
      {'name': 'Sacred Charan Paduka - Small (3 Inch)', 'sku': 'DADA-PDK-001', 'stock': 50, 'safety': '10 units'},
      {'name': 'Sacred Charan Paduka - Medium (5 Inch)', 'sku': 'DADA-PDK-002', 'stock': 40, 'safety': '6 units'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inventory & Stock Replenishment', 
                  style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('Monitor real-time warehouse levels and trigger batch restocks.', 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withOpacity(0.3))),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('0 items below safety threshold', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: _tableHeaderText('ITEM & SKU')),
                    Expanded(flex: 1, child: _tableHeaderText('CURRENT STOCK')),
                    Expanded(flex: 1, child: _tableHeaderText('SAFETY LIMIT')),
                    Expanded(flex: 1, child: _tableHeaderText('STATUS INDICATOR')),
                    Expanded(flex: 1, child: _tableHeaderText('BATCH REPLENISH')),
                  ],
                ),
              ),
              // List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inventory.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      children: [
                        // ITEM & SKU
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text(item['sku'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade400, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        // CURRENT STOCK
                        Expanded(
                          flex: 1,
                          child: Text('${item['stock']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ),
                        // SAFETY LIMIT
                        Expanded(
                          flex: 1,
                          child: Text(item['safety'] as String, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ),
                        // STATUS INDICATOR
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.1))),
                              child: const Text('Adequate Stock', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          ),
                        ),
                        // BATCH REPLENISH
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              _replenishBtn('+5', Colors.grey.shade100, Colors.black87),
                              const SizedBox(width: 8),
                              _replenishBtn('+25', templeGold, Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _replenishBtn(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        boxShadow: bg == templeGold ? [BoxShadow(color: templeGold.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
      ),
      child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildOrdersDispatchView() {
    final orders = [
      {
        'id': 'DADA-2026-58107',
        'date': '22 Aug 2026',
        'status': 'DELIVERED',
        'payment': 'COD (pending)',
        'amount': '₹173.95',
        'itemsCount': '1 sacred items',
        'customer': 'Himanshu Rathod',
        'address': 'B-402, Radhe Krishna Residency, Near Temple Road, Ahmedabad, Gujarat',
        'mobile': '+91 98765 43210',
        'carrier': 'DTDC Express / Blue Dart: DTDC-IND-1256539',
        'products': [
          {'name': 'Mobile Keychain', 'qty': '1 x ₹119'}
        ]
      },
      {
        'id': 'DADA-2026-34355',
        'date': '22 Aug 2026',
        'status': 'CANCELLED',
        'payment': 'UPI (paid)',
        'amount': '₹202.95',
        'itemsCount': '1 sacred items',
        'customer': 'Himanshu Rathod',
        'address': 'B-402, Radhe Krishna Residency, Near Temple Road, Ahmedabad, Gujarat',
        'mobile': '+91 98765 43210',
        'carrier': 'DTDC Express / Blue Dart: DTDC-IND-5328727',
        'products': [
          {'name': 'Dada\'s Photo Keychain', 'qty': '1 x ₹99'}
        ]
      },
      {
        'id': 'DADA-2026-89661',
        'date': '20 Feb 2026',
        'status': 'CANCELLED',
        'payment': 'UPI (paid)',
        'amount': '₹383.67',
        'itemsCount': '4 sacred items',
        'customer': 'Himanshu Rathod',
        'address': 'B-402, Radhe Krishna Residency, Near Temple Road, Ahmedabad, Gujarat',
        'mobile': '+91 98765 43210',
        'carrier': '',
        'products': [
          {'name': 'Dada\'s Photo Keychain', 'qty': '2 x ₹198'},
          {'name': 'Dada\'s Photo Temple (Mandir)', 'qty': '1 x ₹125'},
          {'name': 'Sacred Charan Paduka - Medium (5 Inch)', 'qty': '1 x ₹79'}
        ]
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        _buildOrdersHeader(),
        const SizedBox(height: 32),
        ...orders.map((o) => _buildOrderCard(o)),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildOrdersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orders & Consecration Dispatch', 
              style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Track devotee orders, manage shipping carriers, and generate GST invoices.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        Row(
          children: [
            _filterChip('ALL', true),
            _filterChip('PENDING', false),
            _filterChip('PROCESSING', false),
            _filterChip('SHIPPED', false),
            _filterChip('DELIVERED', false),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.brown.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? Colors.brown.shade800 : Colors.grey.shade200),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> o) {
    bool isCancelled = o['status'] == 'CANCELLED';
    Color statusColor = o['status'] == 'DELIVERED' ? Colors.green : (isCancelled ? Colors.grey : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: templeGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.inventory_2_outlined, color: Colors.brown, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(o['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(o['status'] as String, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Placed on ${o['date']} • Payment: ${o['payment']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(o['amount'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(o['itemsCount'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 24),
              Container(
                width: 150,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: isCancelled ? 'Cancelled' : 'Delivered',
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    items: ['Delivered', 'Cancelled', 'Processing'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                    onChanged: (v) {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Product List in Order
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: (o['products'] as List).map((p) => Container(
              width: 320,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(width: 40, height: 40, color: Colors.grey.shade200, child: const Icon(Icons.image_outlined, size: 20, color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(p['qty'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          // Devotee Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        children: [
                          TextSpan(text: '${o['customer']} • ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${o['address']} (${o['mobile']})', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if ((o['carrier'] as String).isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
                  child: Text(o['carrier'] as String, style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w500)),
                ),
              const SizedBox(width: 24),
              OutlinedButton(
                onPressed: () {}, 
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Update Tracking', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {}, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('PRINT INVOICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSettlementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payments & COD Settlement', 
              style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Reconcile UPI transfers, Card gateways, and Cash on Delivery collections.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildPaymentStatCard('UPI INSTANT TRANSFERS', '₹586.62', 'ID: dada.bhagwan@okhdfcbank', Icons.account_balance_wallet_outlined),
                _buildPaymentStatCard('CASH ON DELIVERY (COD)', '₹173.95', 'Doorstep carrier collections', Icons.local_shipping_outlined),
                _buildPaymentStatCard('ONLINE CARDS / NETBANKING', '₹0.00', '100% Secure 256-bit Encrypted', Icons.security_outlined),
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildPaymentStatCard(String label, String value, String sub, IconData icon) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(icon, color: primaryTeal.withValues(alpha: 0.1), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDevoteesUserView() {
    final devotees = [
      {
        'name': 'Himanshu Rathod',
        'email': 'rathodhimanshu865@gmail.com',
        'mobile': '+91 98765 43210',
        'orders': 3,
        'offerings': '₹1760.57',
        'location': 'Ahmedabad, Gujarat',
        'joined': '2026-01-15',
      },
      {
        'name': 'Priya Sharma',
        'email': 'priya.sharma@gmail.com',
        'mobile': '+91 98251 67890',
        'orders': 0,
        'offerings': '₹0.00',
        'location': 'Surat, Gujarat',
        'joined': '2026-01-20',
      },
      {
        'name': 'Amit Patel',
        'email': 'amit.patel99@yahoo.com',
        'mobile': '+91 97123 45678',
        'orders': 0,
        'offerings': '₹0.00',
        'location': 'Vadodara, Gujarat',
        'joined': '2026-02-01',
      },
      {
        'name': 'Neha Joshi',
        'email': 'neha.joshi@outlook.com',
        'mobile': '+91 98380 11223',
        'orders': 0,
        'offerings': '₹0.00',
        'location': 'Mumbai, Maharashtra',
        'joined': '2026-02-10',
      },
      {
        'name': 'Rajeshwar Dave',
        'email': 'rajesh.dave@gmail.com',
        'mobile': '+91 94260 95887',
        'orders': 0,
        'offerings': '₹0.00',
        'location': 'Rajkot, Gujarat',
        'joined': '2026-02-14',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        _buildDevoteesHeader(),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: devotees.map((d) => _buildDevoteeCard(d)).toList(),
            );
          },
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildDevoteesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Devotee User Management', 
              style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('View registered devotees, their contact information, and sacred purchase history.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search devotees...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevoteeCard(Map<String, dynamic> d) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.brown.shade800,
                child: Text(d['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                    Text(d['email'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    Text(d['mobile'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Orders:', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  Text('Lifetime Offerings:', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${d['orders']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(d['offerings'] as String, style: TextStyle(color: Colors.brown.shade400, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.brown),
              const SizedBox(width: 4),
              Text(d['location'] as String, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.message_outlined, size: 16, color: Colors.teal.shade700),
                  const SizedBox(width: 8),
                  Text('WhatsApp Seva', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Text('joined ${d['joined']}', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsOffersView() {
    final coupons = [
      {
        'code': 'DADA10',
        'desc': '10% instant discount on all Dada & Radha Krishna sacred products',
        'discount': '10%',
        'minOrder': '₹299',
        'used': '412',
        'status': 'ACTIVE',
      },
      {
        'code': 'RADHE50',
        'desc': 'Flat ₹50 OFF on orders above ₹499 + Free Consecration Kit',
        'discount': '₹50',
        'minOrder': '₹499',
        'used': '289',
        'status': 'ACTIVE',
      },
      {
        'code': 'MANDIR100',
        'desc': 'Flat ₹100 OFF on Temple & Acrylic Frame collections above ₹999',
        'discount': '₹100',
        'minOrder': '₹999',
        'used': '145',
        'status': 'ACTIVE',
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        _buildCouponsHeader(),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: coupons.map((c) => _buildCouponCard(c)).toList(),
            );
          }
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildCouponsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coupons & Devotional Offers', 
              style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Create promo codes and celebratory blessing discounts for devotees.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        _actionBtn('+ CREATE PROMO CODE', const Color(0xFF8B4513), Icons.add),
      ],
    );
  }

  Widget _buildCouponCard(Map<String, String> c) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: templeGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(c['code']!, style: TextStyle(color: templeGold, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(c['desc']!, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 24),
          _couponDetailRow('Discount:', c['discount']!),
          _couponDetailRow('Min Order:', c['minOrder']!),
          _couponDetailRow('Times Used:', c['used']!),
          const Divider(height: 48),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _couponDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildReviewsBlessingsView() {
    final reviews = [
      {
        'devotee': 'Ramesh Patel',
        'product': 'Dada\'s Photo Keychain',
        'rating': 5,
        'comment': 'The darshan is very clear. High quality material.',
      },
      {
        'devotee': 'Suresh Kumar',
        'product': 'Acrylic Photo Frame',
        'rating': 4,
        'comment': 'Very beautiful frame for my car dashboard.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Devotee Reviews & Blessings', 
              style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Moderate customer testimonials and publish official Temple Seva replies.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 32),
        ...reviews.map((r) => _buildReviewCard(r)),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(text: r['devotee'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' on '),
                    TextSpan(text: r['product'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star, 
                  size: 14, 
                  color: index < r['rating'] ? Colors.amber : Colors.grey.shade200,
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            r['comment'],
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Reply to Devotee →',
                style: TextStyle(color: templeGold, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSevaSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Store & Seva Configuration', 
              style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Configure helpline phone, WhatsApp support, UPI payment ID, and announcement bar.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          width: 1000,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _buildSettingField('STORE NAME', 'DADA Official Devotional Store')),
                  const SizedBox(width: 32),
                  Expanded(child: _buildSettingField('STORE TAGLINE', 'Sacred Dada & Radha Krishna Devotional Treasures, Mandir Essentials')),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildSettingField('WHATSAPP SEVA NUMBER', '+91 98765 43210')),
                  const SizedBox(width: 32),
                  Expanded(child: _buildSettingField('UPI PAYMENT ID', 'dada.bhagwan@okhdfcbank')),
                ],
              ),
              const SizedBox(height: 32),
              _buildSettingField('TOP ANNOUNCEMENT BAR TEXT', '🎁 Complimentary Rakshasutra & Chandan Tika Blessing on all orders above ₹499 | Code: DADA10'),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('SAVE SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSettingField(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1)),
        const SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: initialValue),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
