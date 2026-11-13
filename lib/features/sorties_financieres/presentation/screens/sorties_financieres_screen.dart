import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/sortie_financiere_entity.dart';
import '../providers/sorties_dashboard_provider.dart';
import '../providers/sorties_list_provider.dart';
import '../providers/sortie_form_provider.dart';
import '../widgets/sortie_card.dart';
import '../../../main/presentation/screens/main_shell.dart' show floatingNavInset;

class SortiesFinancieresScreen extends ConsumerStatefulWidget {
  const SortiesFinancieresScreen({super.key});

  @override
  ConsumerState<SortiesFinancieresScreen> createState() =>
      _SortiesFinancieresScreenState();
}

class _SortiesFinancieresScreenState extends ConsumerState<SortiesFinancieresScreen> {
  var _filters = SortiesFilter.empty;
  String _selectedType = 'tous';
  late final ScrollController _scrollController;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      final listState = ref.read(sortiesListProvider);
      if (!listState.isLoading && listState.hasMore) {
        ref.read(sortiesListProvider.notifier).loadMore(_filters, type: _selectedType);
      }
    }
  }

  void _onFilterChanged(SortiesFilter newFilters) {
    setState(() => _filters = newFilters);
    ref.read(sortiesListProvider.notifier).load(newFilters, type: _selectedType, reset: true);
  }

  void _onTypeChanged(String type) {
    setState(() => _selectedType = type);
    ref.read(sortiesListProvider.notifier).load(_filters, type: type, reset: true);
  }

  void _showFormDialog({String? initialType, SortieFinanciereEntity? editSortie}) {
    showDialog(
      context: context,
      builder: (ctx) => _SortieFormDialog(initialType: initialType, sortieToEdit: editSortie),
    ).then((val) {
      if (val == true) {
        ref.read(sortiesListProvider.notifier).refresh(_filters, type: _selectedType);
        // ignore: unused_result
        ref.refresh(sortiesDashboardProvider(_filters));
        // ignore: unused_result
        ref.refresh(sortiesDashboardProvider(SortiesFilter.empty));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(sortiesListProvider);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: RefreshIndicator(
        color: SignmeColors.primaryLight,
        onRefresh: () async {
          await ref.read(sortiesListProvider.notifier).refresh(_filters, type: _selectedType);
          // ignore: unused_result
          ref.refresh(sortiesDashboardProvider(_filters));
          // ignore: unused_result
          ref.refresh(sortiesDashboardProvider(SortiesFilter.empty));
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  SignmeSpacing.lg, SignmeSpacing.lg,
                  SignmeSpacing.lg, SignmeSpacing.md,
                ),
                child: _GlobalStatsCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                child: _PeriodFilter(
                  filters: _filters,
                  onChanged: _onFilterChanged,
                ),
              ),
            ),
            if (_filters.hasAnyFilter)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SignmeSpacing.lg, SignmeSpacing.md,
                    SignmeSpacing.lg, SignmeSpacing.md,
                  ),
                  child: _PeriodSynthesisCard(filters: _filters),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SignmeSpacing.lg, SignmeSpacing.md,
                  SignmeSpacing.lg, SignmeSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeFilterChips(
                        selectedType: _selectedType,
                        onChanged: _onTypeChanged,
                      ),
                    ),
                    const SizedBox(width: SignmeSpacing.sm),
                    SignmeAnchoredActionMenu(
                      items: [
                        SignmeAnchoredActionMenuItem(
                          icon: Icons.money_off,
                          label: 'Sortie ordinaire',
                          onTap: () => _showFormDialog(initialType: 'simple'),
                        ),
                        SignmeAnchoredActionMenuItem(
                          icon: Icons.receipt_long,
                          label: 'Sortie de frais',
                          onTap: () => _showFormDialog(initialType: 'frais'),
                        ),
                      ],
                      builder: (context, onTap) => FloatingActionButton.small(
                        key: _fabKey,
                        onPressed: onTap,
                        backgroundColor: SignmeColors.primaryLight,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (listState.isLoading && listState.items.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                sliver: SliverToBoxAdapter(child: SignmeSkeletonList(itemCount: 4, itemHeight: 96)),
              )
            else if (listState.error != null && listState.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: SignmeErrorState(
                  title: 'Chargement impossible',
                  message: listState.error!,
                  onRetry: () => ref.read(sortiesListProvider.notifier).refresh(_filters, type: _selectedType),
                ),
              )
            else if (listState.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SignmeEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'Aucune sortie',
                  message: 'Les sorties financières enregistrées apparaîtront ici.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == listState.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: SignmeSpacing.md),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final sortie = listState.items[index];
                      return SortieCard(
                        sortie: sortie,
                        onChanged: () {
                          ref.read(sortiesListProvider.notifier).refresh(_filters, type: _selectedType);
                          // ignore: unused_result
                          ref.refresh(sortiesDashboardProvider(_filters));
                          // ignore: unused_result
                          ref.refresh(sortiesDashboardProvider(SortiesFilter.empty));
                        },
                        onEdit: sortie.canEdit ? () => _showFormDialog(editSortie: sortie) : null,
                      );
                    },
                    childCount: listState.items.length + (listState.hasMore ? 1 : 0),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: floatingNavInset(context) + 80),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SignmeTypography.labelSmall.copyWith(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: SignmeTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _GlobalStatsCard extends ConsumerWidget {
  const _GlobalStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(sortiesDashboardProvider(SortiesFilter.empty));

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.primaryLight.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      ),
      padding: const EdgeInsets.all(SignmeSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: SignmeSpacing.sm),
              Text(
                'Solde actuel',
                style: SignmeTypography.labelLarge.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.md),
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (_, __) => const Text('Solde indisponible', style: TextStyle(color: Colors.white)),
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FinanceFormatters.fcfa(stats.soldeActuel),
                  style: SignmeTypography.headlineMedium.copyWith(
                    color: SignmeColors.success,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: SignmeSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatTile(label: 'Total Encaissé', value: FinanceFormatters.fcfa(stats.totalEncaisseGlobal)),
                    _StatTile(label: 'Frais Générés', value: FinanceFormatters.fcfa(stats.totalFraisGeneres)),
                  ],
                ),
                const SizedBox(height: SignmeSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatTile(label: 'Sorties Simples', value: FinanceFormatters.fcfa(stats.totalSortiesSimples)),
                    _StatTile(label: 'Frais Versés', value: FinanceFormatters.fcfa(stats.totalSortieFraisValidees)),
                    _StatTile(label: 'Frais Restants', value: FinanceFormatters.fcfa(stats.fraisRestantAVerser)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  const _PeriodFilter({required this.filters, required this.onChanged});
  final SortiesFilter filters;
  final ValueChanged<SortiesFilter> onChanged;

  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  List<int> _years() {
    final now = DateTime.now().year;
    return List.generate(6, (i) => now - i);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      padding: const EdgeInsets.all(SignmeSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: SignmeCompactDropdown<int?>(
              label: 'Année',
              value: filters.year,
              items: [null, ..._years()],
              itemLabel: (y) => y == null ? 'Toutes' : y.toString(),
              hint: 'Toutes',
              onChanged: (y) => onChanged(filters.copyWith(year: y)),
            ),
          ),
          const SizedBox(width: SignmeSpacing.sm),
          Expanded(
            child: SignmeCompactDropdown<int?>(
              label: 'Mois',
              value: filters.month,
              items: [null, ...List.generate(12, (i) => i + 1)],
              itemLabel: (m) => m == null ? 'Tous' : _months[m - 1],
              hint: 'Tous',
              onChanged: (m) => onChanged(filters.copyWith(month: m)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSynthesisCard extends ConsumerWidget {
  const _PeriodSynthesisCard({required this.filters});
  final SortiesFilter filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(sortiesDashboardProvider(filters));

    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      padding: const EdgeInsets.all(SignmeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Résumé de la période', style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: SignmeSpacing.sm),
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Résumé indisponible'),
            data: (stats) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Encaissé Période', style: SignmeTypography.bodyMedium),
                    Text(FinanceFormatters.fcfa(stats.periodeEncaisse), style: SignmeTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: SignmeColors.success)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Frais Période', style: SignmeTypography.bodyMedium),
                    Text(FinanceFormatters.fcfa(stats.periodeFrais), style: SignmeTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sorties Simples', style: SignmeTypography.bodyMedium),
                    Text(FinanceFormatters.fcfa(stats.periodeSortiesSimples), style: SignmeTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: SignmeColors.error)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeFilterChips extends StatelessWidget {
  const _TypeFilterChips({required this.selectedType, required this.onChanged});
  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip('Tous', 'tous'),
        const SizedBox(width: SignmeSpacing.sm),
        _buildChip('Simple', 'simple'),
        const SizedBox(width: SignmeSpacing.sm),
        _buildChip('Frais', 'frais'),
      ],
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(value),
      selectedColor: SignmeColors.primaryLight,
      labelStyle: TextStyle(color: isSelected ? Colors.white : SignmeColors.black),
    );
  }
}

class _SortieFormDialog extends ConsumerStatefulWidget {
  const _SortieFormDialog({this.initialType, this.sortieToEdit});
  final String? initialType;

  /// Non-null = mode édition (sortie simple approuvée uniquement, cf.
  /// [SortieFinanciereEntity.canEdit]). Le type ne peut pas être changé.
  final SortieFinanciereEntity? sortieToEdit;

  bool get isEditing => sortieToEdit != null;

  @override
  ConsumerState<_SortieFormDialog> createState() => _SortieFormDialogState();
}

class _SortieFormDialogState extends ConsumerState<_SortieFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  final _montantCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final editing = widget.sortieToEdit;
    _type = editing?.type ?? widget.initialType ?? 'simple';
    if (editing != null) {
      _montantCtrl.text = editing.montant.toString();
      _descriptionCtrl.text = editing.description;
      _referenceCtrl.text = editing.reference ?? '';
    }
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _descriptionCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final montant = int.parse(_montantCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final description = _descriptionCtrl.text.trim();
    final reference = _referenceCtrl.text.trim();

    if (widget.isEditing) {
      await ref.read(sortieFormProvider.notifier).update(
            widget.sortieToEdit!.uuid,
            montant: montant,
            description: description,
            reference: reference,
          );
    } else if (_type == 'simple') {
      await ref.read(sortieFormProvider.notifier).createSimple(montant: montant, description: description, reference: reference);
    } else {
      await ref.read(sortieFormProvider.notifier).createFrais(montant: montant, description: description, reference: reference);
    }

    final state = ref.read(sortieFormProvider);
    if (state.success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sortieFormProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      ),
      backgroundColor: SignmeColors.white,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: SignmeSpacing.lg,
            right: SignmeSpacing.lg,
            top: SignmeSpacing.lg,
            bottom: SignmeSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEditing
                      ? 'Modifier la sortie'
                      : (_type == 'simple' ? 'Sortie Ordinaire' : 'Sortie de Frais'),
                  style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: SignmeSpacing.md),
                if (!widget.isEditing && _type == 'frais')
                  Container(
                    padding: const EdgeInsets.all(SignmeSpacing.sm),
                    decoration: BoxDecoration(
                      color: SignmeColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                    ),
                    child: const Text('Cette sortie sera soumise à validation de l\'administration', style: TextStyle(color: SignmeColors.warning)),
                  ),
                const SizedBox(height: SignmeSpacing.md),
                SignmeTextInput(
                  label: 'Montant (FCFA)',
                  hint: 'Ex. 25000',
                  controller: _montantCtrl,
                  keyboardType: TextInputType.number,
                  enabled: !state.isLoading,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requis';
                    final m = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
                    if (m == null || m < 100) return 'Montant invalide (min 100)';
                    return null;
                  },
                ),
                const SizedBox(height: SignmeSpacing.md),
                SignmeTextInput(
                  label: 'Description',
                  hint: 'Motif de la sortie',
                  controller: _descriptionCtrl,
                  maxLength: 255,
                  enabled: !state.isLoading,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: SignmeSpacing.md),
                SignmeTextInput(
                  label: 'Référence (Optionnel)',
                  hint: 'Ex. numéro de reçu',
                  controller: _referenceCtrl,
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: SignmeSpacing.lg),
                if (state.error != null) ...[
                  Text(state.error!, style: const TextStyle(color: SignmeColors.error)),
                  const SizedBox(height: SignmeSpacing.sm),
                ],
                Row(
                  children: [
                    Expanded(
                      child: SignmeSecondaryButton(
                        label: 'Annuler',
                        onPressed: state.isLoading ? null : () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: SignmeSpacing.md),
                    Expanded(
                      child: SignmePrimaryButton(
                        label: 'Enregistrer',
                        isLoading: state.isLoading,
                        onPressed: state.isLoading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}