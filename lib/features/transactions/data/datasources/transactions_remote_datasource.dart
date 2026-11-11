import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionsRemoteDataSource {
  TransactionsRemoteDataSource(this._dio);

  final Dio _dio;

  /// Transactions de l'utilisateur connecté, de la plus récente à la plus
  /// ancienne. [statut] : completed | pending | failed ; [type] :
  /// contribution | don | signature.
  Future<TransactionsPage> list({
    int page = 1,
    int perPage = 20,
    String? query,
    String? statut,
    String? type,
    CancelToken? cancelToken,
  }) async {
    try {
      final resp = await _dio.get(
        ApiConfig.transactions,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (query != null && query.isNotEmpty) 'q': query,
          if (statut != null) 'statut': statut,
          if (type != null) 'type': type,
        },
        cancelToken: cancelToken,
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final body = resp.data as Map<String, dynamic>;
        final pagination = body['pagination'] as Map<String, dynamic>?;

        return TransactionsPage(
          items: ApiResponseParser.extractList(body).map(TransactionEntity.fromJson).toList(),
          currentPage: (pagination?['current_page'] as num?)?.toInt() ?? page,
          lastPage: (pagination?['last_page'] as num?)?.toInt() ?? page,
        );
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
