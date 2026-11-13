import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../groupes/presentation/providers/groupes_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/presentation/widgets/recent_transactions_section.dart';
import '../../domain/entities/service_entity.dart';
import '../providers/services_provider.dart';
import '../widgets/service_tile.dart';
import '../../../main/presentation/screens/main_shell.dart' show floatingNavInset;

/// Écran Services : accès rapide aux actions courantes des fidèles,
/// rangées par rubrique, avec recherche.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  static const int _columns = 4;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = filterServices(ref.watch(availableServicesProvider), _controller.text);
    final sections = <String, List<ServiceEntity>>{};
    for (final service in services) {
      sections.putIfAbsent(service.section, () => []).add(service);
    }

    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    // La navbar flottante se masque avec le clavier : le contenu se dégage
    // alors au-dessus du clavier plutôt que de la navbar.
    final bottomPadding =
        keyboardInset > 0 ? keyboardInset + SignmeSpacing.lg : floatingNavInset(context);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: RefreshIndicator(
        color: SignmeColors.primaryLight,
        onRefresh: () async {
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(mesGroupesProvider);
          try {
            await ref.read(recentTransactionsProvider.future);
          } catch (_) {
            // L'erreur s'affiche dans la section : le geste de rafraîchissement se termine.
          }
        },
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          SignmeSpacing.lg,
          SignmeSpacing.sm,
          SignmeSpacing.lg,
          bottomPadding,
        ),
        children: [
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            style: SignmeTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Rechercher un service…',
              prefixIcon: const Icon(Icons.search_rounded, color: SignmeColors.mediumGray),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, color: SignmeColors.mediumGray),
                      tooltip: 'Effacer',
                      onPressed: () => setState(_controller.clear),
                    ),
              filled: true,
              fillColor: SignmeColors.accentSky.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: SignmeSpacing.xl),
          if (sections.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: SignmeSpacing.xxxl),
              child: SignmeEmptyState(
                icon: Icons.search_off_rounded,
                title: 'Aucun service trouvé',
                message: 'Essayez un autre mot, par exemple « don ».',
              ),
            ),
          for (final entry in sections.entries) ...[
            Text(
              entry.key,
              style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: SignmeSpacing.md),
            // Wrap + largeur de colonne calculée : chaque tuile prend sa hauteur
            // naturelle (le libellé peut passer sur 2 lignes ou grandir avec
            // la taille de police système) — un ratio fixe débordait.
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = SignmeSpacing.md;
                final tileWidth = (constraints.maxWidth - spacing * (_columns - 1)) / _columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: SignmeSpacing.lg,
                  children: [
                    for (final service in entry.value)
                      SizedBox(
                        width: tileWidth,
                        child: ServiceTile(service: service, onTap: () => _open(service.route)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: SignmeSpacing.xl),
          ],
          // Aperçu des transactions : masqué pendant une recherche de service.
          if (_controller.text.isEmpty)
            RecentTransactionsSection(onSeeAll: () => _open(AppRoutes.servicesTransactions)),
        ],
      ),
      ),
    );
  }

  /// Ouvre un service ; au retour, l'aperçu des transactions est rafraîchi
  /// (un don ou un paiement vient peut-être d'être effectué).
  Future<void> _open(String route) async {
    await context.push(route);
    if (mounted) {
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(mesGroupesProvider); // badges des groupes mis à jour après la visite
    }
  }
}
