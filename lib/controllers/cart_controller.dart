import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartController extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get subtotal => _items.values.fold(0, (sum, item) => sum + item.total);

  CartController() {
    _loadCart();
  }

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        _items.remove(productId);
      } else {
        _items[productId]!.quantity = quantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    // Simplified serialization for this phase
    // In a real app, we'd store minimal IDs and fetch full products, 
    // but for immediate persistence we'll store basic data.
    final cartData = _items.map((key, item) => MapEntry(key, {
      'quantity': item.quantity,
      'product': {
        'id': item.product.id,
        'title': item.product.title,
        'price': item.product.price,
        'images': item.product.images,
        'slug': item.product.slug,
      }
    }));
    prefs.setString('shopping_cart', jsonEncode(cartData));
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartStr = prefs.getString('shopping_cart');
    if (cartStr != null) {
      try {
        final Map<String, dynamic> cartData = jsonDecode(cartStr);
        cartData.forEach((key, value) {
          final pData = value['product'];
          final product = Product(
            id: pData['id'],
            title: pData['title'],
            price: pData['price']?.toDouble(),
            images: List<String>.from(pData['images'] ?? []),
            slug: pData['slug'],
          );
          _items[key] = CartItem(product: product, quantity: value['quantity']);
        });
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading cart: $e");
      }
    }
  }
}
