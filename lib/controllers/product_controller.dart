import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import 'package:path/path.dart' as path_helper;

class ProductController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Product> _allProducts = [];
  List<Product> get allProducts => _allProducts;

  List<Product> _visibleProducts = [];
  List<Product> get visibleProducts => _visibleProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _productsSubscription;

  ProductController() {
    _listenToProducts();
  }

  void _listenToProducts() {
    _isLoading = true;
    notifyListeners();

    _productsSubscription = _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _allProducts = snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
      _visibleProducts = _allProducts.where((p) => p.visible).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error listening to products: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  // --- CRUD Operations ---

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  Future<void> toggleVisibility(String id, bool currentStatus) async {
    await _firestore.collection('products').doc(id).update({'visible': !currentStatus});
  }

  // --- Helpers ---

  String generateSlug(String title) {
    return title
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  Future<String> uploadProductImage(String fileName, Uint8List bytes) async {
    final uploadName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final reference = _storage.ref('products/$uploadName');
    
    final ext = path_helper.extension(fileName).replaceFirst('.', '').toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
    
    final task = reference.putData(bytes, SettableMetadata(contentType: mimeType));
    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }
  
  Product? getProductBySlug(String slug) {
    try {
      return _allProducts.firstWhere((p) => p.slug == slug);
    } catch (e) {
      return null;
    }
  }
}
