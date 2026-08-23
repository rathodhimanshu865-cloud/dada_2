import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductController extends ChangeNotifier {
  List<ProductModel> get featuredProducts => [
    ProductModel(
      id: '1',
      title: 'Devotee Keychain',
      category: 'Keychain',
      price: 150.0,
      originalPrice: 200.0,
      imageUrl: 'https://via.placeholder.com/300x300',
      isNew: true,
    ),
    ProductModel(
      id: '2',
      title: 'Sacred Acrylic Frame',
      category: 'Acrylic Photo Frame',
      price: 500.0,
      originalPrice: 650.0,
      imageUrl: 'https://via.placeholder.com/300x300',
      isNew: true,
    ),
    ProductModel(
      id: '3',
      title: 'Divine Temple Model',
      category: 'Temple',
      price: 1200.0,
      originalPrice: 1500.0,
      imageUrl: 'https://via.placeholder.com/300x300',
    ),
    ProductModel(
      id: '4',
      title: 'Divine Paduka / Footprints',
      category: 'Footprints / Paduka',
      price: 350.0,
      originalPrice: 400.0,
      imageUrl: 'https://via.placeholder.com/300x300',
      isNew: true,
    ),
    ProductModel(
      id: '5',
      title: 'Spiritual Sticker Collection',
      category: 'Sticker',
      price: 50.0,
      originalPrice: 80.0,
      imageUrl: 'https://via.placeholder.com/300x300',
    ),
    ProductModel(
      id: '6',
      title: 'Pouch / Pocket Pin',
      category: 'Pouch / Pocket Pin',
      price: 120.0,
      originalPrice: 150.0,
      imageUrl: 'https://via.placeholder.com/300x300',
      isNew: true,
    ),
    ProductModel(
      id: '7',
      title: 'Rakshasutra / Sacred Thread',
      category: 'Rakshasutra / Sacred Thread',
      price: 100.0,
      originalPrice: 150.0,
      imageUrl: 'https://via.placeholder.com/300x300',
    ),
    ProductModel(
      id: '8',
      title: 'Other Products',
      category: 'Other Products',
      price: 300.0,
      originalPrice: 350.0,
      imageUrl: 'https://via.placeholder.com/300x300',
    ),
  ];
}
