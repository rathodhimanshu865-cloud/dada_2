import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(OrderModel order) async {
    final batch = _firestore.batch();
    
    // 1. Create the order
    final orderRef = _firestore.collection('orders').doc(order.orderId);
    batch.set(orderRef, order.toFirestore());
    
    // 2. Decrement stock for each item
    for (var item in order.items) {
      final productId = item['productId'];
      final quantity = item['quantity'] ?? 0;
      
      if (productId != null && quantity > 0) {
        final productRef = _firestore.collection('products').doc(productId);
        batch.update(productRef, {
          'stock': FieldValue.increment(-quantity),
          'salesCount': FieldValue.increment(quantity),
        });
      }
    }
    
    await batch.commit();
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
           final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
           orders.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
           return orders;
        });
  }

  Stream<OrderModel?> getOrderDetails(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) => snapshot.exists ? OrderModel.fromFirestore(snapshot) : null);
  }

  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'orderStatus': 'Cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin methods
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'orderStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOrder(OrderModel order) async {
    await _firestore.collection('orders').doc(order.orderId).update(order.toFirestore());
  }
}
