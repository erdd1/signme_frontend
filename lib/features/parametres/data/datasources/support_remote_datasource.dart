import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';

/// Datasource — Contact du service client (WhatsApp).
class SupportRemoteDataSource {
  SupportRemoteDataSource(this._dio);

  final Dio _dio;

  /// Retourne le lien WhatsApp du support (ex. https://wa.me/237699803165),
  /// servi par le serveur plutôt que codé en dur dans l'application.
  Future<String> whatsappLink() async {
    try {
      final resp = await _dio.get(ApiConfig.supportWhatsapp);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        final link = data?['link'] as String?;
        if (link == null || link.isEmpty) {
          throw ServerException(message: 'Lien du service client indisponible.');
        }
        return link;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
