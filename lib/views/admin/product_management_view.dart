import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/controllers/dashboard_controller.dart';
import 'package:dada_2/controllers/product_controller.dart';
import 'package:dada_2/models/product_model.dart';
import 'dashboard_view.dart';
import 'category_management_view.dart';
import 'inventory_stock_view.dart';
import 'order_dispatch_view.dart';
import 'payments_view.dart';
import 'devotee_management_view.dart';
import 'coupons_view.dart';
import 'reviews_view.dart';
import 'store_settings_view.dart';
import 'product_dialog_helper.dart';

class ProductManagementView extends StatefulWidget {
  const ProductManagementView({super.key});

  @override
  State<ProductManagementView> createState() => _ProductManagementViewState();
}

class _ProductManagementViewState extends State<ProductManagementView> {
  int _activeSubMenu = 0;
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final ScrollController _headerScrollCtrl = ScrollController();

  @override
  void dispose() {
    _headerScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Provider.of<DashboardController>(context);
    final prodCtrl = Provider.of<ProductController>(context);

    return Column(
      children: [
        _buildTopNavigationBar(dashCtrl, prodCtrl),
        Expanded(
          child: Container(
            color: const Color(0xFFFDFBF7),
            child: _buildActiveView(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavigationBar(DashboardController dashCtrl, ProductController prodCtrl) {
    final items = [
      {'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'title': 'Products', 'icon': Icons.shopping_bag_outlined},
      {'title': 'Categories', 'icon': Icons.category_outlined},
      {'title': 'Inventory', 'icon': Icons.inventory_2_outlined},
      {'title': 'Orders', 'icon': Icons.local_shipping_outlined},
      {'title': 'Users', 'icon': Icons.people_outline},
      {'title': 'Payments', 'icon': Icons.payments_outlined},
      {'title': 'Coupons', 'icon': Icons.local_offer_outlined},
      {'title': 'Reviews', 'icon': Icons.star_outline},
      {'title': 'Store & Settings', 'icon': Icons.settings_outlined},
    ];

    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _headerScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items.asMap().entries.map((e) {
                  int i = e.key;
                  bool active = _activeSubMenu == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () => setState(() => _activeSubMenu = i),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? primaryTeal : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(items[i]['icon'] as IconData, color: active ? Colors.white : Colors.grey, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              items[i]['title'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                color: active ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            onPressed: () => dashCtrl.loadDashboardData(),
            icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView() {
    switch (_activeSubMenu) {
      case 0: return DashboardView(onMenuChange: (index) => setState(() => _activeSubMenu = index));
      case 1: return const ProductListView();
      case 2: return CategoryManagementView(onMenuChange: (index) => setState(() => _activeSubMenu = index));
      case 3: return const InventoryStockView();
      case 4: return const OrderDispatchView();
      case 5: return const DevoteeManagementView();
      case 6: return const PaymentsView();
      case 7: return const CouponsView();
      case 8: return const ReviewsView();
      case 9: return const StoreSettingsView();
      default: return const DashboardView();
    }
  }
}

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prodCtrl = Provider.of<ProductController>(context);

    return StreamBuilder<List<ProductModel>>(
      stream: prodCtrl.getAdminProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = snapshot.data ?? [];
        final query = _searchCtrl.text.toLowerCase();
        final selectedCatId = prodCtrl.selectedCategoryId;
        
        final filtered = products.where((p) {
          final matchesSearch = p.name.toLowerCase().contains(query) || p.sku.toLowerCase().contains(query);
          final matchesCategory = selectedCatId == 'all' || p.categoryId.toLowerCase().trim() == selectedCatId.toLowerCase().trim();
          return matchesSearch && matchesCategory;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Product Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: () => ProductDialogHelper.showProductDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('ADD PRODUCT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4513), foregroundColor: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: prodCtrl.categories.contains(prodCtrl.selectedCategory) ? prodCtrl.selectedCategory : 'All Sacred Products',
                      decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      items: prodCtrl.categories.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) { if (v != null) prodCtrl.selectCategory(v); },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: _buildProductsTable(filtered, prodCtrl),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildProductsTable(List<ProductModel> products, ProductController prodCtrl) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text('PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 1, child: Text('PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 1, child: Text('STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 1, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (c, i) => const Divider(height: 1),
          itemBuilder: (c, i) {
            final p = products[i];
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(p.imageUrl, width: 32, height: 32, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, size: 32))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Text('₹${p.price}', style: const TextStyle(fontSize: 13))),
                  Expanded(
                    flex: 1, 
                    child: Row(
                      children: [
                        Text('${p.stock}', style: TextStyle(fontSize: 13, color: p.stock <= p.minStockAlert ? Colors.red : Colors.teal, fontWeight: FontWeight.bold)),
                        if (p.stock <= 2) ...[
                           const SizedBox(width: 8),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                             child: const Text('OUT OF STOCK', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                           ),
                        ],
                      ],
                    )
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        IconButton(onPressed: () => ProductDialogHelper.showProductDialog(context, product: p), icon: const Icon(Icons.edit_outlined, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        IconButton(onPressed: () => prodCtrl.deleteProduct(p.id), icon: const Icon(Icons.delete_outline, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
