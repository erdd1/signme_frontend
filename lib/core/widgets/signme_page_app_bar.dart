import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design_system/index.dart';
import '../router/app_router.dart';

/// En-tête unique des écrans de détail et de formulaire : flèche de retour,
/// puis grand titre aligné à gauche — le même langage visuel que l'écran du
/// groupe et les services. Remplace les AppBar recopiées dans chaque écran.
///
/// Le retour dépile l'écran ; s'il n'y a rien à dépiler (arrivée par un lien
/// ou une notification), il ramène à l'accueil.
class SignmePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SignmePageAppBar({
    super.key,
    required this.title,
    this.backEnabled = true,
    this.actions,
    this.bottom,
  });

  final String title;

  /// Faux pendant un enregistrement : la flèche est désactivée.
  final bool backEnabled;
  final List<Widget>? actions;

  /// Widget placé sous le titre (ex. une `TabBar`).
  final PreferredSizeWidget? bottom;

  static const double _titleHeight = 52;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + _titleHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SignmeColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
        tooltip: 'Retour',
        onPressed: backEnabled ? () => context.canPop() ? context.pop() : context.go(AppRoutes.home) : null,
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_titleHeight + (bottom?.preferredSize.height ?? 0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _titleHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: SignmeTypography.displaySmall.copyWith(fontWeight: FontWeight.w900, height: 1.2),
                    ),
                  ),
                ),
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}
