import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../providers/celebrations_provider.dart';
import '../widgets/celebration_card.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../main/presentation/screens/main_shell.dart' show floatingNavInset;

class CelebrationsScreen extends ConsumerWidget {
  const CelebrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(celebrationsProvider);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: async.when(
        loading: () => const SignmePageSkeleton(itemHeight: 90),
        error: (e, _) => SignmeErrorState(
          title: 'Chargement impossible',
          message: messageFromError(e),
          onRetry: () => ref.read(celebrationsProvider.notifier).load(),
        ),
        data: (celebrations) => RefreshIndicator(
          color: SignmeColors.primaryLight,
          onRefresh: () => ref.read(celebrationsProvider.notifier).refresh(),
          child: celebrations.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.xxl),
                    child: SignmeEmptyState(
                      icon: Icons.celebration_rounded,
                      title: 'Aucune célébration pour le moment',
                      message: 'Vos vœux d\'anniversaire et occasions spéciales apparaîtront ici.',
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    SignmeSpacing.lg,
                    SignmeSpacing.lg,
                    SignmeSpacing.lg,
                    floatingNavInset(context),
                  ),
                  itemCount: celebrations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: SignmeSpacing.md),
                  itemBuilder: (context, i) {
                    final celebration = celebrations[i];
                    return CelebrationCard(
                      celebration: celebration,
                      onTap: () => context.pushNamed(
                        'celebration-detail',
                        pathParameters: {'uuid': celebration.uuid},
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
