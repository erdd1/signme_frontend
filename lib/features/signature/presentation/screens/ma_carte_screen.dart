import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/signature_entity.dart';
import '../../domain/ma_carte_years.dart';
import '../providers/ma_carte_provider.dart';
import '../../../main/presentation/screens/main_shell.dart' show floatingNavInset;

class MaCarteScreen extends ConsumerStatefulWidget {
  const MaCarteScreen({super.key});

  @override
  ConsumerState<MaCarteScreen> createState() => _MaCarteScreenState();
}

class _MaCarteScreenState extends ConsumerState<MaCarteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(maCarteProvider.notifier);
      await notifier.loadIfNeeded();
      await notifier.refreshSilently();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).auth?.user;
    if (user != null && !AppPermissions.canViewMaCarte(user)) {
      return const SignmeNoPermissionState(
        title: 'Fonctionnalité bloquée',
        message: AppPermissions.notCommuniantMessage,
        icon: Icons.credit_card_off_rounded,
      );
    }

    ref.watch(maCarteBootstrapProvider);
    final state = ref.watch(maCarteProvider);

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () => ref.read(maCarteProvider.notifier).load(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          SignmeSpacing.lg,
          SignmeSpacing.lg,
          SignmeSpacing.lg,
          floatingNavInset(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OnboardingSection(
              svgPath: SignmeAssets.onboardingSigner,
              title: 'Votre carte de Sainte-Cène',
              description:
                  'Consultez vos signatures et offrandes mois par mois.',
            ),
            const SizedBox(height: SignmeSpacing.xl),
            _StatusBanner(
              onSigner: () => context.go(AppRoutes.signer),
            ),
            const SizedBox(height: SignmeSpacing.lg),
            _SignatureTable(
              cartesByYear: state.cartesByYear,
              loadingYears: state.loadingYears,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.onSigner});

  final VoidCallback onSigner;

  @override
  Widget build(BuildContext context) {
    return SignmeHeroCard(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: Text(
              'Mettre à jour votre carte',
              style: SignmeTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: SignmeSpacing.sm),
          SizedBox(
            width: 108,
            height: 40,
            child: SignmePrimaryButton(
              label: AppStrings.signerBtn,
              onPressed: onSigner,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignatureTable extends StatelessWidget {
  const _SignatureTable({
    required this.cartesByYear,
    required this.loadingYears,
  });

  final Map<int, MaCarteData> cartesByYear;
  final Set<int> loadingYears;

  static const double _minTableWidth = 360;
  static const double _monthColWidth = 44;
  static const double _yearColWidth = 58;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < _minTableWidth
            ? _minTableWidth
            : constraints.maxWidth;
        return Container(
          decoration: BoxDecoration(
            color: SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _TableHeader(
                    monthColWidth: _monthColWidth,
                    yearColWidth: _yearColWidth,
                  ),
                  const Divider(height: 1, color: SignmeColors.lightGrayBorder),
                  ...List.generate(
                    12,
                    (i) => _TableRow(
                      monthIdx: i,
                      cartesByYear: cartesByYear,
                      loadingYears: loadingYears,
                      monthColWidth: _monthColWidth,
                      yearColWidth: _yearColWidth,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.monthColWidth,
    required this.yearColWidth,
  });

  final double monthColWidth;
  final double yearColWidth;

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SignmeSpacing.md,
        vertical: SignmeSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: SignmeColors.accentSky,
        borderRadius: BorderRadius.vertical(top: Radius.circular(SignmeSpacing.radiusLg)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: monthColWidth,
            child: Text(
              'MOIS',
              style: SignmeTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: SignmeColors.primaryDark,
              ),
            ),
          ),
          ...MaCarteYears.display.map(
            (y) => SizedBox(
              width: yearColWidth,
              child: Text(
                y.toString(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SignmeTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: y == currentYear
                      ? SignmeColors.primaryLight
                      : SignmeColors.mediumGray,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.monthIdx,
    required this.cartesByYear,
    required this.loadingYears,
    required this.monthColWidth,
    required this.yearColWidth,
  });

  final int monthIdx;
  final Map<int, MaCarteData> cartesByYear;
  final Set<int> loadingYears;
  final double monthColWidth;
  final double yearColWidth;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth =
        monthIdx == now.month - 1 && MaCarteYears.display.contains(now.year);

    return Column(
      children: [
        Container(
          color: isCurrentMonth
              ? SignmeColors.accentSky.withOpacity(0.35)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: SignmeSpacing.md,
            vertical: SignmeSpacing.md,
          ),
          child: Row(
            children: [
              SizedBox(
                width: monthColWidth,
                child: Text(
                  AppStrings.moisShort[monthIdx].toUpperCase(),
                  style: SignmeTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...MaCarteYears.display.map((year) {
                final isLoading = loadingYears.contains(year);
                final sig = isLoading
                    ? null
                    : cartesByYear[year]?.signaturesParMois[monthIdx.toString()];
                return SizedBox(
                  width: yearColWidth,
                  child: _AmountCell(
                    isLoading: isLoading,
                    signature: sig,
                  ),
                );
              }),
            ],
          ),
        ),
        if (monthIdx < 11)
          const Divider(
            height: 1,
            color: SignmeColors.lightGrayBorder,
            indent: SignmeSpacing.md,
          ),
      ],
    );
  }
}

class _AmountCell extends StatelessWidget {
  const _AmountCell({
    required this.isLoading,
    this.signature,
  });

  final bool isLoading;
  final SignatureEntity? signature;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableCellShimmer(width: 34, height: 10);
    }

    if (signature == null) {
      return const Center(
        child: Text(
          '–',
          style: TextStyle(color: SignmeColors.mediumGray),
        ),
      );
    }

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          NumberFormat('#,###', 'fr_FR').format(signature!.amount),
          style: SignmeTypography.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: signature!.isCompleted
                ? SignmeColors.success
                : SignmeColors.warning,
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}
