import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';

class ProductDetailProvider extends ChangeNotifier {
  Product? _product;
  Product? get product => _product;

  ProductVariant? _selectedVariant;
  ProductVariant? get selectedVariant => _selectedVariant;

  int _quantity = 1;
  int get quantity => _quantity;

  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  bool _isGift = false;
  bool get isGift => _isGift;

  String _giftNote = '';
  String get giftNote => _giftNote;

  void setProduct(Product product) {
    _product = product;
    if (product.variants.isNotEmpty) {
      _selectedVariant = product.variants.first;
    } else {
      _selectedVariant = null;
    }
    _quantity = 1;
    _currentImageIndex = 0;
    _isGift = false;
    _giftNote = '';
    notifyListeners();
  }

  void selectVariant(ProductVariant variant) {
    _selectedVariant = variant;
    _quantity = 1; // Reset quantity on variant change
    notifyListeners();
  }

  void incrementQuantity() {
    int maxLimit = _selectedVariant?.stockQuantity ?? _product?.stockQuantity ?? 10; // Default limit or stock
    if (_quantity < maxLimit) {
      _quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  void setCurrentImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void toggleIsGift(bool value) {
    _isGift = value;
    notifyListeners();
  }

  void setGiftNote(String note) {
    _giftNote = note;
    notifyListeners();
  }

  double get currentPrice {
    if (_selectedVariant != null && _selectedVariant!.price != null) {
      return _selectedVariant!.price!;
    }
    return _product?.salePrice ?? _product?.price ?? 0.0;
  }

  bool get isOutOfStock {
    if (_selectedVariant != null) {
      return _selectedVariant!.stockQuantity <= 0;
    }
    return (_product?.stockQuantity ?? 0) <= 0 || _product?.stockStatus == 'Out of Stock';
  }
}
