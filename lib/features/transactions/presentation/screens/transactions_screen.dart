import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../providers/transactions_provider.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transactions_filter_sheet.dart';

/// Historique des transactions : toutes les opérations financières de
/// l'utilisateur, avec recherche, filtres et défilement infini.
///
/// Plein écran, hors coquille (ni appbar ni navbar du shell) : bouton retour
/// et grand titre, comme un relevé.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
        ref.read(transactionsHistoryProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsHistoryProvider);
    final notifier = ref.read(transactionsHistoryProvider.notifier);

    final bottomPadding = MediaQuery.of(context).padding.bottom + SignmeSpacing.xl;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          tooltip: 'Retour',
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.services),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, 0, SignmeSpacing.lg, SignmeSpacing.lg),
            child: Text(
              'Historique des transactions',
              style: SignmeTypography.displaySmall.copyWith(fontWeight: FontWeight.w900, height: 1.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, 0, SignmeSpacing.lg, SignmeSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (v) {
                      setState(() {}); // met à jour le bouton d'effacement
                      notifier.setQuery(v);
                    },
                    textInputAction: TextInputAction.search,
                    style: SignmeTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Rechercher ici',
                      prefixIcon: const Icon(Icons.search_rounded, color: SignmeColors.black),
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, color: SignmeColors.mediumGray),
                              tooltip: 'Effacer',
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                                notifier.setQuery('');
                              },
                            ),
                      filled: true,
                      fillColor: SignmeColors.accentSky.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SignmeSpacing.sm),
                _FilterButton(
                  active: state.filters.hasFilter,
                  onTap: () => showTransactionsFilterSheet(context),
                ),
              ],
            ),
          ),
          Expanded(child: _body(state, notifier, bottomPadding)),
        ],
      ),
    );
  }

  Widget _body(TransactionsHistoryState state, TransactionsHistoryNotifier notifier, double bottomPadding) {
    if (state.isLoading && state.items.isEmpty) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
        children: const [SignmeSkeletonList(itemCount: 6, itemHeight: 84)],
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return SignmeErrorState(
        title: 'Chargement impossible',
        message: state.error!,
        onRetry: notifier.refresh,
      );
    }

    if (state.items.isEmpty) {
      return SignmeEmptyState(
        icon: Icons.receipt_long_rounded,
        title: state.filters.hasFilter || state.filters.query.isNotEmpty
            ? 'Aucune transaction trouvée'
            : 'Aucune transaction pour le moment',
        message: state.filters.hasFilter || state.filters.query.isNotEmpty
            ? 'Essayez une autre recherche ou retirez les filtres.'
            : 'Vos dons, contributions et signatures apparaîtront ici.',
      );
    }

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: notifier.refresh,
      child: ListView(
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(SignmeSpacing.lg, 0, SignmeSpacing.lg, bottomPadding),
        children: [
          Container(
            decoration: BoxDecoration(
              color: SignmeColors.white,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
              border: Border.all(color: SignmeColors.lightGrayBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < state.items.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: SignmeSpacing.md, endIndent: SignmeSpacing.md),
                  TransactionTile(
                    transaction: state.items[i],
                    onTap: () => showTransactionDetailSheet(context, state.items[i]),
                  ),
                ],
              ],
            ),
          ),
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(SignmeSpacing.lg),
              child: Center(child: CircularProgressIndicator(color: SignmeColors.primaryLight)),
            ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: SignmeSpacing.md),
              child: Center(
                child: SignmeTextButton(
                  label: 'Réessayer',
                  icon: Icons.refresh_rounded,
                  onPressed: notifier.loadMore,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Filtrer',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: SignmeColors.lightGray, shape: BoxShape.circle),
              child: const Icon(Icons.tune_rounded, color: SignmeColors.black),
            ),
            if (active)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: SignmeColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: SignmeColors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
