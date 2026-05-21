import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/historique_personnel_entity.dart';
import '../../data/models/historique_personnel_model.dart';

/// Provider pour obtenir l'historique personnel (signatures à distance)
/// C'est l'historique des signatures à distance de l'utilisateur connecté
final historiquePersonnelProvider =
    FutureProvider.family<List<HistoriquePersonnelEntity>, Map<String, dynamic>>((
  ref,
  filters,
) async {
  final dio = ref.watch(dioProvider); // Utilise le dio avec authentification
  final baseUrl = 'http://localhost:8000/api/v1';

  try {
    // Construire les query parameters - TOUS doivent être String pour Dio
    final queryParams = <String, String>{};
    if (filters.containsKey('month')) {
      queryParams['month'] = filters['month'].toString();
    }
    if (filters.containsKey('status')) {
      queryParams['status'] = filters['status'].toString();
    }
    if (filters.containsKey('year')) {
      queryParams['year'] = filters['year'].toString();
    }
    queryParams['per_page'] = (filters['per_page'] ?? 20).toString();

    // GET /api/v1/signatures/historique-personnel
    // Endpoint à créer côté backend pour retourner UNIQUEMENT les signatures de l'utilisateur connecté
    final response = await dio.get(
      '/signatures/historique-personnel',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      final signatures = data
          .map((s) {
            final model = HistoriquePersonnelModel.fromJson(s);
            return HistoriquePersonnelEntity(
              id: model.id,
              userId: model.userId,
              nomUtilisateur: model.nomUtilisateur,
              month: model.month,
              year: model.year,
              status: model.status,
              amount: model.amount,
              fees: model.fees,
              signatureType: model.signatureType,
              paymentMethod: model.paymentMethod,
              paymentPhoneNumber: model.paymentPhoneNumber,
              createdAt: model.createdAt,
              completedAt: model.completedAt,
              errorMessage: model.errorMessage,
            );
          })
          .toList()
          .cast<HistoriquePersonnelEntity>();

      return signatures;
    } else {
      throw Exception('Failed to fetch historique personnel: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching historique personnel: $e');
  }
});

/// Provider pour rafraîchir l'historique personnel
final refreshHistoriquePersonnelProvider = FutureProvider.family<void, Map<String, dynamic>>((
  ref,
  filters,
) async {
  ref.invalidate(historiquePersonnelProvider);
});
