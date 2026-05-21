import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/role_menu_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/users_provider.dart';
import 'create_user_dialog.dart';
import 'user_detail_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 150) {
        ref.read(usersProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersListProvider);
    final auth = ref.watch(authNotifierProvider);
    final currentUser = auth.auth?.user;
    final users = state.filtered;

    // ── Check permissions ──────────────────────────────────────────────
    final canViewUsers = currentUser != null && 
        (currentUser.role == 'pasteur' || currentUser.role == 'secretaire');

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleMenuDrawer(),
      appBar: AppBar(
        title: Text('Gérer Utilisateurs',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: canViewUsers
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => CreateUserDialog(
                    currentUserRole: currentUser!.role,
                  ),
                );
              },
              child: const Icon(Icons.person_add_rounded, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          // ── Check permissions guard ──────────────────────────────────
          if (!canViewUsers)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Accès limité aux pasteurs et secrétaires',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => ref.read(usersListProvider.notifier).search(v),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(usersListProvider.notifier).search('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: !canViewUsers
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block_rounded,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pas d\'accès',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seuls les pasteurs et secrétaires\npeuvent gérer les utilisateurs',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildBody(state, users),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UsersListState state, List<UserEntity> users) {
    if (state.isLoading && state.users.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: 6,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: AppShimmerBox(height: 80, width: double.infinity, radius: 12),
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline_rounded,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              state.searchQuery.isEmpty
                  ? 'Aucun utilisateur'
                  : 'Aucun résultat',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(usersListProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: users.length + (state.hasMore && state.isLoading ? 1 : 0),
        itemBuilder: (_, i) {
          if (i < users.length) {
            return GestureDetector(
              onTap: () {
                // Navigation vers le détail de l'utilisateur
                // À adapter avec votre système de navigation
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserDetailScreen(userId: users[i].id),
                  ),
                );
              },
              child: _UserCard(user: users[i]),
            );
          }
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: AppShimmerBox(height: 80, width: double.infinity, radius: 12),
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: const Icon(Icons.person_rounded,
                size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nom,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.roleLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getRoleColor(user.role),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!user.actif)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Inactif',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Status icon
          Icon(
            user.actif ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: user.actif ? AppColors.success : AppColors.error,
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'administrateur':
        return AppColors.primary;
      case 'pasteur':
        return const Color(0xFF6B5B95);
      case 'secretaire':
        return const Color(0xFFE09F3E);
      case 'tresorier':
        return const Color(0xFFD62828);
      case 'ancien':
        return const Color(0xFF2E8B57);
      default:
        return AppColors.textSecondary;
    }
  }
}
