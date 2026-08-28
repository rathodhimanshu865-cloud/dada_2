import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityController extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ConnectivityController() {
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateState(results);
  }

  void _updateState(List<ConnectivityResult> results) {
    // connectivity_plus 6.0+ returns a list. If any result is not 'none', we are "online"
    final bool online = !results.contains(ConnectivityResult.none);
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
