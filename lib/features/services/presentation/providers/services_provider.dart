import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/service_entity.dart';

/// Rubriques de l'écran Services.
abstract final class ServiceSections {
  static const monEglise = 'Mon église';
}

/// Catalogue des services. Ajouter un service = ajouter une entrée ici
/// (et sa route) ; `availableFor` restreint par rôle si besoin.
final List<ServiceEntity> servicesCatalog = [
  const ServiceEntity(
    id: 'don',
    label: 'Faire un don',
    icon: Icons.volunteer_activism_rounded,
    section: ServiceSections.monEglise,
    route: AppRoutes.servicesDon,
  ),
];

/// Services disponibles pour l'utilisateur connecté.
final availableServicesProvider = Provider<List<ServiceEntity>>((ref) {
  final user = ref.watch(authNotifierProvider).auth?.user;
  if (user == null) return const [];

  return servicesCatalog.where((s) => s.isAvailableFor(user)).toList();
});
