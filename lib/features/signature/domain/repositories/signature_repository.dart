import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../entities/member_signature_status.dart';
import '../entities/payment_transaction_status.dart';
import '../entities/signature_entity.dart';

abstract class SignatureRepository {
  Future<MaCarteData> getMaCarte(int year);
  Future<DistancePaymentInitResult> initiateDistancePayment({
    required List<String> months,
    required int amount,
    required String paymentMethod,
    String? paymentOperator,
    String? phoneNumber,
  });
  Future<PaymentTransactionStatus> getTransactionStatus(int transactionId);
  Future<bool> initiatePresentielSignature({
    required int userId,
    required List<String> months,
    required int amount,
  });
  Future<List<UserEntity>> searchMembers(String query);
  Future<List<UserEntity>> getPasteurMembers();
  Future<MemberSignatureStatus?> getMemberStatus(int userId, String monthParam);
  Future<Map<String, dynamic>?> canSignPresentielNow();
}

class SignatureRepositoryImpl implements SignatureRepository {
  SignatureRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<MaCarteData> getMaCarte(int year) async {
    try {
      final resp = await _dio.get(
        ApiConfig.signatureMaCarte,
        queryParameters: {'year': year},
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse carte invalide');
        return MaCarteData.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  @override
  Future<DistancePaymentInitResult> initiateDistancePayment({
    required List<String> months,
    required int amount,
    required String paymentMethod,
    String? paymentOperator,
    String? phoneNumber,
  }) async {
    try {
      final resp = await _dio.post(
        ApiConfig.signatureDistance,
        data: {
          'months': months,
          'amount': amount,
          'paymentMethod': paymentMethod,
          if (paymentOperator != null) 'paymentOperator': paymentOperator,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );
      if ((resp.statusCode == 201 || resp.statusCode == 200) &&
          ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse paiement invalide');
        }
        return DistancePaymentInitResult.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  @override
  Future<PaymentTransactionStatus> getTransactionStatus(
    int transactionId,
  ) async {
    try {
      final resp = await _dio.get(
        ApiConfig.signatureTransactionStatus(transactionId),
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data != null) {
          return PaymentTransactionStatus.fromJson(data);
        }
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  @override
  Future<bool> initiatePresentielSignature({
    required int userId,
    required List<String> months,
    required int amount,
  }) async {
    try {
      final resp = await _dio.post(
        ApiConfig.signaturePresentiel,
        data: {'userId': userId, 'months': months, 'amount': amount},
      );
      return resp.statusCode == 201 && ApiResponseParser.isSuccess(resp.data);
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  @override
  Future<List<UserEntity>> searchMembers(String query) async {
    try {
      final resp = await _dio.get(
        ApiConfig.users,
        queryParameters: {'search': query, 'per_page': 20},
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map(UserModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<List<UserEntity>> getPasteurMembers() async {
    try {
      final resp = await _dio.get(ApiConfig.usersPasteur);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map(UserModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<MemberSignatureStatus?> getMemberStatus(
    int userId,
    String monthParam,
  ) async {
    try {
      final resp = await _dio.get(
        ApiConfig.signatureMemberStatus(userId),
        queryParameters: {'month': monthParam},
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data != null) return MemberSignatureStatus.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<Map<String, dynamic>?> canSignPresentielNow() async {
    try {
      final resp = await _dio.get('${ApiConfig.users}/can-sign-presentiel');
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.dataMap(resp.data);
      }
    } catch (_) {}
    return null;
  }
}

final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  return SignatureRepositoryImpl(ref.watch(dioProvider));
});
