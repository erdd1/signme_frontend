import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/index.dart';
import 'app_button.dart';
import 'app_shimmer.dart';
import 'signme_loaders.dart';

/// Contenu scrollable dans un espace à hauteur limitée (évite les overflows).
class SignmeViewportFit extends StatelessWidget {
  const SignmeViewportFit({
    super.key,
    required this.child,
    this.align = Alignment.topCenter,
  });

  final Widget child;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        if (!maxH.isFinite) {
          return child;
        }
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: maxH),
            child: Align(alignment: align, child: child),
          ),
        );
      },
    );
  }
}

/// Affiche loading / erreur / vide / contenu pour un [AsyncValue] Riverpod.
class SignmeAsyncValue<T> extends StatelessWidget {
  const SignmeAsyncValue({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Aucun contenu',
    this.emptyMessage = 'Revenez plus tard pour voir les nouveautés.',
    this.isEmpty,
    this.padding,
    this.fitViewport = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final VoidCallback? onRetry;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final bool Function(T data)? isEmpty;
  final EdgeInsetsGeometry? padding;
  /// Enveloppe loading/erreur/vide pour les parents à hauteur fixe (SliverFillRemaining…).
  final bool fitViewport;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => _wrapIfNeeded(loading ?? const _DefaultListLoading()),
      error: (err, _) => _wrapIfNeeded(
        SignmeErrorState(
          title: 'Chargement impossible',
          message: _humanizeError(err),
          onRetry: onRetry,
        ),
      ),
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return _wrapIfNeeded(
            SignmeEmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
              action: onRetry != null
                  ? SignmePrimaryButton(
                      label: 'Actualiser',
                      onPressed: onRetry,
                    )
                  : null,
            ),
          );
        }
        final child = data(d);
        if (padding != null) {
          return Padding(padding: padding!, child: child);
        }
        return child;
      },
    );
  }

  Widget _wrapIfNeeded(Widget child) {
    if (!fitViewport) return child;
    return SignmeViewportFit(
      align: Alignment.center,
      child: child,
    );
  }

  static String _humanizeError(Object err) {
    final raw = err.toString();
    if (raw.contains('AppException')) {
      return raw.replaceFirst(RegExp(r'^.*AppException\(\d+\):\s*'), '');
    }
    if (raw.contains('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return 'Vérifiez votre connexion et réessayez.';
  }

  /// Slivers pour [CustomScrollView] sans overflow (préférer [SliverList] dans [data]).
  static List<Widget> buildSlivers<T>({
    required AsyncValue<T> value,
    required List<Widget> Function(T data) data,
    Widget? loading,
    VoidCallback? onRetry,
    IconData emptyIcon = Icons.inbox_outlined,
    String emptyTitle = 'Aucun contenu',
    String emptyMessage = 'Revenez plus tard pour voir les nouveautés.',
    bool Function(T data)? isEmpty,
  }) {
    return value.when(
      loading: () => [
        SliverToBoxAdapter(
          child: loading ?? const _DefaultListLoading(),
        ),
      ],
      error: (err, _) => [
        SliverFillRemaining(
          hasScrollBody: true,
          child: SignmeViewportFit(
            align: Alignment.center,
            child: SignmeErrorState(
              title: 'Chargement impossible',
              message: _humanizeError(err),
              onRetry: onRetry,
            ),
          ),
        ),
      ],
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return [
            SliverFillRemaining(
              hasScrollBody: true,
              child: SignmeViewportFit(
                align: Alignment.center,
                child: SignmeEmptyState(
                  icon: emptyIcon,
                  title: emptyTitle,
                  message: emptyMessage,
                  action: onRetry != null
                      ? SignmePrimaryButton(
                          label: 'Actualiser',
                          onPressed: onRetry,
                        )
                      : null,
                ),
              ),
            ),
          ];
        }
        return data(d);
      },
    );
  }
}

/// État chargement / erreur pour [StateNotifier] (données optionnelles).
class SignmeLoadableBody extends StatelessWidget {
  const SignmeLoadableBody({
    super.key,
    required this.isLoading,
    required this.hasData,
    required this.child,
    this.error,
    this.onRetry,
    this.initialLoading,
    this.showRefreshBar = true,
  });

  final bool isLoading;
  final bool hasData;
  final Widget child;
  final String? error;
  final VoidCallback? onRetry;
  final Widget? initialLoading;
  final bool showRefreshBar;

  @override
  Widget build(BuildContext context) {
    if (error != null && !hasData) {
      return SignmeViewportFit(
        align: Alignment.center,
        child: SignmeErrorState(
          title: 'Chargement impossible',
          message: _sanitize(error!),
          onRetry: onRetry,
        ),
      );
    }

    if (isLoading && !hasData && initialLoading != null) {
      return SignmeViewportFit(child: initialLoading!);
    }

    return Stack(
      children: [
        child,
        if (isLoading && showRefreshBar)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(SignmeColors.primaryLight),
            ),
          ),
      ],
    );
  }

  static String _sanitize(String e) {
    if (e.length > 180) return '${e.substring(0, 180)}…';
    return e.replaceFirst('Exception:', '').trim();
  }
}

class _DefaultListLoading extends StatelessWidget {
  const _DefaultListLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SignmeSpacing.lg,
        vertical: SignmeSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          2,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: SignmeSpacing.md),
            child: PublicationCardShimmer(),
          ),
        ),
      ),
    );
  }
}
