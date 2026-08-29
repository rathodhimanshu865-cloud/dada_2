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
  bool _isLoading = false;

  DashboardStats get stats => _stats;
  List<ProductModel> get recentProducts => _recentProducts;
  List<OrderModel> get recentOrders => _recentOrders;
  bool get isLoading => _isLoading;

  DashboardController() {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch stats in parallel
      final results = await Future.wait([
        _firestore.collection('products').get(),
        _firestore.collection('categories').get(),
        _firestore.collection('users').get(),
        _firestore.collection('orders').get(),
      ]);

      final allProducts = results[0].docs;
      final allCategories = results[1].docs;
      final allUsers = results[2].docs;
      final allOrders = results[3].docs;

      final products = allProducts.map((doc) => ProductModel.fromFirestore(doc)).toList();
      final orders = allOrders.map((doc) => OrderModel.fromFirestore(doc)).toList();

      int activeProducts = products.where((p) => p.isActive).length;
      int pendingOrders = orders.where((o) => o.orderStatus == 'Pending').length;
      int completedOrders = orders.where((o) => o.orderStatus == 'Delivered').length;
      double totalRevenue = orders.where((o) => o.paymentStatus == 'Paid' || o.orderStatus == 'Delivered').fold(0.0, (accSum, o) => accSum + o.totalAmount);

      _stats = DashboardStats(
        totalProducts: allProducts.length,
        activeProducts: activeProducts,
        totalCategories: allCategories.length,
        totalUsers: allUsers.length,
        totalOrders: allOrders.length,
        pendingOrders: pendingOrders,
        completedOrders: completedOrders,
        totalRevenue: totalRevenue,
      );

      // Recent Products (Limit 5)
      _recentProducts = products;
      _recentProducts.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      if (_recentProducts.length > 5) _recentProducts = _recentProducts.sublist(0, 5);

      // Recent Orders (Limit 5)
      _recentOrders = orders;
      _recentOrders.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      if (_recentOrders.length > 5) _recentOrders = _recentOrders.sublist(0, 5);

    } catch (e) {
      debugPrint("Dashboard load error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
