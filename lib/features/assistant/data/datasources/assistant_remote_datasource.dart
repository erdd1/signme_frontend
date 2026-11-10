import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/assistant_message_entity.dart';

class AssistantRemoteDataSource {
  AssistantRemoteDataSource(this._dio);

  final Dio _dio;

  /// Envoie la conversation (le dernier message est la question) et renvoie
  /// la réponse de l'assistant. Le moteur peut mettre jusqu'à ~30 s à
  /// répondre : le délai de réception est donc plus large que celui par défaut.
  Future<String> chat(List<AssistantMessageEntity> conversation) async {
    try {
      final resp = await _dio.post(
        ApiConfig.assistantChat,
        data: {'messages': conversation.map((m) => m.toJson()).toList()},
        options: Options(receiveTimeout: const Duration(seconds: 45)),
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final reply = ApiResponseParser.dataMap(resp.data)?['reply']?.toString();
        if (reply != null && reply.trim().isNotEmpty) return reply.trim();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
