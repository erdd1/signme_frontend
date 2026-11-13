import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../home/presentation/widgets/expandable_text_block.dart';
import '../../domain/entities/evenement_entity.dart';
import '../providers/evenements_provider.dart';
import '../widgets/objectif_progress_bar.dart';
import '../../../main/presentation/screens/main_shell.dart' show floatingNavInset;

/// Écran de détail d'un événement — atteint depuis un lien partagé
/// (WhatsApp/App Links/Universal Links) ou une notification push. Charge
/// l'événement par UUID (offline-first, même provider que le fil d'actualité)
/// pour que "l'événement précis" soit toujours identifiable, même quand
/// l'utilisateur n'a pas déjà la liste des événements en mémoire.
class EvenementDetailScreen extends ConsumerWidget {
  const EvenementDetailScreen({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(evenementDetailProvider(uuid));

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        title: Text(
          'Événement',
          style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          async.maybeWhen(
            data: (evenement) => evenement.peutGerer
                ? IconButton(
                    icon: const Icon(Icons.share_rounded, color: SignmeColors.primaryLight),
                    tooltip: 'Partager',
                    onPressed: () => _share(evenement),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const SignmePageSkeleton(),
        error: (e, _) => SignmeErrorState(
          title: 'Événement introuvable',
          message: messageFromError(e),
          onRetry: () => ref.invalidate(evenementDetailProvider(uuid)),
        ),
        data: (evenement) => _EvenementDetailContent(evenement: evenement),
      ),
    );
  }

  void _share(EvenementEntity evenement) {
    Share.share(evenement.shareText, subject: evenement.titre);
  }
}

class _EvenementDetailContent extends StatelessWidget {
  const _EvenementDetailContent({required this.evenement});

  final EvenementEntity evenement;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: floatingNavInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EvenementDetailImage(evenement: evenement),
          Padding(
            padding: const EdgeInsets.all(SignmeSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (evenement.church.nom != null) ...[
                  Text(
                    evenement.church.nom!.toUpperCase(),
                    style: SignmeTypography.labelSmall.copyWith(
                      color: SignmeColors.primaryLight,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: SignmeSpacing.sm),
                ],
                Text(
                  evenement.titre,
                  style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: SignmeSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFD0D9F5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF6B7BB5)),
                      const SizedBox(width: 5),
                      Text(
                        evenement.formattedDate,
                        style: SignmeTypography.bodySmall.copyWith(
                          color: const Color(0xFF6B7BB5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SignmeSpacing.lg),
                ExpandableTextBlock(text: evenement.description, maxLines: 8),
                if (evenement.aUnObjectif) ...[
                  const SizedBox(height: SignmeSpacing.lg),
                  ObjectifProgressBar(
                    objectifMontant: evenement.objectifMontant!,
                    montantCollecte: evenement.montantCollecte,
                    pourcentage: evenement.pourcentageObjectif ?? 0,
                  ),
                ],
                const SizedBox(height: SignmeSpacing.xl),
                _ContribuerButton(evenement: evenement),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EvenementDetailImage extends StatelessWidget {
  const _EvenementDetailImage({required this.evenement});
  final EvenementEntity evenement;

  @override
  Widget build(BuildContext context) {
    final url = evenement.imageUrl;
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: (url != null && url.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: SignmeColors.accentSky),
              errorWidget: (_, __, ___) => _defaultImage(),
            )
          : _defaultImage(),
    );
  }

  Widget _defaultImage() {
    return Container(
      color: SignmeColors.accentSky,
      alignment: Alignment.center,
      child: SvgPicture.asset(SignmeAssets.evenementDefault, height: 110, fit: BoxFit.contain),
    );
  }
}

class _ContribuerButton extends StatelessWidget {
  const _ContribuerButton({required this.evenement});
  final EvenementEntity evenement;

  @override
  Widget build(BuildContext context) {
    final peutContribuer = evenement.peutContribuer;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: peutContribuer ? const LinearGradient(colors: SignmeColors.buttonGradient) : null,
          color: peutContribuer ? null : SignmeColors.lightGray,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: peutContribuer
                ? () => context.push(
                      AppRoutes.contributionFormPath(evenement.uuid),
                      extra: evenement,
                    )
                : null,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    peutContribuer ? Icons.volunteer_activism_rounded : Icons.lock_clock_rounded,
                    size: 18,
                    color: peutContribuer ? Colors.white : SignmeColors.mediumGray,
                  ),
                  const SizedBox(width: SignmeSpacing.sm),
                  Text(
                    evenement.labelBoutonContribution,
                    style: SignmeTypography.buttonText.copyWith(
                      fontSize: 14,
                      color: peutContribuer ? Colors.white : SignmeColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
