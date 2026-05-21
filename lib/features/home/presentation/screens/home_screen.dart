import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/role_menu_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/publication_entity.dart';
import '../providers/publications_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(publicationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState  = ref.watch(authNotifierProvider);
    final pubState   = ref.watch(publicationsProvider);
    final user       = authState.auth?.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleMenuDrawer(),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(publicationsProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar ────────────────────────────────────────────────────
            _buildAppBar(context, user?.nom ?? ''),

            // ── Welcome + Church Card ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(user),
                    const SizedBox(height: 12),
                    if (user?.churchNom != null) _buildChurchCard(user!.churchNom!),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.newsFeed,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Publications ──────────────────────────────────────────────
            if (pubState.isLoading && pubState.publications.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const PublicationCardShimmer(),
                    childCount: 5,
                  ),
                ),
              )
            else if (pubState.publications.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      const Icon(Icons.article_outlined, size: 56, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(AppStrings.noPublication,
                          style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i < pubState.publications.length) {
                        return _PublicationCard(pub: pubState.publications[i]);
                      }
                      return pubState.isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: PublicationCardShimmer(),
                            )
                          : const SizedBox.shrink();
                    },
                    childCount: pubState.publications.length + (pubState.hasMore ? 1 : 0),
                  ),
                ),
              ),

            // ── Bottom padding ────────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── AppBar Sliver ─────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext context, String nom) {
    return SliverAppBar(
      floating:    true,
      snap:        true,
      pinned:      false,
      backgroundColor: AppColors.surface,
      elevation:   0,
      shadowColor: Colors.black12,
      title: Row(
        children: [
          // Logo
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified_user_rounded, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 24),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ],
    );
  }

  // ── Welcome Card ──────────────────────────────────────────────────────────
  Widget _buildWelcomeCard(dynamic user) {
    final roleLbl = user != null
        ? (AppStrings.roleLabels[user.role] ?? user.role.toUpperCase())
        : '';
    return Row(
      children: [
        // Avatar
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: user?.photoUrl != null
              ? ClipOval(child: CachedNetworkImage(imageUrl: user!.photoUrl!, fit: BoxFit.cover))
              : const Icon(Icons.person_rounded, size: 28, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.welcome2,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              Text(
                user?.nom ?? '',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        // Badge rôle
        if (roleLbl.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Text(
              roleLbl,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  // ── Church Card ───────────────────────────────────────────────────────────
  Widget _buildChurchCard(String churchNom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.church_rounded, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              churchNom,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// ── Publication Card ──────────────────────────────────────────────────────────
class _PublicationCard extends StatelessWidget {
  const _PublicationCard({required this.pub});
  final PublicationEntity pub;

  Color get _typeColor {
    switch (pub.type) {
      case 'MEDITATION':  return const Color(0xFF7C3AED);
      case 'ANNONCE':     return AppColors.secondary;
      case 'TEMOIGNAGE':  return AppColors.success;
      case 'PRIERE':      return AppColors.warning;
      default:            return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              _avatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pub.auteurNom,
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(pub.type,
                              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: _typeColor)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${timeago.format(pub.createdAt, locale: 'fr')}',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Titre ────────────────────────────────────────────────────────
          Text(pub.titre,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),

          // ── Référence ────────────────────────────────────────────────────
          if (pub.reference != null) ...[
            const SizedBox(height: 2),
            Text('Référence : ${pub.reference}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 6),

          // ── Contenu ──────────────────────────────────────────────────────
          Text(
            pub.contenu,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (pub.auteurPhoto != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(pub.auteurPhoto!),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primarySurface,
      child: Text(
        pub.auteurNom.isNotEmpty ? pub.auteurNom[0].toUpperCase() : 'A',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}
