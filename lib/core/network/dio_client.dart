import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

/// Construit et configure l'instance Dio avec interceptors Auth + Error
Dio buildDioClient(SecureStorage storage) {
  final dio = Dio(BaseOptions(
    baseUrl:        ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept':       'application/json',
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.addAll([
    _AuthInterceptor(storage, dio),
    _ErrorInterceptor(),
  ]);

  return dio;
}

// ── Auth Interceptor ─────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._dio);

  final SecureStorage _storage;
  final Dio           _dio;
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
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          // Rejouer la requête originale avec le nouveau token
          final token = await _storage.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          final cloneReq = await _dio.fetch(err.requestOptions);
          _isRefreshing = false;
          return handler.resolve(cloneReq);
        }
      } catch (_) {}
      _isRefreshing = false;
      // Token refresh échoué → clear session
      await _storage.clearSession();
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
      await _storage.saveAccessToken(data['access_token']?.toString() ?? '');
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
        final msg  = err.response?.data?['message']?.toString();
        final errs = _parseErrors(err.response?.data);

        switch (code) {
          case 401:
            return handler.reject(
              err.copyWith(error: AuthException(message: msg ?? 'Non authentifié')),
            );
          case 403:
            return handler.reject(
              err.copyWith(error: ForbiddenException(message: msg ?? 'Accès refusé')),
            );
          case 404:
            return handler.reject(
              err.copyWith(error: NotFoundException(message: msg ?? 'Introuvable')),
            );
          case 422:
            return handler.reject(
              err.copyWith(error: ValidationException(message: msg ?? 'Validation échouée', errors: errs)),
            );
          default:
            return handler.reject(
              err.copyWith(error: ServerException(message: msg ?? 'Erreur serveur')),
            );
        }

      default:
        handler.next(err);
    }
  }

  Map<String, List<String>> _parseErrors(dynamic data) {
    try {
      final raw = data?['errors'] as Map<String, dynamic>?;
      if (raw == null) return {};
      return raw.map((k, v) => MapEntry(
        k,
        (v as List).map((e) => e.toString()).toList(),
      ));
    } catch (_) {
      return {};
    }
  }
}
