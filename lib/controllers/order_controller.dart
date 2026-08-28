import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../repositories/order_repository.dart';

class OrderController extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> placeOrder({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required List<CartItem> cartItems,
    required double subtotal,
    required double deliveryCharge,
    required double tax,
    required double total,
    required String paymentMethod,
    String? note,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final orderId = 'DADA-${DateTime.now().millisecondsSinceEpoch}';
      
      final items = cartItems.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        'price': item.price,
        'quantity': item.quantity,
        'imageUrl': item.imageUrl,
      }).toList();

      final order = OrderModel(
        orderId: orderId,
        userId: user.uid,
        customerName: name,
        phone: phone,
        email: email,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        items: items,
        subtotal: subtotal,
        deliveryCharge: deliveryCharge,
        discount: 0.0, // Can be implemented with coupons later
        tax: tax,
        totalAmount: total,
        paymentMethod: paymentMethod,
        paymentStatus: paymentMethod == 'COD' ? 'Pending' : 'Paid',
        orderStatus: 'Pending',
        note: note,
      );

      await _repository.placeOrder(order);
      _isLoading = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      debugPrint("Place order error: $e");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Stream<List<OrderModel>> get userOrders {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _repository.getUserOrders(user.uid);
  }

  Stream<OrderModel?> getOrderDetails(String orderId) {
    return _repository.getOrderDetails(orderId);
  }

  Future<void> cancelOrder(String orderId) async {
    await _repository.cancelOrder(orderId);
  }
}
