// ── Exceptions typées ──────────────────────────────────────────────────────────

class AppException implements Exception {
  AppException({required this.message, this.statusCode});
  final String message;
  final int?   statusCode;

  @override
  String toString() => message;
}

/// 401 — Token invalide / expiré
class AuthException extends AppException {
  AuthException({required super.message}) : super(statusCode: 401);
}

/// 422 — Validation échouée
class ValidationException extends AppException {
  ValidationException({required super.message, this.errors = const {}})
      : super(statusCode: 422);

  final Map<String, List<String>> errors;

  String get firstError {
    if (errors.isNotEmpty) return errors.values.first.first;
    return message;
  }
}

/// 429 — Trop de requêtes (rate limit / brute force)
class RateLimitException extends AppException {
  RateLimitException({
    required super.message,
    this.retryAfterSeconds,
  }) : super(statusCode: 429);

  final int? retryAfterSeconds;
}

/// 403 — Accès interdit
class ForbiddenException extends AppException {
  ForbiddenException({super.message = "Une erreur s'est produite."}) : super(statusCode: 403);
}

/// 404 — Ressource introuvable
class NotFoundException extends AppException {
  NotFoundException({super.message = "Une erreur s'est produite. Veuillez réessayer..."}) : super(statusCode: 404);
}

/// 5xx — Erreur serveur
class ServerException extends AppException {
  ServerException({super.message = "Une erreur s'est produite. Veuillez réessayer..."}) : super(statusCode: 500);
}

/// Pas de connexion internet
class NetworkException extends AppException {
  NetworkException({super.message = 'Vérifiez votre connexion internet.'});
}

/// Timeout
class TimeoutException extends AppException {
  TimeoutException({super.message = 'La connexion a expiré. Réessayez.'});
}

/// Erreur inconnue
class UnknownException extends AppException {
  UnknownException({super.message = 'Une erreur inattendue s\'est produite.'});
}
