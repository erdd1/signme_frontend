import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user_entity.dart';

/// Un service rapide proposé aux fidèles (tuile de l'écran Services).
class ServiceEntity {
  const ServiceEntity({
    required this.id,
    required this.label,
    required this.icon,
    required this.section,
    required this.route,
    this.availableFor,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Rubrique sous laquelle la tuile est rangée (ex. « Mon église »).
  final String section;

  /// Route ouverte au toucher de la tuile.
  final String route;

  /// Restriction éventuelle par rôle / statut ; null = disponible pour tous.
  final bool Function(UserEntity user)? availableFor;

  bool isAvailableFor(UserEntity user) => availableFor?.call(user) ?? true;
}

/// Filtre les services par texte saisi (libellé ou rubrique, sans tenir
/// compte de la casse ni des accents).
List<ServiceEntity> filterServices(List<ServiceEntity> services, String query) {
  final needle = _normalize(query);
  if (needle.isEmpty) return services;

  return services
      .where((s) => _normalize(s.label).contains(needle) || _normalize(s.section).contains(needle))
      .toList();
}

String _normalize(String value) {
  const accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ç': 'c',
  };
  final lower = value.trim().toLowerCase();
  return lower.split('').map((c) => accents[c] ?? c).join();
}
