import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/about_article_entity.dart';
import '../providers/about_church_provider.dart';
import '../widgets/about_header_card.dart';
import '../widgets/about_scroll_fab.dart';
import '../widgets/article_card.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/pinned_carousel.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../main/presentation/screens/main_shell.dart' show floatingNavInset;

class AboutChurchScreen extends ConsumerStatefulWidget {
  const AboutChurchScreen({super.key});

  @override
  ConsumerState<AboutChurchScreen> createState() => _AboutChurchScreenState();
}

class _AboutChurchScreenState extends ConsumerState<AboutChurchScreen> {
  final _scrollController = ScrollController();

  // Une GlobalKey par article, pour permettre au tap sur un item de
  // carrousel de scroller jusqu'à l'article correspondant plus bas dans la
  // même page (jamais de navigation vers une nouvelle route).
  final Map<String, GlobalKey> _articleKeys = {};

  GlobalKey _keyFor(String uuid) => _articleKeys.putIfAbsent(uuid, () => GlobalKey());

  void _scrollToArticle(AboutArticleEntity article) {
    // Si un filtre masque actuellement cet article, on repasse sur "Tous"
    // pour qu'il soit bien monté dans l'arbre avant de scroller vers lui.
    final currentFilter = ref.read(aboutChurchCategoryFilterProvider);
    if (currentFilter != AboutChurchCategory.all && currentFilter != article.type) {
      ref.read(aboutChurchCategoryFilterProvider.notifier).state = AboutChurchCategory.all;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keyFor(article.uuid).currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payloadAsync = ref.watch(aboutChurchProvider);
    final categoryFilter = ref.watch(aboutChurchCategoryFilterProvider);
    final user = ref.watch(authNotifierProvider).auth?.user;
    final canManage = user != null && AppPermissions.canManageAboutChurch(user);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      floatingActionButton: AboutScrollFab(scrollController: _scrollController),
      body: payloadAsync.when(
        loading: () => const SignmePageSkeleton(),
        error: (e, _) => SignmeErrorState(
          title: 'Chargement impossible',
          message: messageFromError(e),
          onRetry: () => ref.read(aboutChurchProvider.notifier).load(),
        ),
        data: (payload) {
          final filteredArticles = categoryFilter == AboutChurchCategory.all
              ? payload.articles
              : payload.articles.where((a) => a.type == categoryFilter).toList();

          return RefreshIndicator(
            color: SignmeColors.primaryLight,
            onRefresh: () => ref.read(aboutChurchProvider.notifier).refresh(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: EdgeInsets.fromLTRB(
                SignmeSpacing.lg,
                SignmeSpacing.lg,
                SignmeSpacing.lg,
                floatingNavInset(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AboutHeaderCard(
                    church: payload.church,
                    info: payload.info,
                    onEdit: canManage
                        ? () => context.pushNamed('about-church-edit-info')
                        : null,
                  ),
                  const SizedBox(height: SignmeSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: CategoryFilterBar(
                          selected: categoryFilter,
                          onChanged: (v) =>
                              ref.read(aboutChurchCategoryFilterProvider.notifier).state = v,
                        ),
                      ),
                      if (canManage) ...[
                        const SizedBox(width: SignmeSpacing.sm),
                        FloatingActionButton.small(
                          heroTag: 'about_church_create_fab',
                          backgroundColor: SignmeColors.primaryLight,
                          onPressed: () => context.pushNamed('about-church-create'),
                          child: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: SignmeSpacing.lg),

                  // ── Carrousels épinglés : toujours visibles, quel que soit
                  // le filtre actif (curated highlights, indépendants du
                  // filtrage de la liste d'articles ci-dessous). ──────────
                  if (payload.pinnedPastors.isNotEmpty) ...[
                    PinnedCarousel(
                      title: 'Pasteur Actuel',
                      items: payload.pinnedPastors,
                      onItemTap: _scrollToArticle,
                    ),
                    const SizedBox(height: SignmeSpacing.xl),
                  ],
                  if (payload.pinnedGroups.isNotEmpty) ...[
                    PinnedCarousel(
                      title: 'Nos Groupes',
                      items: payload.pinnedGroups,
                      onItemTap: _scrollToArticle,
                    ),
                    const SizedBox(height: SignmeSpacing.xl),
                  ],
                  if (payload.pinnedActivities.isNotEmpty) ...[
                    PinnedCarousel(
                      title: 'Activités Majeures',
                      items: payload.pinnedActivities,
                      onItemTap: _scrollToArticle,
                    ),
                    const SizedBox(height: SignmeSpacing.xl),
                  ],

                  // ── Liste d'articles filtrée ─────────────────────────────
                  if (filteredArticles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: SignmeSpacing.xxl),
                      child: SignmeEmptyState(
                        icon: Icons.church_rounded,
                        title: 'Aucun article',
                        message: 'Aucun contenu disponible pour cette catégorie.',
                      ),
                    )
                  else
                    for (final article in filteredArticles)
                      Padding(
                        key: _keyFor(article.uuid),
                        padding: const EdgeInsets.only(bottom: SignmeSpacing.lg),
                        child: ArticleCard(article: article),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
