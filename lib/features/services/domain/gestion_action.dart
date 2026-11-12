import 'package:flutter/material.dart';

/// Une action d'un service de gestion (« Gestion événement », « Gestion
/// finance »). Chaque action ouvre l'écran qui existait déjà dans le menu :
/// seul leur REGROUPEMENT a changé, jamais ce qu'elles font ni qui y a droit.
class GestionAction {
  const GestionAction({
    required this.id,
    required this.titre,
    required this.description,
    required this.icone,
    required this.route,
    this.estOnglet = false,
  });

  final String id;
  final String titre;
  final String description;
  final IconData icone;
  final String route;

  /// Vrai pour un écran qui est un onglet de l'application (Finances) : on y
  /// accède comme depuis l'ancien menu, plutôt qu'en l'empilant.
  final bool estOnglet;
}
