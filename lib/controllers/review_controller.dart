import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewController extends ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> addReview(ReviewModel review) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.addReview(review);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _repository.getProductReviews(productId);
  }

  Stream<List<ReviewModel>> getAllReviews() {
    return _repository.getAllReviews();
  }
  
  Future<void> deleteReview(String reviewId) async {
    await _repository.deleteReview(reviewId);
  }
}
