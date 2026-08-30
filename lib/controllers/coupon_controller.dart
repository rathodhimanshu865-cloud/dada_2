import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/coupon_model.dart';

class CouponController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CouponModel> _coupons = [];
  bool _isLoading = false;

  List<CouponModel> get coupons => _coupons;
  bool get isLoading => _isLoading;

  CouponController() {
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('coupons').orderBy('createdAt', descending: true).get();
      _coupons = snapshot.docs.map((doc) => CouponModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching coupons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCoupon(CouponModel coupon) async {
    try {
      await _firestore.collection('coupons').add(coupon.toFirestore());
      await fetchCoupons();
    } catch (e) {
      debugPrint('Error adding coupon: $e');
    }
  }

  Future<void> deleteCoupon(String id) async {
    try {
      await _firestore.collection('coupons').doc(id).delete();
      await fetchCoupons();
    } catch (e) {
      debugPrint('Error deleting coupon: $e');
    }
  }

  Future<void> toggleCouponStatus(String id, bool status) async {
    try {
      await _firestore.collection('coupons').doc(id).update({'isActive': status});
      await fetchCoupons();
    } catch (e) {
      debugPrint('Error updating coupon status: $e');
    }
  }
}
