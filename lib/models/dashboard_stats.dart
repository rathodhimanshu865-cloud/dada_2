class DashboardStats {
  final int totalProducts;
  final int activeProducts;
  final int totalCategories;
  final int totalUsers;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double totalRevenue;
  final double totalProfit;

  DashboardStats({
    this.totalProducts = 0,
    this.activeProducts = 0,
    this.totalCategories = 0,
    this.totalUsers = 0,
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.completedOrders = 0,
    this.totalRevenue = 0.0,
    this.totalProfit = 0.0,
  });

  factory DashboardStats.fromFirestore(Map<String, dynamic> data) {
    return DashboardStats(
      totalProducts: data['totalProducts'] ?? 0,
      activeProducts: data['activeProducts'] ?? 0,
      totalCategories: data['totalCategories'] ?? 0,
      totalUsers: data['totalUsers'] ?? 0,
      totalOrders: data['totalOrders'] ?? 0,
      pendingOrders: data['pendingOrders'] ?? 0,
      completedOrders: data['completedOrders'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0.0).toDouble(),
      totalProfit: (data['totalProfit'] ?? 0.0).toDouble(),
    );
  }
}
