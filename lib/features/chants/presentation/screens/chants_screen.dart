import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../providers/chants_provider.dart';
import '../widgets/chant_card.dart';

/// Répertoire de chants : recherche par titre ou par extrait de paroles.
class ChantsScreen extends ConsumerStatefulWidget {
  const ChantsScreen({super.key});

  @override
  ConsumerState<ChantsScreen> createState() => _ChantsScreenState();
}

class _ChantsScreenState extends ConsumerState<ChantsScreen> {
  static const List<String> _suggestions = [
    'Grâce infinie',
    'Alléluia',
    'À toi la gloire',
    'Dieu tout-puissant',
    'Louange',
  ];

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) => ref.read(chantsSearchProvider.notifier).onQueryChanged(value);

  void _applySuggestion(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _search(value);
  }

  void _clear() {
    _controller.clear();
    _search('');
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(chantsSearchProvider);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    // La navbar flottante se masque avec le clavier : le contenu doit alors
    // se dégager au-dessus du clavier plutôt que de la navbar.
    final bottomPadding = keyboardInset > 0
        ? keyboardInset + SignmeSpacing.lg
        : SignmeSpacing.navbarClearance;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SignmeSpacing.lg,
              SignmeSpacing.sm,
              SignmeSpacing.lg,
              SignmeSpacing.md,
            ),
            child: TextField(
              controller: _controller,
              onChanged: (v) {
                setState(() {}); // met à jour le bouton d'effacement
                _search(v);
              },
              textInputAction: TextInputAction.search,
              style: SignmeTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Titre ou paroles du chant…',
                prefixIcon: const Icon(Icons.search_rounded, color: SignmeColors.mediumGray),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, color: SignmeColors.mediumGray),
                        tooltip: 'Effacer',
                        onPressed: _clear,
                      ),
                filled: true,
                fillColor: SignmeColors.accentSky.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: search.isIdle
                ? _IdleView(
                    suggestions: _suggestions,
                    onSuggestion: _applySuggestion,
                    bottomPadding: bottomPadding,
                  )
                : search.result.when(
                    loading: () => ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                      children: const [SignmeSkeletonList(itemCount: 5, itemHeight: 104)],
                    ),
                    error: (e, _) => SignmeErrorState(
                      title: 'Recherche impossible',
                      message: messageFromError(e),
                      icon: e is NetworkException ? Icons.wifi_off_rounded : Icons.error_outline,
                      onRetry: ref.read(chantsSearchProvider.notifier).retry,
                    ),
                    data: (chants) => chants.isEmpty
                        ? const SignmeEmptyState(
                            icon: Icons.music_off_rounded,
                            title: 'Aucun chant trouvé',
                            message:
                                'Essayez avec un autre titre, un mot du refrain ou une orthographe différente.',
                          )
                        : ListView.separated(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.fromLTRB(
                              SignmeSpacing.lg,
                              SignmeSpacing.sm,
                              SignmeSpacing.lg,
                              bottomPadding,
                            ),
                            itemCount: chants.length,
                            separatorBuilder: (_, __) => const SizedBox(height: SignmeSpacing.md),
                            itemBuilder: (context, i) => ChantCard(
                              chant: chants[i],
                              onTap: () => context.pushNamed(
                                'chant-detail',
                                pathParameters: {'id': '${chants[i].id}'},
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Écran d'accueil du répertoire, avant toute recherche.
class _IdleView extends StatelessWidget {
  const _IdleView({
    required this.suggestions,
    required this.onSuggestion,
    required this.bottomPadding,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        SignmeSpacing.lg,
        SignmeSpacing.xl,
        SignmeSpacing.lg,
        bottomPadding,
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: SignmeColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.library_music_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: SignmeSpacing.xl),
          Text(
            'Louez Dieu en chantant',
            style: SignmeTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Text(
            'Tapez le titre d\'un chant ou quelques mots de ses paroles : '
            'retrouvez-le en entier, strophes et refrains compris.',
            style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SignmeSpacing.xxl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ESSAYEZ',
              style: SignmeTypography.labelSmall.copyWith(
                color: SignmeColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: SignmeSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: SignmeSpacing.sm,
              runSpacing: SignmeSpacing.sm,
              children: [
                for (final s in suggestions)
                  SignmePillChip(label: s, selected: false, onTap: () => onSuggestion(s)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
