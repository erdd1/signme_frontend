/// Helpers pour parser les réponses JSON de l'API Laravel (enveloppe standard).
abstract final class ApiResponseParser {
  static bool isSuccess(dynamic body) {
    if (body is! Map<String, dynamic>) return false;
    return body['success'] == true;
  }

  static Map<String, dynamic>? dataMap(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final data = body['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  /// Extrait une liste depuis `data` (liste plate ou pagination Laravel).
  static List<Map<String, dynamic>> extractList(dynamic body) {
    if (body is! Map<String, dynamic>) return const [];

    final data = body['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  static String message(dynamic body, {String fallback = 'Une erreur est survenue.'}) {
    if (body is Map<String, dynamic>) {
      return body['message']?.toString() ?? fallback;
    }
    return fallback;
  }
}
