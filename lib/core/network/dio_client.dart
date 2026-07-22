import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../config/app_environment.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

typedef SessionExpiredCallback = Future<void> Function();

/// Construit et configure l'instance Dio avec interceptors Auth + Error
Dio buildDioClient(
  SecureStorage storage, {
  SessionExpiredCallback? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.addAll([
    _AuthInterceptor(storage, dio, onSessionExpired: onSessionExpired),
    _ErrorInterceptor(),
  ]);

  if (kDebugMode && AppEnvironment.enableApiLogs) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[HTTP] $o'),
      ),
    );
  }

  return dio;
}

// ── Auth Interceptor ─────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(
    this._storage,
    this._dio, {
    this.onSessionExpired,
  });

  final SecureStorage _storage;
  final Dio _dio;
  final SessionExpiredCallback? onSessionExpired;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;

    // Ne pas tenter de refresh sur les routes d'authentification et de réinitialisation
    if (path.contains('/auth/login') ||
        path.contains('/auth/google') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/verify-password-reset-otp') ||
        path.contains('/auth/resend-password-reset-otp') ||
        path.contains('/auth/confirm-password-reset') ||
        path.contains('/auth/reset-password')) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          final token = await _storage.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          final cloneReq = await _dio.fetch(err.requestOptions);
          _isRefreshing = false;
          return handler.resolve(cloneReq);
        }
      } catch (_) {}
      _isRefreshing = false;
      await _storage.clearSession();
      await onSessionExpired?.call();
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    final resp = await _dio.post(
      ApiConfig.refreshToken,
      data: {'refresh_token': refresh},
    );

    if (resp.statusCode == 200 && resp.data['success'] == true) {
      final data = resp.data['data'] as Map<String, dynamic>;
      final access = data['access_token']?.toString() ?? '';
      if (access.isEmpty) return false;
      await _storage.saveAccessToken(access);
      if (data['refresh_token'] != null) {
        await _storage.saveRefreshToken(data['refresh_token'].toString());
      }
      return true;
    }
    return false;
  }
}

// ── Error Interceptor ────────────────────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return handler.reject(
          err.copyWith(error: TimeoutException()),
        );

      case DioExceptionType.connectionError:
        return handler.reject(
          err.copyWith(error: NetworkException()),
        );

      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        final msg = err.response?.data?['message']?.toString();
        final errs = _parseErrors(err.response?.data);

        switch (code) {
          case 401:
            return handler.reject(
              err.copyWith(
                error: AuthException(
                  message: msg ?? 'Non authentifié. Veuillez vous connecter.',
                ),
              ),
            );
          case 403:
            return handler.reject(
              err.copyWith(
                error: ForbiddenException(
                  message: msg ?? 'Une erreur s\'est produite.',
                ),
              ),
            );
          case 404:
            return handler.reject(
              err.copyWith(
                error: NotFoundException(
                  message: msg ?? 'Une erreur s\'est produite.',
                ),
              ),
            );
          case 422:
            return handler.reject(
              err.copyWith(
                error: ValidationException(
                  message: msg ?? 'Validation échouée',
                  errors: errs,
                ),
              ),
            );
          case 429:
            return handler.reject(
              err.copyWith(
                error: RateLimitException(
                  message: msg ??
                      'Trop de tentatives. Patientez avant de réessayer.',
                  retryAfterSeconds: _parseRetryAfter(err.response),
                ),
              ),
            );
          default:
            return handler.reject(
              err.copyWith(
                error: ServerException(
                  message: msg ?? 'Une erreur s\'est produite.',
                ),
              ),
            );
        }

      default:
        handler.next(err);
    }
  }

  int? _parseRetryAfter(Response<dynamic>? response) {
    if (response == null) return null;
    final header = response.headers.value('retry-after');
    if (header != null) {
      final parsed = int.tryParse(header);
      if (parsed != null) return parsed;
    }
    final data = response.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors['retry_after'] != null) {
        return int.tryParse(errors['retry_after'].toString());
      }
    }
    return null;
  }

  Map<String, List<String>> _parseErrors(dynamic data) {
    try {
      final raw = data?['errors'] as Map<String, dynamic>?;
      if (raw == null) return {};
      return raw.map(
        (k, v) => MapEntry(
          k,
          (v as List).map((e) => e.toString()).toList(),
        ),
      );
    } catch (_) {
      return {};
    }
  }
}
