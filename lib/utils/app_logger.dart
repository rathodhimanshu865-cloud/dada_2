import 'package:flutter/foundation.dart';

/// Centralized logger to control terminal noise.
class AppLogger {
  static void info(String message) {
    // Silenced by default to prevent terminal overflow and hanging
  }

  static void error(String message, [dynamic error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint("[ERROR] $message");
      // Only print error details if specifically needed
      // if (error != null) debugPrint(error.toString());
    }
  }

  static void debug(String message) {
    // Silenced by default
  }
}
