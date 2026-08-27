import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/store_config_model.dart';
import '../repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  // Streams for each section
  late Stream<StoreConfigModel> storeConfigStream;
  late Stream<List<CategoryModel>> categoriesStream;
  late Stream<List<ProductModel>> featuredProductsStream;
  late Stream<List<ProductModel>> latestProductsStream;
  late Stream<List<ProductModel>> popularProductsStream;

  // Search state
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  
  // Legacy fields for existing UI compatibility
  List<ProductModel> _allProducts = [];
  List<String> _categories = ['All Sacred Products'];
  String _selectedCategory = 'All Sacred Products';
  bool _isLoading = false;

  List<ProductModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  
  List<ProductModel> get allProducts => _allProducts;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  ProductController() {
    _initStreams();
    fetchProducts();
    fetchCategories();
  }

  void _initStreams() {
    storeConfigStream = _repository.getStoreConfig();
    categoriesStream = _repository.getCategories();
    featuredProductsStream = _repository.getFeaturedProducts();
    latestProductsStream = _repository.getLatestProducts();
    popularProductsStream = _repository.getPopularProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products')
          .orderBy('createdAt', descending: true)
          .get();
      _allProducts = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categories').get();
      List<String> fetchedCategories = snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
      _categories = ['All Sacred Products', ...fetchedCategories];
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<ProductModel> get filteredProducts {
    if (_selectedCategory == 'All Sacred Products') {
      return _allProducts;
    }
    return _allProducts.where((p) => p.categoryId == _selectedCategory).toList();
  }
  
  List<ProductModel> get wishlistProducts {
    return _allProducts.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  Future<void> performSearch(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchProducts(query);
    } catch (e) {
      debugPrint("Search error: $e");
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

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
}
