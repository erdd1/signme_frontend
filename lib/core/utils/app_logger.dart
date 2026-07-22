import 'package:flutter/foundation.dart';
import '../config/app_environment.dart';

/// Journalisation centralisée — désactivée en release pour limiter les fuites d'info.
abstract final class AppLogger {
  static void debug(String message) {
    if (kDebugMode || AppEnvironment.enableApiLogs) {
      debugPrint('[SignMe] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[SignMe][ERROR] $message${error != null ? ': $error' : ''}');
    }
  }
}
