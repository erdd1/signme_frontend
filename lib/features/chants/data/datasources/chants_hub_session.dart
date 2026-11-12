import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_client.dart';

/// Accès au hub Chants, service SÉPARÉ de l'API principale.
///
/// L'API principale ne fait que délivrer un jeton de 15 min et l'adresse du
/// hub ; ensuite l'app parle directement au hub. Si le hub est lent ou arrêté,
/// seules les fonctions Chants le sentent : le reste de SignMe est intact.
class ChantsHubSession {
  ChantsHubSession(this._mainDio, {Dio Function(String url, Interceptor auth)? hubDioBuilder})
      : _hubDioBuilder = hubDioBuilder ?? ((url, auth) => buildHubDioClient(url, auth: auth));

  final Dio _mainDio;
  final Dio Function(String url, Interceptor auth) _hubDioBuilder;

  /// Marge avant l'expiration : on renouvelle le jeton avant qu'il ne casse une requête.
  static const _marge = Duration(seconds: 60);

  String? _token;
  DateTime? _expiration;
  String? _hubUrl;
  Dio? _hubDio;
  Future<void>? _renouvellement;

  /// Client prêt à l'emploi (jeton valide, bonne adresse).
  Future<Dio> client() async {
    await _assurerJeton();
    return _hubDio!;
  }

  /// Oublie le jeton (ex. 401 reçu du hub) : le prochain appel en redemande un.
  void invalider() => _expiration = null;

  Future<void> _assurerJeton() {
    final valide = _token != null && _expiration != null && _expiration!.isAfter(DateTime.now().add(_marge));
    if (valide && _hubDio != null) return Future.value();

    // Un seul renouvellement à la fois, même si dix écrans demandent en même temps.
    return _renouvellement ??= _renouveler().whenComplete(() => _renouvellement = null);
  }

  Future<void> _renouveler() async {
    final Response<dynamic> resp;
    try {
      resp = await _mainDio.post(ApiConfig.chantsToken);
    } on DioException catch (e) {
      // 503 = hub désactivé côté serveur ; réseau/timeout = erreurs typées de l'intercepteur.
      if (e.error is AppException) throw e.error as AppException;
      throw ServerException(message: 'Le répertoire de chants est momentanément indisponible.');
    }

    final data = ApiResponseParser.dataMap(resp.data);
    final token = data?['token']?.toString();
    final hubUrl = data?['hub_url']?.toString();
    if (!ApiResponseParser.isSuccess(resp.data) || token == null || hubUrl == null) {
      throw ServerException(message: 'Le répertoire de chants est momentanément indisponible.');
    }

    final secondes = (data?['expires_in'] as num?)?.toInt() ?? 900;
    _token = token;
    _expiration = DateTime.now().add(Duration(seconds: secondes));

    if (_hubDio == null || _hubUrl != hubUrl) {
      _hubUrl = hubUrl;
      _hubDio = _hubDioBuilder(hubUrl, _HubAuthInterceptor(this));
    }
  }
}

/// Ajoute le jeton à chaque requête ; sur 401, en redemande un et rejoue UNE fois.
class _HubAuthInterceptor extends Interceptor {
  _HubAuthInterceptor(this._session);

  final ChantsHubSession _session;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer ${_session._token}';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final dejaRejoue = err.requestOptions.extra['hub_retry'] == true;
    if (err.response?.statusCode != 401 || dejaRejoue) return handler.next(err);

    try {
      _session.invalider();
      final dio = await _session.client();
      err.requestOptions.extra['hub_retry'] = true;
      err.requestOptions.headers['Authorization'] = 'Bearer ${_session._token}';
      return handler.resolve(await dio.fetch(err.requestOptions));
    } on DioException catch (e) {
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }
}
