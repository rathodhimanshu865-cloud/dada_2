import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<NotificationModel> _notifications = [];
  StreamSubscription? _subscription;
  bool _isDisposed = false;

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationController() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startSubscription(user.uid);
      } else {
        _stopSubscription();
      }
    });
  }

  void _startSubscription(String uid) {
    _subscription?.cancel();
    _subscription = _repository.getNotifications(uid).listen((data) {
      _notifications = data;
      _safeNotifyListeners();
    });
  }

  void _stopSubscription() {
    _subscription?.cancel();
    _notifications = [];
    _safeNotifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _repository.markAsRead(user.uid, id);
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _repository.markAllAsRead(user.uid);
  }

  Future<void> deleteNotification(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _repository.deleteNotification(user.uid, id);
  }

  // System methods to send notifications (usually called from other controllers)
  Future<void> sendOrderNotification({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    String title = 'Order Update';
    String message = 'Your order $orderId is now $status.';
    
    if (status == 'Pending') {
      title = 'Order Placed';
      message = 'Your order $orderId has been successfully placed.';
    }

    await _repository.sendNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'order',
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
