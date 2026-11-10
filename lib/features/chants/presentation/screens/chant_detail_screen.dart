import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/chant_entity.dart';
import '../providers/chants_provider.dart';
import '../widgets/chant_text_size_sheet.dart';
import '../widgets/lyrics_section_view.dart';

/// Paroles complètes d'un chant. Plein écran, hors coquille (ni appbar ni
/// navbar du shell) : lecture sans distraction, comme les célébrations.
class ChantDetailScreen extends ConsumerWidget {
  const ChantDetailScreen({super.key, required this.chantId});

  final int chantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chantDetailProvider(chantId));
    final chant = async.asData?.value;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.chants),
        ),
        title: Text(
          'Paroles',
          style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields_rounded, color: SignmeColors.primaryLight),
            tooltip: 'Taille du texte',
            onPressed: () => showChantTextSizeSheet(context),
          ),
          if (chant != null) ...[
            IconButton(
              icon: const Icon(Icons.copy_rounded, color: SignmeColors.primaryLight),
              tooltip: 'Copier les paroles',
              onPressed: () => _copy(context, chant),
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded, color: SignmeColors.primaryLight),
              tooltip: 'Partager',
              onPressed: () => _share(chant),
            ),
          ],
        ],
      ),
      body: async.when(
        loading: () => ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(SignmeSpacing.lg),
          children: const [
            SignmeSkeleton(width: double.infinity, height: 120, borderRadius: SignmeSpacing.radiusLg),
            SizedBox(height: SignmeSpacing.lg),
            SignmeSkeletonList(itemCount: 3, itemHeight: 150),
          ],
        ),
        error: (e, _) => SignmeErrorState(
          title: 'Chant indisponible',
          message: messageFromError(e),
          icon: e is NetworkException ? Icons.wifi_off_rounded : Icons.error_outline,
          onRetry: () => ref.invalidate(chantDetailProvider(chantId)),
        ),
        data: (chant) => _Lyrics(chant: chant),
      ),
    );
  }

  Future<void> _copy(BuildContext context, ChantDetailEntity chant) async {
    await Clipboard.setData(ClipboardData(text: _shareText(chant)));
    if (context.mounted) AppSnackbar.success(context, 'Paroles copiées');
  }

  void _share(ChantDetailEntity chant) => Share.share(_shareText(chant), subject: chant.title);

  String _shareText(ChantDetailEntity chant) {
    final byline = chant.artist.isEmpty ? chant.title : '${chant.title} — ${chant.artist}';
    return '$byline\n\n${chant.plainText}\n\nPartagé depuis SignMe';
  }
}

class _Lyrics extends ConsumerWidget {
  const _Lyrics({required this.chant});

  final ChantDetailEntity chant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(chantTextScaleProvider);
    final safeBottom = MediaQuery.of(context).padding.bottom;
    var strophe = 0;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        SignmeSpacing.lg,
        SignmeSpacing.lg,
        SignmeSpacing.lg,
        SignmeSpacing.xxxl + safeBottom,
      ),
      children: [
        _Header(chant: chant),
        if (chant.versions.length > 1) ...[
          const SizedBox(height: SignmeSpacing.lg),
          _Versions(chant: chant),
        ],
        const SizedBox(height: SignmeSpacing.lg),
        for (final section in chant.sections) ...[
          LyricsSectionView(
            section: section,
            textScale: scale,
            strophe: section.type == LyricsSectionType.strophe ? ++strophe : null,
          ),
          const SizedBox(height: SignmeSpacing.md),
        ],
        const SizedBox(height: SignmeSpacing.md),
        Text(
          'Paroles fournies par ${chant.sourceName}. Elles restent la propriété de leurs auteurs.',
          style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.chant});

  final ChantDetailEntity chant;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (chant.album != null && chant.album != chant.title) chant.album!,
      if (chant.durationSeconds != null) _formatDuration(chant.durationSeconds!),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.xl),
      decoration: BoxDecoration(
        gradient: SignmeColors.primaryGradientLinear,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.music_note_rounded, color: Colors.white70, size: 28),
          const SizedBox(height: SignmeSpacing.md),
          Text(
            chant.title,
            style: SignmeTypography.headlineLarge.copyWith(color: Colors.white),
          ),
          if (chant.artist.isNotEmpty) ...[
            const SizedBox(height: SignmeSpacing.xs),
            Text(
              chant.artist,
              style: SignmeTypography.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
          if (meta.isNotEmpty) ...[
            const SizedBox(height: SignmeSpacing.sm),
            Text(
              meta.join(' · '),
              style: SignmeTypography.labelSmall.copyWith(color: Colors.white60),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Sélecteur de version : un chip par interprète, la version affichée est
/// cochée ; toucher une autre version remplace l'écran.
class _Versions extends StatelessWidget {
  const _Versions({required this.chant});

  final ChantDetailEntity chant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VERSIONS DISPONIBLES',
          style: SignmeTypography.labelSmall.copyWith(
            color: SignmeColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Wrap(
          spacing: SignmeSpacing.sm,
          runSpacing: SignmeSpacing.sm,
          children: [
            for (final v in chant.versions)
              SignmePillChip(
                label: v.artist.isEmpty ? 'Version ${v.id}' : v.artist,
                selected: v.id == chant.id,
                onTap: () {
                  if (v.id == chant.id) return;
                  context.pushReplacementNamed(
                    'chant-detail',
                    pathParameters: {'id': '${v.id}'},
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
