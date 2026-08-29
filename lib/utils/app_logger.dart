import 'package:flutter/foundation.dart';

/// Centralized logger to control terminal noise.
class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print("[INFO] $message");
    }
  }

  static void error(String message, [dynamic error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint("[ERROR] $message");
      if (error != null) debugPrint(error.toString());
      if (stack != null) debugPrint(stack.toString());
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint("[DEBUG] $message");
    }
  }
}
