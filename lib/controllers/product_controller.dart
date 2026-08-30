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

  bool _isDisposed = false;

  Timer? _notifyTimer;
  void _safeNotifyListeners() {
    if (_isDisposed) return;
    
    // Throttle notifications to max 10 times per second to prevent UI saturation
    if (_notifyTimer?.isActive ?? false) return;
    
    _notifyTimer = Timer(const Duration(milliseconds: 100), () {
      if (!_isDisposed) notifyListeners();
    });
  }

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
  StreamSubscription? _allProductsSub;
  StreamSubscription? _wishlistSubscription;

  // Stream Getters for Backward Compatibility
  Stream<StoreConfigModel> get storeConfigStream => _repository.getStoreConfig();
  Stream<List<CategoryModel>> get categoriesStream => _repository.getCategories();
  Stream<List<ProductModel>> get featuredProductsStream => _repository.getFeaturedProducts();
  Stream<List<ProductModel>> get latestProductsStream => _repository.getLatestProducts();
  Stream<List<ProductModel>> get popularProductsStream => _repository.getPopularProducts();
  Stream<List<ProductModel>> get allProductsStream => _repository.getAllProductsStream();

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
  String? _browsingErrorMessage;

  // Category State
  String _selectedCategoryId = 'all'; 
  
  // Search state
  String _searchQuery = '';
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? get browsingErrorMessage => _browsingErrorMessage;
  String get selectedCategoryId => _selectedCategoryId;

  void clearError() {
    _errorMessage = null;
    _browsingErrorMessage = null;
    _safeNotifyListeners();
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
        _safeNotifyListeners();
      }
    }, onError: (e) => AppLogger.error("Config stream error", e));

    _categorySub = _repository.getCategories().listen((data) {
      if (_categoryObjects.length != data.length) {
        _categoryObjects = data;
        _safeNotifyListeners();
      }
    }, onError: (e) => AppLogger.error("Category stream error", e));

    _featuredSub = _repository.getFeaturedProducts().listen((data) {
      if (_featuredProducts.length != data.length) {
        _featuredProducts = data;
        _safeNotifyListeners();
      }
    }, onError: (e) => AppLogger.error("Featured stream error", e));

    _latestSub = _repository.getLatestProducts().listen((data) {
      if (_latestProducts.length != data.length) {
        _latestProducts = data;
        _safeNotifyListeners();
      }
    }, onError: (e) => AppLogger.error("Latest stream error", e));

    _popularSub = _repository.getPopularProducts().listen((data) {
      if (_popularProducts.length != data.length) {
        _popularProducts = data;
        _safeNotifyListeners();
      }
    }, onError: (e) => AppLogger.error("Popular stream error", e));

    _allProductsSub = _repository.getAllProductsStream().listen((data) {
      // Robust change detection
      bool changed = _allProductsCache.length != data.length;
      if (!changed && data.isNotEmpty && _allProductsCache.isNotEmpty) {
        changed = data[0].id != _allProductsCache[0].id || 
                  data.last.id != _allProductsCache.last.id;
      }
      
      if (changed) {
        _allProductsCache = data;
        _safeNotifyListeners();
      }
    }, onError: (e) => AppLogger.error("All products stream error", e));
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
      _safeNotifyListeners();
    }, onError: (e) => AppLogger.error("Wishlist sync error", e));
  }

  void _stopWishlistSubscription() {
    _wishlistSubscription?.cancel();
    _wishlistIds = [];
    _safeNotifyListeners();
  }

  Future<void> _loadInitialData() async {
    try {
      // Don't await, let it load in background to speed up app start
      _repository.getAllProducts(limit: 100).then((products) {
        _allProductsCache = products;
        _safeNotifyListeners();
      });
    } catch (e) {
      AppLogger.error("Load initial data error", e);
    }
  }

  void selectCategory(String categoryNameOrId) {
    final search = categoryNameOrId.toLowerCase().trim();
    String newId = 'all';

    if (search != 'all sacred products' && search != 'all' && search != '') {
      // 1. Try matching by ID first
      final matchedById = _categoryObjects.where((c) => c.id.toLowerCase() == search || c.id == categoryNameOrId);
      if (matchedById.isNotEmpty) {
        newId = matchedById.first.id;
      } else {
        // 2. Try matching by Name
        final matchedByName = _categoryObjects.where((c) => c.name.toLowerCase() == search);
        if (matchedByName.isNotEmpty) {
          newId = matchedByName.first.id;
        } else {
          newId = categoryNameOrId;
        }
      }
    }
    
    if (_selectedCategoryId != newId) {
      _selectedCategoryId = newId;
      // Only fetch if it actually changed to prevent loops
      fetchBrowsingProducts(refresh: true);
      _safeNotifyListeners();
    }
  }

  Future<void> fetchBrowsingProducts({bool refresh = false}) async {
    if (_isBrowsingLoading) return;
    if (!refresh && !_hasMore) return;

    if (refresh) {
      _browsingProducts.clear();
      _hasMore = true;
    }

    _isBrowsingLoading = true;
    _browsingErrorMessage = null;
    // Notify once when loading starts
    _safeNotifyListeners();

    try {
      final products = await _repository.getFilteredProducts(
        categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        onlyInStock: onlyInStock,
        sortBy: sortBy,
        descending: sortDescending,
        limit: 100 
      );

      if (products.length < 100) _hasMore = false;
      _browsingProducts.addAll(products);
      
    } catch (e) {
      // Errors are handled by AppLogger or silenced to prevent crashes
    } finally {
      _isBrowsingLoading = false;
      // Notify once when loading ends
      _safeNotifyListeners();
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
    if (productId.isEmpty) return Stream.value(null);
    return _repository.getProductDetails(productId);
  }

  List<ProductModel> get filteredProducts {
    if (_selectedCategoryId == 'all') {
      return _allProductsCache;
    }
    final targetId = _selectedCategoryId.toLowerCase().trim();
    return _allProductsCache.where((p) => p.categoryId.toLowerCase().trim() == targetId).toList();
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
      _safeNotifyListeners();
      return;
    }

    _isSearching = true;
    _safeNotifyListeners();

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
      _safeNotifyListeners();
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
    _isDisposed = true;
    _configSub?.cancel();
    _categorySub?.cancel();
    _featuredSub?.cancel();
    _latestSub?.cancel();
    _popularSub?.cancel();
    _allProductsSub?.cancel();
    _wishlistSubscription?.cancel();
    super.dispose();
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      // Optimistic cache update for both Admin and User-side lists
      _allProductsCache.insert(0, product);
      if (_selectedCategoryId == 'all' || _selectedCategoryId == product.categoryId) {
        _browsingProducts.insert(0, product);
      }
      _safeNotifyListeners();

      await _repository.addProduct(product);
      
      // Background refreshes (don't await) to ensure server sync
      _loadInitialData(); 
      fetchBrowsingProducts(refresh: true);
    } catch (e) {
      AppLogger.error("Add product error", e);
      _errorMessage = "Failed to add product: $e";
      // Rollback on error
      _allProductsCache.removeWhere((p) => p.id == product.id);
      _browsingProducts.removeWhere((p) => p.id == product.id);
      _safeNotifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      // Optimistic cache update for immediate UI feedback in non-streamed views
      final idx = _allProductsCache.indexWhere((p) => p.id == product.id);
      if (idx != -1) {
        _allProductsCache[idx] = product;
        _safeNotifyListeners();
      }

      await _repository.updateProduct(product);
      
      // Background refreshes (don't await) to ensure sync with server
      _loadInitialData(); 
      fetchBrowsingProducts(refresh: true);
    } catch (e) {
      AppLogger.error("Update product error", e);
      _errorMessage = "Failed to update product: $e";
      _safeNotifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _allProductsCache.removeWhere((p) => p.id == productId);
      _safeNotifyListeners();

      await _repository.deleteProduct(productId);
      
      _loadInitialData(); 
      fetchBrowsingProducts(refresh: true);
    } catch (e) {
      AppLogger.error("Delete product error", e);
      _errorMessage = "Failed to delete product: $e";
      _safeNotifyListeners();
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

  Future<void> performMigration() async {
    try {
      _errorMessage = "Migrating 'radhe_' to 'Keychain'...";
      _safeNotifyListeners();
      
      await _repository.migrateCategory('radhe_', 'keychain');
      
      _errorMessage = null;
      _safeNotifyListeners();
      
      // Refresh local data
      _loadInitialData();
      fetchBrowsingProducts(refresh: true);
    } catch (e) {
      _errorMessage = "Migration failed: $e";
      _safeNotifyListeners();
    }
  }
}
