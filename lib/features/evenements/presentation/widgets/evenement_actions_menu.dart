import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/evenement_entity.dart';
import '../providers/evenements_provider.dart';

enum EvenementAction {
  publier,
  annulerPlanification,
  terminer,
  archiver,
  desarchiver,
  partager,
}

/// Menu contextuel de gestion d'un événement (pasteur/secrétaire).
/// Utilisé à la fois par [EvenementCard] (fil d'actualité) et par
/// [EvenementGestionCard] (écran "Gérer les événements"). Le backend reste la
/// seule autorité : cette liste ne fait que refléter les transitions
/// plausibles pour l'état courant (l'auteur est vérifié serveur).
class EvenementActionsMenu extends ConsumerWidget {
  const EvenementActionsMenu({super.key, required this.evenement});
  final EvenementEntity evenement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Un événement planifié pas encore publié peut à tout moment être publié
    // immédiatement (l'auteur change d'avis, pas besoin d'attendre la date
    // prévue) ou annulé/supprimé définitivement.
    final planifieNonPublie = evenement.isPlanifie && evenement.publishedAt == null;

    // Un événement n'est partageable (lien public + aperçu) qu'une fois
    // réellement visible en dehors de l'app — brouillon/planifié/archivé
    // exclus (voir EvenementShareController côté backend, même règle).
    final estPartageable = evenement.isActif || evenement.isTermine;

    final actions = <EvenementAction>[
      if (evenement.isBrouillon || planifieNonPublie) EvenementAction.publier,
      if (planifieNonPublie) EvenementAction.annulerPlanification,
      if (estPartageable) EvenementAction.partager,
      if (evenement.isActif) EvenementAction.terminer,
      if (evenement.isTermine) EvenementAction.archiver,
      if (evenement.isArchive) EvenementAction.desarchiver,
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<EvenementAction>(
      icon: const Icon(Icons.more_vert_rounded, color: SignmeColors.mediumGray, size: 20),
      itemBuilder: (context) => actions
          .map((a) => PopupMenuItem(value: a, child: Text(_label(a, planifieNonPublie))))
          .toList(),
      onSelected: (action) => _handle(context, ref, action),
    );
  }

  String _label(EvenementAction a, bool planifieNonPublie) => switch (a) {
        EvenementAction.publier => planifieNonPublie ? 'Publier maintenant' : 'Publier',
        EvenementAction.annulerPlanification => 'Annuler et supprimer',
        EvenementAction.terminer => 'Terminer',
        EvenementAction.archiver => 'Archiver',
        EvenementAction.desarchiver => 'Désarchiver',
        EvenementAction.partager => 'Partager',
      };

  Future<void> _handle(BuildContext context, WidgetRef ref, EvenementAction action) async {
    // Purement local (feuille de partage native) : ne passe pas par
    // evenementFormProvider, jamais d'appel API.
    if (action == EvenementAction.partager) {
      _partager();
      return;
    }

    // Suppression définitive et irréversible : confirmation obligatoire.
    if (action == EvenementAction.annulerPlanification) {
      final confirmed = await _confirmDelete(context);
      if (confirmed != true) return;
    }

    final notifier = ref.read(evenementFormProvider.notifier);
    try {
      switch (action) {
        case EvenementAction.publier:
          await notifier.publish(evenement.uuid);
          break;
        case EvenementAction.annulerPlanification:
          await notifier.cancelScheduled(evenement.uuid);
          break;
        case EvenementAction.terminer:
          await notifier.terminer(evenement.uuid);
          break;
        case EvenementAction.archiver:
          await notifier.archiver(evenement.uuid);
          break;
        case EvenementAction.desarchiver:
          await notifier.desarchiver(evenement.uuid);
          break;
        case EvenementAction.partager:
          // Déjà traité par le retour anticipé ci-dessus.
          break;
      }
      if (context.mounted) {
        AppSnackbar.success(
          context,
          action == EvenementAction.annulerPlanification
              ? 'Événement supprimé avec succès.'
              : 'Action effectuée avec succès.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.warning(context, 'Une erreur est survenue.');
      }
    }
  }

  /// Partage le lien public de l'événement (WhatsApp, SMS, email...). Ouvre
  /// directement l'app d'un destinataire qui l'a déjà installée (Android App
  /// Links / iOS Universal Links) ou l'aperçu Open Graph + page de secours
  /// sinon — voir routes/web.php côté backend.
  void _partager() {
    Share.share(evenement.shareText, subject: evenement.titre);
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        title: Text(
          'Supprimer cet événement ?',
          style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Cet événement programmé n\'a jamais été publié. Cette action est '
          'définitive et ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Supprimer',
              style: TextStyle(color: SignmeColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
