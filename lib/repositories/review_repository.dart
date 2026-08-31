import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview(ReviewModel review) async {
    final batch = _firestore.batch();
    
    // Add review
    final reviewRef = _firestore.collection('reviews').doc();
    batch.set(reviewRef, review.toFirestore());
    
    // Update product rating and review count
    final productRef = _firestore.collection('products').doc(review.productId);
    
    // Note: In a production app, we would use a Cloud Function for this 
    // to avoid race conditions and ensure accuracy. 
    // Here we'll do it client-side for simplicity.
    final productDoc = await productRef.get();
    if (productDoc.exists) {
      final data = productDoc.data()!;
      int count = data['reviewCount'] ?? 0;
      double currentRating = (data['rating'] ?? 0.0).toDouble();
      
      double newRating = ((currentRating * count) + review.rating) / (count + 1);
      
      batch.update(productRef, {
        'rating': newRating,
        'reviewCount': count + 1,
      });
    }

    await batch.commit();
  }

  Stream<List<ReviewModel>> getProductReviews(String productId) {
    // Note: If this query hangs, please check the Firebase Console for missing index errors.
    // Filter by product ID and order by most recent.
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
           final reviews = snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
           // Sort locally to avoid mandatory composite index errors while debugging
           reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
           return reviews;
        });
  }

  Stream<List<ReviewModel>> getAllReviews() {
    return _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  }
  
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }
}
