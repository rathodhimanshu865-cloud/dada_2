import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductController extends ChangeNotifier {
  String _selectedCategory = 'All Sacred Products';

  String get selectedCategory => _selectedCategory;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<String> get categories => [
    'All Sacred Products',
    'Keychains',
    'Acrylic Photo Frames',
    'Temple',
    'Yantras & Malas',
    'Idols',
    'Puja Items',
    'Books & Granths',
    'Apparel',
  ];

  List<ProductModel> get allProducts => [
    ProductModel(
      id: '1',
      title: 'Devotee Keychain',
      category: 'Keychains',
      price: 150.0,
      originalPrice: 200.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Keychain',
      isNew: true,
    ),
    ProductModel(
      id: '2',
      title: 'Sacred Acrylic Frame',
      category: 'Acrylic Photo Frames',
      price: 500.0,
      originalPrice: 650.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Frame',
      isNew: true,
    ),
    ProductModel(
      id: '3',
      title: 'Divine Temple Model',
      category: 'Temple',
      price: 1200.0,
      originalPrice: 1500.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Temple',
    ),
    ProductModel(
      id: '4',
      title: 'Divine Paduka / Footprints',
      category: 'Temple',
      price: 350.0,
      originalPrice: 400.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Paduka',
      isNew: true,
    ),
    ProductModel(
      id: '5',
      title: 'Yantra for Peace',
      category: 'Yantras & Malas',
      price: 250.0,
      originalPrice: 300.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Yantra',
    ),
    ProductModel(
      id: '6',
      title: 'Radha Krishna Idol',
      category: 'Idols',
      price: 800.0,
      originalPrice: 1000.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Idol',
      isNew: true,
    ),
    ProductModel(
      id: '7',
      title: 'Bhagvat Gita',
      category: 'Books & Granths',
      price: 450.0,
      originalPrice: 500.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Book',
    ),
    ProductModel(
      id: '8',
      title: 'Sacred Kurta',
      category: 'Apparel',
      price: 1200.0,
      originalPrice: 1500.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Apparel',
    ),
    ProductModel(
      id: '9',
      title: 'Sacred Incense Sticks',
      category: 'Puja Items',
      price: 150.0,
      originalPrice: 200.0,
      imageUrl: 'https://via.placeholder.com/300x300/E8DCC4/0F4C5C?text=Incense',
      isNew: true,
    ),
  ];

  List<ProductModel> get filteredProducts {
    if (_selectedCategory == 'All Sacred Products') {
      return allProducts;
    }
    return allProducts.where((p) => p.category == _selectedCategory).toList();
  }

  List<ProductModel> get featuredProducts => allProducts.take(4).toList();

  final List<String> _wishlistIds = [];

  List<String> get wishlistIds => _wishlistIds;

  bool isLiked(String productId) => _wishlistIds.contains(productId);

  void toggleLike(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  List<ProductModel> get wishlistProducts {
    return allProducts.where((p) => _wishlistIds.contains(p.id)).toList();
  }
}
