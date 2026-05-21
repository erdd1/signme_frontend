import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/historique_signatures_entity.dart';
import '../../data/models/historique_signatures_model.dart';

/// Provider pour obtenir l'historique des signatures en présentiel
/// C'est l'historique des signatures effectuées PAR l'utilisateur connecté (ancien/pasteur)
/// Uniquement pour les anciens/pasteurs
final historiqueSignaturesProvider =
    FutureProvider.family<List<HistoriqueSignaturesEntity>, Map<String, dynamic>>((
  ref,
  filters,
) async {
  final dio = ref.watch(dioProvider); // Utilise le dio avec authentification
  final baseUrl = 'http://localhost:8000/api/v1';

  try {
    // Construire les query parameters - TOUS les paramètres doivent être des Strings
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
    if (filters.containsKey('userId')) {
      queryParams['userId'] = filters['userId'].toString();
    }
    queryParams['per_page'] = (filters['per_page'] ?? 20).toString();

    // GET /api/v1/signatures/historique-signatures
    // Endpoint à créer côté backend pour retourner les signatures effectuées par l'utilisateur connecté
    final response = await dio.get(
      '/signatures/historique-signatures',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      final signatures = data
          .map((s) {
            final model = HistoriqueSignaturesModel.fromJson(s);
            return HistoriqueSignaturesEntity(
              id: model.id,
              userId: model.userId,
              nomParoissien: model.nomParoissien,
              emailParoissien: model.emailParoissien,
              ancienId: model.ancienId,
              nomAncien: model.nomAncien,
              month: model.month,
              year: model.year,
              status: model.status,
              amount: model.amount,
              fees: model.fees,
              signatureType: model.signatureType,
              location: model.location,
              churchId: model.churchId,
              churchName: model.churchName,
              createdAt: model.createdAt,
              completedAt: model.completedAt,
              notes: model.notes,
            );
          })
          .toList()
          .cast<HistoriqueSignaturesEntity>();

      return signatures;
    } else {
      throw Exception('Failed to fetch historique signatures: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching historique signatures: $e');
  }
});

/// Provider pour rafraîchir l'historique des signatures
final refreshHistoriqueSignaturesProvider = FutureProvider.family<void, Map<String, dynamic>>((
  ref,
  filters,
) async {
  ref.invalidate(historiqueSignaturesProvider);
});
