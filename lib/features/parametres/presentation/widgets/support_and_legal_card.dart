import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/support_provider.dart';

class SupportAndLegalCard extends ConsumerStatefulWidget {
  const SupportAndLegalCard({super.key});

  @override
  ConsumerState<SupportAndLegalCard> createState() => _SupportAndLegalCardState();
}

class _SupportAndLegalCardState extends ConsumerState<SupportAndLegalCard> {
  bool _isOpeningWhatsapp = false;

  Future<void> _contacterServiceClient() async {
    if (_isOpeningWhatsapp) return;
    setState(() => _isOpeningWhatsapp = true);

    String link;
    try {
      link = await ref.read(supportRemoteDataSourceProvider).whatsappLink();
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Impossible de récupérer le contact du service client.');
        setState(() => _isOpeningWhatsapp = false);
      }
      return;
    }

    try {
      final nomUtilisateur = ref.read(authNotifierProvider).auth?.user.nom ?? 'un utilisateur';
      final message = 'Salut je suis $nomUtilisateur de l\'application SignMe, '
          'je rencontre un souci actuellement sur l\'application.';
      final uri = Uri.parse('$link?text=${Uri.encodeComponent(message)}');

      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        AppSnackbar.error(context, 'Impossible d\'ouvrir WhatsApp. Vérifiez qu\'il est installé.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Impossible d\'ouvrir WhatsApp : $e');
      }
    } finally {
      if (mounted) setState(() => _isOpeningWhatsapp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support et Légal',
          style: SignmeTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: SignmeColors.black,
          ),
        ),
        const SizedBox(height: SignmeSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
          ),
          child: Column(
            children: [
              _buildLegalTile(
                iconWidget: Image.asset(SignmeAssets.whatsapp, width: 20, height: 20),
                title: 'Contactez le service client',
                subtitle: 'Contactez-nous, vous rencontrez un problème dans l\'application ?',
                onTap: _contacterServiceClient,
                trailing: _isOpeningWhatsapp
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: SignmeColors.primaryLight),
                      )
                    : null,
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildLegalTile(
                iconWidget: const Icon(Icons.help_outline, color: SignmeColors.primaryLight, size: 20),
                title: 'Aide et support',
                subtitle: 'Contactez notre équipe support',
                onTap: () {},
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildLegalTile(
                iconWidget: const Icon(Icons.description_outlined, color: SignmeColors.primaryLight, size: 20),
                title: 'Politique de confidentialité',
                subtitle: 'Consultez nos politiques',
                onTap: () {},
              ),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              _buildLegalTile(
                iconWidget: const Icon(Icons.balance_outlined, color: SignmeColors.primaryLight, size: 20),
                title: 'Conditions d\'utilisation',
                subtitle: 'Lisez nos conditions',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalTile({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SignmeSpacing.lg,
          vertical: SignmeSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(SignmeSpacing.sm),
              decoration: BoxDecoration(
                color: SignmeColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: iconWidget,
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SignmeTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: SignmeColors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: SignmeTypography.bodySmall.copyWith(
                      color: SignmeColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: SignmeColors.mediumGray.withOpacity(0.5),
                ),
          ],
        ),
      ),
    );
  }
}
