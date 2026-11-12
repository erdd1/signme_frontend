import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../groupes/presentation/providers/groupes_provider.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/gestion_evenement.dart';

/// Rubriques de l'écran Services.
abstract final class ServiceSections {
  static const mesActivites = 'Mes activités';
}

/// Catalogue des services. Ajouter un service = ajouter une entrée ici
/// (et sa route) ; `availableFor` restreint par rôle si besoin.
final List<ServiceEntity> servicesCatalog = [
  const ServiceEntity(
    id: 'don',
    label: 'Faire un don',
    icon: Icons.volunteer_activism_rounded,
    section: ServiceSections.mesActivites,
    route: AppRoutes.servicesDon,
  ),
  ServiceEntity(
    id: 'gestion-evenement',
    label: 'Gestion événement',
    icon: Icons.event_note_rounded,
    section: ServiceSections.mesActivites,
    route: AppRoutes.servicesGestionEvenement,
    availableFor: peutGererEvenements,
  ),
];

/// Un service « Groupe <nom> » par groupe auquel appartient l'utilisateur
/// (ex. « Groupe Cojeunesse »). Liste fraîche du serveur ; à défaut (chargement,
/// hors ligne), les groupes connus du profil. Sans groupe : aucun service.
final groupesServicesProvider = Provider<List<ServiceEntity>>((ref) {
  final user = ref.watch(authNotifierProvider).auth?.user;
  if (user == null) return const [];

  final doServeur = ref.watch(mesGroupesProvider).valueOrNull;
  final groupes = doServeur != null
      ? [for (final g in doServeur) (uuid: g.uuid, nom: g.nom, nonLus: g.nonLus)]
      : [
          for (final g in user.groupes)
            if (g.uuid != null) (uuid: g.uuid!, nom: g.nom, nonLus: 0),
        ];

  return [
    for (final g in groupes)
      ServiceEntity(
        id: 'groupe:${g.uuid}',
        label: 'Groupe ${g.nom}',
        icon: Icons.groups_rounded,
        // Même rubrique que « Faire un don ».
        section: ServiceSections.mesActivites,
        route: AppRoutes.servicesGroupe(g.uuid),
        badgeCount: g.nonLus,
      ),
  ];
});

/// Services disponibles pour l'utilisateur connecté.
final availableServicesProvider = Provider<List<ServiceEntity>>((ref) {
  final user = ref.watch(authNotifierProvider).auth?.user;
  if (user == null) return const [];

  return [
    ...servicesCatalog.where((s) => s.isAvailableFor(user)),
    ...ref.watch(groupesServicesProvider),
  ];
});
