import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'cms_views_helper.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../utils/app_typography.dart';
import 'order_management_view.dart';
import 'admin_users_view.dart';
import 'admin_notifications_view.dart';
import 'admin_settings_view.dart';

class ProductManagementView extends StatefulWidget {
  final int initialTab;
  const ProductManagementView({super.key, this.initialTab = 0});

  @override
  State<ProductManagementView> createState() => _ProductManagementViewState();
}

class _ProductManagementViewState extends State<ProductManagementView> {
  late int _activeSubMenu;
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color templeGold = const Color(0xFFC89A5B);
  final Color bgCream = const Color(0xFFFDFBF7);

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeSubMenu = widget.initialTab;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = Provider.of<DashboardController>(context);
    final productController = Provider.of<ProductController>(context);

    return Container(
      color: bgCream,
      child: Column(
        children: [
          _buildTopNavigationBar(dashboardController),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: _buildActiveView(dashboardController, productController),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigationBar(DashboardController controller) {
    final stats = controller.stats;
    final items = [
      {'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'title': 'Products', 'icon': Icons.shopping_bag_outlined, 'badge': '${stats.totalProducts}'},
      {'title': 'Categories', 'icon': Icons.category_outlined, 'badge': '${stats.totalCategories}'},
      {'title': 'Inventory', 'icon': Icons.inventory_2_outlined},
      {'title': 'Orders', 'icon': Icons.local_shipping_outlined, 'badge': '${stats.totalOrders}'},
      {'title': 'Users', 'icon': Icons.people_outline, 'badge': '${stats.totalUsers}'},
      {'title': 'Notifications', 'icon': Icons.notifications_outlined},
      {'title': 'Payments', 'icon': Icons.payments_outlined},
      {'title': 'Coupons', 'icon': Icons.local_offer_outlined},
      {'title': 'Reviews', 'icon': Icons.star_outline},
      {'title': 'Store Settings', 'icon': Icons.settings_outlined},
      // CMS Content Sections (Consolidated into header for easy access)
      {'title': 'General CMS', 'icon': Icons.web_outlined},
      {'title': 'Hero', 'icon': Icons.burst_mode},
      {'title': 'Bio', 'icon': Icons.person_outline},
      {'title': 'Katha Pages', 'icon': Icons.menu_book},
      {'title': 'Events', 'icon': Icons.event},
      {'title': 'Home CMS', 'icon': Icons.home_outlined},
      {'title': 'News', 'icon': Icons.newspaper},
      {'title': 'Archive', 'icon': Icons.list_alt},
      {'title': 'Photos', 'icon': Icons.photo_library},
      {'title': 'Videos', 'icon': Icons.video_library},
      {'title': 'Stotra', 'icon': Icons.music_note},
      {'title': 'Contact', 'icon': Icons.contact_mail},
      {'title': 'Footer', 'icon': Icons.south},
    ];

    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildAdminProfile(),
          const VerticalDivider(width: 40, indent: 15, endIndent: 15),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: items.asMap().entries.map((e) {
                    int i = e.key;
                    bool active = _activeSubMenu == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _activeSubMenu = i),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? primaryTeal : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(items[i]['icon'] as IconData, color: active ? Colors.white : Colors.grey, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                items[i]['title'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                  color: active ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (items[i]['badge'] != null && items[i]['badge'] != '0') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: active ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    items[i]['badge'] as String,
                                    style: TextStyle(fontSize: 10, color: active ? Colors.white : Colors.grey),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 40, indent: 15, endIndent: 15),
          TextButton.icon(
            onPressed: () => controller.loadDashboardData(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfile() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(backgroundColor: primaryTeal, radius: 16, child: const Text('AD', style: TextStyle(color: Colors.white, fontSize: 10))),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('Seva Manager', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveView(DashboardController dashCtrl, ProductController prodCtrl) {
    if (prodCtrl.isBrowsingLoading && prodCtrl.browsingProducts.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()));
    }
    
    if (prodCtrl.errorMessage != null && prodCtrl.browsingProducts.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(prodCtrl.errorMessage!, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: prodCtrl.clearError, child: const Text('RETRY')),
        ],
      ));
    }

    final homeController = Provider.of<HomePageController>(context, listen: false);

    // Dynamic routing for the "Super Header"
    if (_activeSubMenu <= 10) {
      switch (_activeSubMenu) {
        case 0: return _buildDashboard(dashCtrl);
        case 1: return _buildProductsList(prodCtrl);
        case 2: return _buildCategoriesGrid(prodCtrl);
        case 3: return _buildInventoryStockView(prodCtrl);
        case 4: return const OrderManagementView();
        case 5: return const AdminUsersView();
        case 6: return const AdminNotificationsView();
        case 7: return _buildPaymentsSettlementView(dashCtrl);
        case 8: return _buildCouponsOffersView();
        case 9: return _buildReviewsBlessingsView();
        case 10: return const AdminSettingsView();
        default: return const Center(child: Text('Section coming soon'));
      }
    } else {
      // Map CMS indices (starting from 11 in this view) to helper's indices (starting from 0)
      return CMSViewsHelper.buildCMSView(_activeSubMenu - 11, homeController, context, {}, (fn) => setState(fn));
    }
  }

  Widget _buildDashboard(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        _buildDashboardTitle(),
        const SizedBox(height: 32),
        _buildStatsGrid(controller),
        const SizedBox(height: 24),
        _buildActionButtons(),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1000) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRecentOrders(controller.recentOrders)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildStockWatch(controller.recentProducts)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildRecentOrders(controller.recentOrders),
                  const SizedBox(height: 24),
                  _buildStockWatch(controller.recentProducts),
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
          _siteHeaderItem(Icons.phone_in_talk_outlined, 'Helpline: Official Store'),
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
                      child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
            onPressed: () => Navigator.pushNamed(context, '/'),
            icon: const Icon(Icons.public, size: 16),
            label: const Text('View Store', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
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
      ],
    );
  }

  Widget _buildStatsGrid(DashboardController controller) {
    final stats = controller.stats;
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildStatCard('TOTAL REVENUE', '₹${stats.totalRevenue.toStringAsFixed(2)}', 'Total offerings received', Icons.currency_rupee, Colors.green),
        _buildStatCard('TOTAL ORDERS', '${stats.totalOrders}', '${stats.pendingOrders} pending consecration', Icons.receipt_long_outlined, Colors.blue),
        _buildStatCard('SACRED PRODUCTS', '${stats.totalProducts}', '${stats.activeProducts} active listings', Icons.auto_awesome_mosaic_outlined, Colors.brown),
        _buildStatCard('REGISTERED DEVOTEES', '${stats.totalUsers}', 'Joined the community', Icons.people_outline, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String sub, IconData icon, Color iconColor) {
    return Container(
      width: 250,
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
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87))),
          const SizedBox(height: 8),
          Text(sub, style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _actionBtn('+ ADD PRODUCT', templeGold, Icons.add, onTap: () => _showProductDialog()),
        _actionBtn('View All Orders', Colors.white, Icons.list_alt, isOutlined: true, onTap: () => setState(() => _activeSubMenu = 4)),
      ],
    );
  }

  Widget _actionBtn(String label, Color color, IconData icon, {bool isOutlined = false, VoidCallback? onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap ?? () {},
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

  Widget _buildRecentOrders(List<OrderModel> orders) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Devotee Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () => setState(() => _activeSubMenu = 4), child: Text('View All Orders (${orders.length}) →', style: const TextStyle(fontSize: 12, color: Colors.brown))),
            ],
          ),
          const SizedBox(height: 20),
          if (orders.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Text('No orders yet.'))
          else ...orders.take(5).map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(o.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 12),
                          _statusBadge(o.orderStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${o.customerName} • ${o.city}, ${o.state}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${o.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Delivered') color = Colors.green;
    if (status == 'Cancelled') color = Colors.red;
    if (status == 'Shipped') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStockWatch(List<ProductModel> products) {
    final lowStock = products.where((p) => p.stock < 10).toList();
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
              Text('${lowStock.length} Items', style: TextStyle(color: templeGold, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          if (lowStock.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.inventory_outlined, size: 48, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  const Text('No items currently low on stock.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                ],
              ),
            )
          else
            ...lowStock.take(5).map((p) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(p.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: Text(p.categoryId, style: const TextStyle(fontSize: 10)),
              trailing: Text('${p.stock}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            )),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductController prodCtrl) {
    return StreamBuilder<List<ProductModel>>(
      stream: prodCtrl.getAdminProducts(),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
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
                    Text('Product Catalog Management', 
                      style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('Add, edit, adjust stock, and manage sacred product listings.', 
                      style: TextStyle(color: Colors.grey.shade50, fontSize: 13)),
                  ],
                ),
                _actionBtn('+ ADD NEW PRODUCT', templeGold, Icons.add, onTap: () => _showProductDialog()),
              ],
            ),
            const SizedBox(height: 24),
            _buildFiltersRow(prodCtrl),
            const SizedBox(height: 24),
            _buildProductsTable(products, prodCtrl),
          ],
        );
      }
    );
  }

  Widget _buildFiltersRow(ProductController prodCtrl) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by title...',
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: prodCtrl.categoryObjects.any((c) => c.name == prodCtrl.selectedCategory) ? prodCtrl.selectedCategory : 'All Sacred Products',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: prodCtrl.categories.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (v) {
                  if (v != null) prodCtrl.selectCategory(v);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTable(List<ProductModel> products, ProductController prodCtrl) {
    final query = _searchCtrl.text.toLowerCase();
    final filtered = products.where((p) => p.name.toLowerCase().contains(query)).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              children: [
                Expanded(flex: 4, child: _tableHeaderText('PRODUCT DETAILS')),
                Expanded(flex: 2, child: _tableHeaderText('CATEGORY')),
                Expanded(flex: 1, child: _tableHeaderText('PRICE')),
                Expanded(flex: 1, child: _tableHeaderText('STOCK')),
                Expanded(flex: 1, child: _tableHeaderText('STATUS')),
                Expanded(flex: 1, child: _tableHeaderText('ACTIONS')),
              ],
            ),
          ),
          if (filtered.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No products found.')))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final p = filtered[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: p.imageUrls.isNotEmpty 
                                ? Image.network(p.imageUrls[0], width: 48, height: 48, fit: BoxFit.cover)
                                : Container(width: 48, height: 48, color: Colors.grey.shade100, child: const Icon(Icons.image_outlined)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), if (p.isFeatured) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: templeGold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text('FEATURED', style: TextStyle(color: templeGold, fontSize: 8, fontWeight: FontWeight.bold)))]))
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(p.categoryId, style: const TextStyle(fontSize: 12))),
                      Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('₹${p.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)), if (p.discountPrice != null) Text('₹${p.discountPrice!.toInt()}', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))])),
                      Expanded(flex: 1, child: Row(children: [Text('${p.stock}', style: TextStyle(fontWeight: FontWeight.bold, color: p.stock < 10 ? Colors.red : Colors.black87)), const SizedBox(width: 8), _stockControl(p, prodCtrl)])),
                      Expanded(flex: 1, child: _statusChip(p.isActive)),
                      Expanded(flex: 1, child: Row(children: [IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showProductDialog(product: p)), IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: () => _confirmDelete(p.id, prodCtrl))])),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _statusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: (active ? Colors.green : Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(active ? 'ACTIVE' : 'INACTIVE', style: TextStyle(color: active ? Colors.green : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _stockControl(ProductModel p, ProductController ctrl) {
    return Row(
      children: [
        _miniBtn('-', () => ctrl.updateProduct(p.copyWith(stock: (p.stock - 1).clamp(0, 9999)))),
        _miniBtn('+', () => ctrl.updateProduct(p.copyWith(stock: p.stock + 1))),
      ],
    );
  }

  Widget _miniBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(width: 20, height: 20, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)), alignment: Alignment.center, child: Text(label, style: const TextStyle(fontSize: 12))),
    );
  }

  Widget _tableHeaderText(String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 0.5));
  }

  Widget _buildCategoriesGrid(ProductController prodCtrl) {
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
            _actionBtn('+ ADD NEW CATEGORY', templeGold, Icons.add, onTap: () => _showCategoryDialog()),
          ],
        ),
        const SizedBox(height: 32),
        StreamBuilder<List<CategoryModel>>(
          stream: prodCtrl.categoriesStream,
          builder: (context, snapshot) {
            final categories = snapshot.data ?? [];
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, i) => _buildCategoryCard(categories[i], prodCtrl),
                );
              },
            );
          }
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryModel cat, ProductController ctrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: cat.imageUrl.isNotEmpty ? Image.network(cat.imageUrl, width: 40, height: 40, fit: BoxFit.cover) : Container(width: 40, height: 40, color: Colors.grey.shade100, child: const Icon(Icons.category))),
              Row(
                children: [
                  _statusChip(cat.isActive),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () => _confirmDeleteCategory(cat.id, ctrl)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (cat.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(cat.description, style: TextStyle(color: Colors.grey.shade500, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const Spacer(),
          TextButton(onPressed: () => _showCategoryDialog(category: cat), child: const Text('Edit Category →', style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildInventoryStockView(ProductController prodCtrl) {
    return StreamBuilder<List<ProductModel>>(
      stream: prodCtrl.getAdminProducts(),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSiteHeader(),
            const SizedBox(height: 20),
            _buildAdminBanner(),
            const SizedBox(height: 32),
            Text('Inventory & Stock Replenishment', style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
              child: Column(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))), child: Row(children: [Expanded(flex: 4, child: _tableHeaderText('ITEM & SKU')), Expanded(flex: 1, child: _tableHeaderText('STOCK')), Expanded(flex: 2, child: _tableHeaderText('REPLENISH'))])),
                ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: products.length, separatorBuilder: (c, i) => const Divider(height: 1), itemBuilder: (c, i) {
                  final p = products[i];
                  return Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), child: Row(children: [Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(p.id, style: const TextStyle(fontSize: 10, color: Colors.grey))])), Expanded(flex: 1, child: Text('${p.stock}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: p.stock < 10 ? Colors.red : Colors.black87))), Expanded(flex: 2, child: Row(children: [ElevatedButton(onPressed: () => prodCtrl.updateProduct(p.copyWith(stock: p.stock + 10)), child: const Text('+10')), const SizedBox(width: 8), ElevatedButton(onPressed: () => prodCtrl.updateProduct(p.copyWith(stock: p.stock + 50)), style: ElevatedButton.styleFrom(backgroundColor: templeGold), child: const Text('+50'))]))]));
                })
              ]),
            ),
          ],
        );
      }
    );
  }

  Widget _buildPaymentsSettlementView(DashboardController controller) {
    final stats = controller.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSiteHeader(),
        const SizedBox(height: 20),
        _buildAdminBanner(),
        const SizedBox(height: 32),
        Text('Payments & COD Settlement', style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        _buildPaymentStatCard('TOTAL SETTLED REVENUE', '₹${stats.totalRevenue.toStringAsFixed(2)}', 'Total offerings received', Icons.payments_outlined),
      ],
    );
  }

  Widget _buildPaymentStatCard(String label, String value, String sub, IconData icon) {
    return Container(
      width: 320, padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400)), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), Icon(icon, color: primaryTeal.withOpacity(0.1), size: 24)]), Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))]),
    );
  }

  Widget _buildDevoteesUserView() { return const Center(child: Text('Devotee User Management')); }
  Widget _buildCouponsOffersView() { return const Center(child: Text('Coupons & Devotional Offers')); }
  Widget _buildReviewsBlessingsView() { return const Center(child: Text('Devotee Reviews & Blessings')); }

  // --- CRUD Dialogs ---

  void _showProductDialog({ProductModel? product}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name);
    final descCtrl = TextEditingController(text: product?.description);
    final priceCtrl = TextEditingController(text: product?.price.toString());
    final discCtrl = TextEditingController(text: product?.discountPrice?.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '0');
    String selectedCat = product?.categoryId ?? 'Keychain';
    bool isActive = product?.isActive ?? true;
    bool isFeatured = product?.isFeatured ?? false;
    List<String> currentImages = product?.imageUrls != null ? List.from(product!.imageUrls) : [];
    double uploadProgress = 0;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final prodCtrl = Provider.of<ProductController>(context, listen: false);
          return AlertDialog(
            title: Text(isEdit ? 'Edit Sacred Item' : 'Add New Sacred Item'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (isUploading) ...[
                      LinearProgressIndicator(value: uploadProgress),
                      const SizedBox(height: 8),
                      Text('Uploading image: ${(uploadProgress * 100).toInt()}%'),
                      const SizedBox(height: 16),
                    ],
                    _dialogField('Product Name', nameCtrl),
                    _dialogField('Description', descCtrl, maxLines: 3),
                    Row(children: [Expanded(child: _dialogField('Price (₹)', priceCtrl)), const SizedBox(width: 16), Expanded(child: _dialogField('Discount Price (Optional)', discCtrl))]),
                    Row(children: [Expanded(child: _dialogField('Stock Count', stockCtrl)), const SizedBox(width: 16), Expanded(child: _dialogCatDropdown(prodCtrl, selectedCat, (v) => setDialogState(() => selectedCat = v!)))]),
                    SwitchListTile(title: const Text('Active for Sale'), value: isActive, onChanged: (v) => setDialogState(() => isActive = v)),
                    SwitchListTile(title: const Text('Mark as Featured'), value: isFeatured, onChanged: (v) => setDialogState(() => isFeatured = v)),
                    const Divider(),
                    const Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      ...currentImages.map((url) => Stack(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover)), 
                        Positioned(top: 0, right: 0, child: GestureDetector(
                          onTap: () async {
                            await prodCtrl.deleteImage(url);
                            setDialogState(() => currentImages.remove(url));
                          }, 
                          child: Container(color: Colors.black54, child: const Icon(Icons.close, color: Colors.white, size: 16))
                        ))
                      ])),
                      InkWell(onTap: isUploading ? null : () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1080, imageQuality: 85);
                        if (img != null) {
                          final productId = isEdit ? product.id : 'new_${DateTime.now().millisecondsSinceEpoch}';
                          final task = prodCtrl.getUploadTask(File(img.path), productId);
                          
                          setDialogState(() {
                            isUploading = true;
                            uploadProgress = 0;
                          });

                          task.snapshotEvents.listen((snapshot) {
                            setDialogState(() {
                              uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
                            });
                          });

                          final snapshot = await task;
                          final url = await snapshot.ref.getDownloadURL();
                          
                          setDialogState(() {
                            currentImages.add(url);
                            isUploading = false;
                          });
                        }
                      }, child: Container(width: 80, height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_a_photo))),
                    ]),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
              ElevatedButton(
                onPressed: () async {
                  final p = (isEdit ? product : ProductModel(id: 'DADA-${DateTime.now().millisecondsSinceEpoch}', name: '', price: 0, categoryId: '')).copyWith(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 0.0,
                    discountPrice: double.tryParse(discCtrl.text),
                    categoryId: selectedCat,
                    stock: int.tryParse(stockCtrl.text) ?? 0,
                    isActive: isActive,
                    isFeatured: isFeatured,
                    imageUrls: currentImages,
                    imageUrl: currentImages.isNotEmpty ? currentImages[0] : '',
                  );
                  if (isEdit) {
                    await prodCtrl.updateProduct(p);
                  } else {
                    await prodCtrl.addProduct(p);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
                child: Text(isEdit ? 'SAVE CHANGES' : 'PUBLISH PRODUCT'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showCategoryDialog({CategoryModel? category}) {
    final isEdit = category != null;
    final nameCtrl = TextEditingController(text: category?.name);
    final descCtrl = TextEditingController(text: category?.description);
    String imageUrl = category?.imageUrl ?? '';
    bool isActive = category?.isActive ?? true;
    double uploadProgress = 0;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final prodCtrl = Provider.of<ProductController>(context, listen: false);
          return AlertDialog(
            title: Text(isEdit ? 'Edit Category' : 'Add Category'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUploading) ...[
                      LinearProgressIndicator(value: uploadProgress),
                      const SizedBox(height: 8),
                      Text('Uploading icon: ${(uploadProgress * 100).toInt()}%'),
                      const SizedBox(height: 16),
                    ],
                    _dialogField('Category Name', nameCtrl),
                    _dialogField('Description', descCtrl, maxLines: 3),
                    SwitchListTile(
                      title: const Text('Active Category'),
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.isNotEmpty 
                        ? Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover) 
                        : Container(width: 100, height: 100, color: Colors.grey.shade100, child: const Icon(Icons.category, size: 40, color: Colors.grey)),
                    ),
                    TextButton.icon(
                      onPressed: isUploading ? null : () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
                        if (img != null) {
                          final catId = isEdit ? category.id : 'cat_${DateTime.now().millisecondsSinceEpoch}';
                          final task = prodCtrl.getUploadTask(File(img.path), catId);

                          setDialogState(() {
                            isUploading = true;
                            uploadProgress = 0;
                          });

                          task.snapshotEvents.listen((snapshot) {
                            setDialogState(() {
                              uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
                            });
                          });

                          final snapshot = await task;
                          final url = await snapshot.ref.getDownloadURL();
                          
                          setDialogState(() {
                            imageUrl = url;
                            isUploading = false;
                          });
                        }
                      }, 
                      icon: const Icon(Icons.upload), 
                      label: Text(imageUrl.isEmpty ? 'Upload Category Icon' : 'Replace Category Icon'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  final c = (isEdit ? category : CategoryModel(id: nameCtrl.text.toLowerCase().replaceAll(' ', '_'), name: '', imageUrl: '')).copyWith(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    imageUrl: imageUrl,
                    isActive: isActive,
                    updatedAt: DateTime.now(),
                  );
                  if (isEdit) {
                    await prodCtrl.updateCategory(c);
                  } else {
                    await prodCtrl.addCategory(c);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('SAVE'),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(controller: ctrl, maxLines: maxLines, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
    );
  }

  Widget _dialogCatDropdown(ProductController prodCtrl, String selected, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: prodCtrl.categoryObjects.any((c) => c.id == selected) ? selected : (prodCtrl.categoryObjects.isNotEmpty ? prodCtrl.categoryObjects[0].id : null),
          items: prodCtrl.categoryObjects.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _confirmDelete(String id, ProductController ctrl) {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Delete Product?'), content: const Text('This action cannot be undone.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')), ElevatedButton(onPressed: () async { await ctrl.deleteProduct(id); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('DELETE'))]));
  }

  void _confirmDeleteCategory(String id, ProductController ctrl) async {
    final hasProducts = await ctrl.hasProductsInCategory(id);
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(hasProducts ? 'Cannot Delete Category' : 'Delete Category?'),
          content: Text(hasProducts 
            ? 'This category has products assigned to it. Please reassign or delete the products first.' 
            : 'This action cannot be undone. Are you sure you want to delete this category?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            if (!hasProducts)
              ElevatedButton(
                onPressed: () async {
                  await ctrl.deleteCategory(id);
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
          ],
        ),
      );
    }
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
