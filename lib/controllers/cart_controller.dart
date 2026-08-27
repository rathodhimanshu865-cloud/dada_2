import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<CartItem> _items = [];
  StreamSubscription? _cartSubscription;

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (count, item) => count + item.quantity);

  double get subtotal => _items.fold(0.0, (acc, item) => acc + (item.price * item.quantity));

  double get shippingFee => subtotal > 499 || subtotal == 0 ? 0 : 49;
  
  double get tax => subtotal * 0.05;

  double get total => subtotal + shippingFee + tax;

  CartController() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startCartSubscription(user.uid);
      } else {
        _stopCartSubscription();
      }
    });
  }

  void _startCartSubscription(String uid) {
    _cartSubscription?.cancel();
    _cartSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _items = snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  void _stopCartSubscription() {
    _cartSubscription?.cancel();
    _items = [];
    notifyListeners();
  }

  Future<void> addToCart(ProductModel product, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartDoc = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product.id);

    final doc = await cartDoc.get();

    int newQuantity = quantity;
    if (doc.exists) {
      newQuantity = (doc.data()?['quantity'] ?? 0) + quantity;
    }

    // Validation: Do not allow quantity greater than available stock
    if (newQuantity > product.stock) {
      newQuantity = product.stock;
    }

    if (newQuantity <= 0) {
      await cartDoc.delete();
    } else {
      await cartDoc.set({
        'productName': product.name,
        'price': product.discountPrice ?? product.price,
        'imageUrl': product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
        'quantity': newQuantity,
        'addedAt': doc.exists ? (doc.data()?['addedAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateQuantity(String productId, int delta) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartDoc = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    final doc = await cartDoc.get();
    if (!doc.exists) return;

    int currentQty = doc.data()?['quantity'] ?? 0;
    int newQty = currentQty + delta;

    // We need to check stock. Since we only have productId here, 
    // ideally we'd fetch the product. For now, let's assume UI handles basic limits,
    // but here we should at least prevent < 1 if we don't want auto-remove, 
    // or auto-remove if < 1.
    
    if (newQty <= 0) {
      await cartDoc.delete();
    } else {
      // Re-verify stock if possible. 
      // For a robust system, we should fetch product stock from Firestore here.
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (productDoc.exists) {
        int stock = productDoc.data()?['stock'] ?? 0;
        if (newQty > stock) newQty = stock;
      }

      await cartDoc.update({'quantity': newQty});
    }
  }

  Future<void> removeItem(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart');
    
    final batch = _firestore.batch();
    final snapshot = await cartRef.get();
    
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
