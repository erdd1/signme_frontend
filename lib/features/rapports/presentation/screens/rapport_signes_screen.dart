import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../domain/entities/rapport_membre_entity.dart';
import '../providers/rapports_provider.dart';
import '../widgets/signed_member_card.dart';

class RapportSignesScreen extends ConsumerStatefulWidget {
  final List<RapportMembreEntity> signes;
  final String month;

  const RapportSignesScreen({
    required this.signes,
    required this.month,
    super.key,
  });

  @override
  ConsumerState<RapportSignesScreen> createState() =>
      _RapportSignesScreenState();
}

class _RapportSignesScreenState extends ConsumerState<RapportSignesScreen> {
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    // Initialiser la liste des signés après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rapportSignesListProvider.notifier).setMembers(widget.signes);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rapportSignesListProvider);
    final filtered = state.filtered;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Bouton retour et titre ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(SignmeSpacing.lg),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: SignmeColors.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: SignmeSpacing.md),
                Text(
                  'Rechercher un membre',
                  style: SignmeTypography.headlineSmall.copyWith(
                    color: SignmeColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: SignmeSpacing.md),

          // ── Barre de recherche ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SignmeSpacing.lg,
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    ref.read(rapportSignesListProvider.notifier).search(v),
                style: SignmeTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Rechercher un membre…',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: SignmeColors.textSecondary,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            ref
                                .read(rapportSignesListProvider.notifier)
                                .clearSearch();
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: SignmeColors.textSecondary,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SignmeSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: SignmeColors.lightGrayBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SignmeSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: SignmeColors.lightGrayBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SignmeSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: SignmeColors.primaryLight,
                    ),
                  ),
                  filled: true,
                  fillColor: SignmeColors.lightGray,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SignmeSpacing.md,
                    vertical: SignmeSpacing.md,
                  ),
                ),
              ),
            ),

            const SizedBox(height: SignmeSpacing.lg),

            // ── Liste des signés ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SignmeSpacing.lg,
              ),
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(SignmeSpacing.xl),
                        child: Text(
                          'Aucun membre trouvé',
                          style: SignmeTypography.bodyMedium.copyWith(
                            color: SignmeColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < filtered.length; i++) ...[
                          SignedMemberCard(member: filtered[i]),
                          if (i < filtered.length - 1)
                            const Divider(
                              color: SignmeColors.lightGrayBorder,
                              height: 1,
                            ),
                        ],
                      ],
                    ),
            ),

            const SizedBox(height: 120), // Bottom padding for navbar
          ],
        ),
    );
  }
}
