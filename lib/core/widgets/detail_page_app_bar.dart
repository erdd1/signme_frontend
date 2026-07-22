import 'package:flutter/material.dart';
import 'package:signme/core/design_system/index.dart';

/// AppBar for Detail Pages - Menu (left) + Title (center) + Actions (right)
class DetailPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final List<Widget> actions;

  const DetailPageAppBar({
    Key? key,
    required this.title,
    this.onMenuTap,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SignmeColors.white,
      elevation: 0,
      leading: onMenuTap != null
          ? GestureDetector(
              onTap: onMenuTap,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SignmeColors.accentSky,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: SignmeColors.primaryDark,
                  size: 24,
                ),
              ),
            )
          : null,
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            SignmeColors.primaryDark,
            SignmeColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          title,
          style: TextStyle(
            color: SignmeColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
