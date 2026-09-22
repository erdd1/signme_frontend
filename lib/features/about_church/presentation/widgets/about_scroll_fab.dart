import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

/// FAB flottant discret : scrolle tout en bas si l'utilisateur est plutôt en
/// haut de la page, tout en haut sinon. Bascule dynamiquement selon la
/// position de scroll actuelle.
class AboutScrollFab extends StatelessWidget {
  const AboutScrollFab({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        // `hasClients` seul ne garantit pas que `position.maxScrollExtent`
        // soit déjà calculé (premier layout pas encore terminé) — y accéder
        // trop tôt lève un "Null check operator used on a null value".
        final canReadPosition =
            scrollController.hasClients && scrollController.position.hasContentDimensions;
        final isNearTop = !canReadPosition ||
            scrollController.offset < (scrollController.position.maxScrollExtent / 2);

        return FloatingActionButton.small(
          heroTag: 'about_church_scroll_fab',
          backgroundColor: SignmeColors.primaryLight,
          onPressed: () {
            if (!canReadPosition) return;
            scrollController.animateTo(
              isNearTop ? scrollController.position.maxScrollExtent : 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
          child: Icon(
            isNearTop ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
