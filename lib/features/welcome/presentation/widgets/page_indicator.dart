import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

/// Widget affichant les indicateurs de page (dots)
class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.xxl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalPages,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 8,
            width: currentPage == index ? 28 : 8,
            decoration: BoxDecoration(
              color: currentPage == index
                  ? SignmeColors.primaryLight
                  : SignmeColors.skeleton,
               borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
