import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/store_config_model.dart';
import '../repositories/product_repository.dart';
import '../utils/app_logger.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Internal Data State
  StoreConfigModel _storeConfig = StoreConfigModel();
  List<CategoryModel> _categoryObjects = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _latestProducts = [];
  List<ProductModel> _popularProducts = [];
  
  // Subscriptions
  StreamSubscription? _configSub;
  StreamSubscription? _categorySub;
  StreamSubscription? _featuredSub;
  StreamSubscription? _latestSub;
  StreamSubscription? _popularSub;
  StreamSubscription? _wishlistSubscription;

  // Stream Getters for Backward Compatibility
  Stream<StoreConfigModel> get storeConfigStream => _repository.getStoreConfig();
  Stream<List<CategoryModel>> get categoriesStream => _repository.getCategories();
  Stream<List<ProductModel>> get featuredProductsStream => _repository.getFeaturedProducts();
  Stream<List<ProductModel>> get latestProductsStream => _repository.getLatestProducts();
  Stream<List<ProductModel>> get popularProductsStream => _repository.getPopularProducts();

  // Getters for UI
  StoreConfigModel get storeConfig => _storeConfig;
  List<CategoryModel> get categoryObjects => _categoryObjects;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get latestProducts => _latestProducts;
  List<ProductModel> get popularProducts => _popularProducts;

  // Browsing state
  final List<ProductModel> _browsingProducts = [];
  bool _isBrowsingLoading = false;
  bool _hasMore = true;

  // Category State
  String _selectedCategoryId = 'all'; 
  
  // Search state
  String _searchQuery = '';
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<ProductModel> get browsingProducts => _browsingProducts;
  bool get isBrowsingLoading => _isBrowsingLoading;
  
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

  List<ProductModel> _allProductsCache = [];
  List<ProductModel> get allProducts => _allProductsCache;

  List<String> _wishlistIds = [];
  List<String> get wishlistIds => _wishlistIds;

  ProductController() {
    _startListeners();
    _loadInitialData();
    _listenToAuth();
  }

  void _startListeners() {
    _configSub?.cancel();
    _categorySub?.cancel();
    _featuredSub?.cancel();
    _latestSub?.cancel();
    _popularSub?.cancel();

    _configSub = _repository.getStoreConfig().listen((data) {
      if (_storeConfig.storeName != data.storeName || _storeConfig.bannerUrl != data.bannerUrl) {
        _storeConfig = data;
        notifyListeners();
      }
    }, onError: (e) => AppLogger.error("Config stream error", e));

    _categorySub = _repository.getCategories().listen((data) {
      _categoryObjects = data;
      notifyListeners();
    }, onError: (e) => AppLogger.error("Category stream error", e));

    _featuredSub = _repository.getFeaturedProducts().listen((data) {
      _featuredProducts = data;
      notifyListeners();
    }, onError: (e) => AppLogger.error("Featured stream error", e));

    _latestSub = _repository.getLatestProducts().listen((data) {
      _latestProducts = data;
      notifyListeners();
    }, onError: (e) => AppLogger.error("Latest stream error", e));

    _popularSub = _repository.getPopularProducts().listen((data) {
      _popularProducts = data;
      notifyListeners();
    }, onError: (e) => AppLogger.error("Popular stream error", e));
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
    }, onError: (e) => AppLogger.error("Wishlist sync error", e));
  }

  void _stopWishlistSubscription() {
    _wishlistSubscription?.cancel();
    _wishlistIds = [];
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    try {
      final products = await _repository.getAllProducts(limit: 100);
      _allProductsCache = products;
      notifyListeners();
    } catch (e) {
      AppLogger.error("Load initial data error", e);
    }
  }

  void selectCategory(String categoryNameOrId) {
    if (categoryNameOrId == 'All Sacred Products' || categoryNameOrId == 'all') {
      _selectedCategoryId = 'all';
    } else {
      if (_categoryObjects.any((c) => c.id == categoryNameOrId)) {
        _selectedCategoryId = categoryNameOrId;
      } else {
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
    _errorMessage = null;
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
      AppLogger.error("Browsing error", e);
      _errorMessage = "Failed to load products. Please try again.";
    } finally {
      _isBrowsingLoading = false;
      notifyListeners();
    }
  }

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

  List<ProductModel> get filteredProducts {
    if (_selectedCategoryId == 'all') {
      return _allProductsCache;
    }
    return _allProductsCache.where((p) => p.categoryId == _selectedCategoryId).toList();
  }
  
  List<ProductModel> get wishlistProducts {
    return _allProductsCache.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  int getProductCountInCategory(String categoryId) {
    return _allProductsCache.where((p) => p.categoryId == categoryId).length;
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
      AppLogger.error("Search error", e);
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
    _configSub?.cancel();
    _categorySub?.cancel();
    _featuredSub?.cancel();
    _latestSub?.cancel();
    _popularSub?.cancel();
    _wishlistSubscription?.cancel();
    super.dispose();
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _repository.addProduct(product);
      await _loadInitialData(); 
      await fetchBrowsingProducts(refresh: true);
      notifyListeners();
    } catch (e) {
      AppLogger.error("Add product error", e);
      _errorMessage = "Failed to add product: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      await _loadInitialData(); 
      await fetchBrowsingProducts(refresh: true);
      notifyListeners();
    } catch (e) {
      AppLogger.error("Update product error", e);
      _errorMessage = "Failed to update product: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      await _loadInitialData(); 
      await fetchBrowsingProducts(refresh: true);
      notifyListeners();
    } catch (e) {
      AppLogger.error("Delete product error", e);
      _errorMessage = "Failed to delete product: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<String> uploadImage(File file, String productId) async {
    return await _repository.uploadProductImage(file, productId);
  }

  UploadTask getUploadTask(File file, String productId) {
    return _repository.getUploadTask(file, productId);
  }

  Future<void> deleteImage(String imageUrl) async {
    await _repository.deleteProductImage(imageUrl);
  }

  Stream<List<ProductModel>> getAdminProducts() {
    return _repository.getAdminProducts();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _repository.addCategory(category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _repository.updateCategory(category);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
  }

  Future<bool> hasProductsInCategory(String categoryId) async {
    return await _repository.hasProductsInCategory(categoryId);
  }
}
