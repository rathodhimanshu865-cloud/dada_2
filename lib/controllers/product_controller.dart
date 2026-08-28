import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/store_config_model.dart';
import '../repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Streams for sections
  late Stream<StoreConfigModel> storeConfigStream;
  late Stream<List<CategoryModel>> categoriesStream;
  late Stream<List<ProductModel>> featuredProductsStream;
  late Stream<List<ProductModel>> latestProductsStream;
  late Stream<List<ProductModel>> popularProductsStream;
  
  // Browsing state
  final List<ProductModel> _browsingProducts = [];
  bool _isBrowsingLoading = false;
  bool _hasMore = true;

  // Category State
  List<CategoryModel> _categoryObjects = [];
  String _selectedCategoryId = 'all'; // Stores category ID, 'all' for all products
  
  // Search state
  String _searchQuery = '';
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  // Compatibility / Helper Getters
  List<ProductModel> get browsingProducts => _browsingProducts;
  bool get isBrowsingLoading => _isBrowsingLoading;
  
  List<CategoryModel> get categoryObjects => _categoryObjects;
  
  // Returns names for UI chips (Compatibility)
  List<String> get categories => ['All Sacred Products', ..._categoryObjects.map((c) => c.name)];
  
  String get selectedCategory {
    if (_selectedCategoryId == 'all') return 'All Sacred Products';
    final cat = _categoryObjects.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => CategoryModel(id: '', name: '', imageUrl: ''));
    return cat.name;
  }

  String get searchQuery => _searchQuery;
  List<ProductModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  // In-memory list for fast searching
  List<ProductModel> _allProductsCache = [];
  List<ProductModel> get allProducts => _allProductsCache;

  List<String> _wishlistIds = [];
  List<String> get wishlistIds => _wishlistIds;
  StreamSubscription? _wishlistSubscription;

  ProductController() {
    _initStreams();
    fetchCategories();
    _loadInitialData();
    _listenToAuth();
  }

  void _listenToAuth() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startWishlistSubscription(user.uid);
      } else {
        _stopWishlistSubscription();
      }
    });
  }

  void _startWishlistSubscription(String uid) {
    _wishlistSubscription?.cancel();
    _wishlistSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .listen((snapshot) {
      _wishlistIds = snapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    });
  }

  void _stopWishlistSubscription() {
    _wishlistSubscription?.cancel();
    _wishlistIds = [];
    notifyListeners();
  }

  void _initStreams() {
    storeConfigStream = _repository.getStoreConfig();
    categoriesStream = _repository.getCategories();
    featuredProductsStream = _repository.getFeaturedProducts();
    latestProductsStream = _repository.getLatestProducts();
    popularProductsStream = _repository.getPopularProducts();
  }

  Future<void> _loadInitialData() async {
    try {
      final products = await _repository.getAllProducts(limit: 100);
      _allProductsCache = products;
      notifyListeners();
    } catch (e) {
      debugPrint("Load initial data error: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      // We listen to the stream for internal state as well
      _repository.getCategories().listen((cats) {
        _categoryObjects = cats;
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Error initializing categories: $e");
    }
  }

  // Called when a category is selected in the UI
  void selectCategory(String categoryNameOrId) {
    if (categoryNameOrId == 'All Sacred Products' || categoryNameOrId == 'all') {
      _selectedCategoryId = 'all';
    } else {
      // Check if it's an ID first
      if (_categoryObjects.any((c) => c.id == categoryNameOrId)) {
        _selectedCategoryId = categoryNameOrId;
      } else {
        // Find ID by Name
        final cat = _categoryObjects.firstWhere(
          (c) => c.name == categoryNameOrId, 
          orElse: () => CategoryModel(id: 'all', name: '', imageUrl: '')
        );
        _selectedCategoryId = cat.id;
      }
    }
    fetchBrowsingProducts(refresh: true);
    notifyListeners();
  }

  Future<void> fetchBrowsingProducts({bool refresh = false}) async {
    if (_isBrowsingLoading) return;
    if (!refresh && !_hasMore) return;

    if (refresh) {
      _browsingProducts.clear();
      _hasMore = true;
    }

    _isBrowsingLoading = true;
    notifyListeners();

    try {
      final products = await _repository.getFilteredProducts(
        categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        onlyInStock: onlyInStock,
        sortBy: sortBy,
        descending: sortDescending,
        limit: 20
      );

      if (products.length < 20) _hasMore = false;
      _browsingProducts.addAll(products);
      
    } catch (e) {
      debugPrint("Browsing error: $e");
    } finally {
      _isBrowsingLoading = false;
      notifyListeners();
    }
  }

  // Filtering & Sorting State
  double? minPrice;
  double? maxPrice;
  bool onlyInStock = false;
  String sortBy = 'createdAt';
  bool sortDescending = true;

  void updateFilters({String? category, double? min, double? max, bool? inStock}) {
    if (category != null) selectCategory(category);
    minPrice = min;
    maxPrice = max;
    if (inStock != null) onlyInStock = inStock;
    fetchBrowsingProducts(refresh: true);
  }

  void updateSort(String by, bool descending) {
    sortBy = by;
    sortDescending = descending;
    fetchBrowsingProducts(refresh: true);
  }

  Stream<ProductModel?> getProductDetails(String productId) {
    return _repository.getProductDetails(productId);
  }

  // Compatibility getter
  List<ProductModel> get filteredProducts {
    if (_selectedCategoryId == 'all') {
      return _allProductsCache;
    }
    return _allProductsCache.where((p) => p.categoryId == _selectedCategoryId).toList();
  }
  
  List<ProductModel> get wishlistProducts {
    return _allProductsCache.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  Future<void> performSearch(String query) async {
    _searchQuery = query.trim();
    _searchError = null;

    if (_searchQuery.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final lowercaseQuery = _searchQuery.toLowerCase();
      
      _searchResults = _allProductsCache.where((p) {
        return p.name.toLowerCase().contains(lowercaseQuery) ||
               p.nameHi.toLowerCase().contains(lowercaseQuery) ||
               p.nameGu.toLowerCase().contains(lowercaseQuery) ||
               p.categoryId.toLowerCase().contains(lowercaseQuery) ||
               p.description.toLowerCase().contains(lowercaseQuery);
      }).toList();

      if (_searchResults.length < 5) {
        final serverResults = await _repository.searchProducts(_searchQuery);
        for (var sp in serverResults) {
          if (!_searchResults.any((r) => r.id == sp.id)) {
            _searchResults.add(sp);
          }
        }
      }
    } catch (e) {
      debugPrint("Search error: $e");
      _searchError = "Something went wrong while searching.";
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  bool isLiked(String productId) => _wishlistIds.contains(productId);

  Future<void> toggleLike(String productId) async {
    final user = _auth.currentUser;
    if (user == null) {
      // Potentially show login prompt or just return
      return;
    }

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId);

    if (_wishlistIds.contains(productId)) {
      await docRef.delete();
    } else {
      await docRef.set({
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }

  // --- Admin CRUD Operations ---

  Future<void> addProduct(ProductModel product) async {
    await _repository.addProduct(product);
  }

  Future<void> updateProduct(ProductModel product) async {
    await _repository.updateProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _repository.deleteProduct(productId);
  }

  Future<String> uploadImage(File file, String productId) async {
    return await _repository.uploadProductImage(file, productId);
  }

  Stream<List<ProductModel>> getAdminProducts() {
    return _repository.getAdminProducts();
  }

  // Category CRUD
  Future<void> addCategory(CategoryModel category) async {
    await _repository.addCategory(category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _repository.updateCategory(category);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
  }
}
