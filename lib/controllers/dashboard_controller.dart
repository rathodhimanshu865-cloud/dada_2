import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class DashboardController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DashboardStats _stats = DashboardStats();
  List<ProductModel> _recentProducts = [];
  List<OrderModel> _recentOrders = [];
  List<ProductModel> _lowStockProducts = [];
  bool _isLoading = false;
  bool _isDisposed = false;
  int _selectedPeriodDays = 30;

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  DashboardStats get stats => _stats;
  List<ProductModel> get recentProducts => _recentProducts;
  List<OrderModel> get recentOrders => _recentOrders;
  List<ProductModel> get lowStockProducts => _lowStockProducts;
  bool get isLoading => _isLoading;
  int get selectedPeriodDays => _selectedPeriodDays;

  DashboardController() {
    loadDashboardData();
  }

  void setPeriod(int days) {
    _selectedPeriodDays = days;
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final results = await Future.wait([
        _firestore.collection('products').get(),
        _firestore.collection('categories').get(),
        _firestore.collection('users').get(),
        _firestore.collection('orders').get(),
      ]);

      final allProductsDocs = results[0].docs;
      final allCategoriesDocs = results[1].docs;
      final allUsersDocs = results[2].docs;
      final allOrdersDocs = results[3].docs;

      final products = allProductsDocs.map((doc) => ProductModel.fromFirestore(doc)).toList();
      final allOrders = allOrdersDocs.map((doc) => OrderModel.fromFirestore(doc)).toList();

      // Filter orders by period
      final now = DateTime.now();
      final periodStart = now.subtract(Duration(days: _selectedPeriodDays));
      final filteredOrders = allOrders.where((o) => (o.createdAt ?? DateTime(0)).isAfter(periodStart)).toList();

      int activeProducts = products.where((p) => p.isActive).length;
      int pendingOrders = filteredOrders.where((o) => o.orderStatus == 'Pending').length;
      int completedOrders = filteredOrders.where((o) => o.orderStatus == 'Delivered').length;
      
      double totalRevenue = 0;
      double totalProfit = 0;

      for (var o in filteredOrders) {
        if (o.paymentStatus == 'Paid' || o.orderStatus == 'Delivered') {
          totalRevenue += o.totalAmount;
          
          // Profit calculation
          for (var item in o.items) {
            final productId = item['productId'];
            final quantity = (item['quantity'] ?? 1) as int;
            final priceAtPurchase = (item['price'] ?? 0.0).toDouble();
            
            // Try to find the product to get cost price
            final product = products.firstWhere((p) => p.id == productId, orElse: () => ProductModel(id: '', name: '', price: 0, categoryId: ''));
            
            if (product.id.isNotEmpty) {
              totalProfit += (priceAtPurchase - product.costPrice) * quantity;
            }
          }
        }
      }

      _stats = DashboardStats(
        totalProducts: allProductsDocs.length,
        activeProducts: activeProducts,
        totalCategories: allCategoriesDocs.length,
        totalUsers: allUsersDocs.length,
        totalOrders: filteredOrders.length,
        pendingOrders: pendingOrders,
        completedOrders: completedOrders,
        totalRevenue: totalRevenue,
        totalProfit: totalProfit,
      );

      // Low stock products
      _lowStockProducts = products.where((p) => p.stock <= p.minStockAlert).toList();

      // Recent Products (Limit 5)
      _recentProducts = products;
      _recentProducts.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      if (_recentProducts.length > 5) _recentProducts = _recentProducts.sublist(0, 5);

      // Recent Orders (Limit 5)
      _recentOrders = allOrders;
      _recentOrders.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      if (_recentOrders.length > 5) _recentOrders = _recentOrders.sublist(0, 5);

    } catch (e) {
      debugPrint('Dashboard Load Error: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
