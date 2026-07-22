import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Extrait une [AppException] depuis une [DioException] (intercepteur Dio).
Never throwFromDio(DioException e) {
  if (e.error is AppException) throw e.error as AppException;
  throw ServerException(message: e.message ?? 'Erreur réseau');
}

String messageFromError(Object e) {
  if (e is AppException) return e.message;
  return 'Une erreur inattendue s\'est produite.';
}
