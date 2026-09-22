import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../providers/about_church_provider.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key, required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  static const _categories = [
    (value: AboutChurchCategory.all, label: 'Tous', icon: Icons.grid_view_rounded),
    (value: AboutChurchCategory.pastor, label: 'Pasteur Actuel', icon: Icons.person_rounded),
    (value: AboutChurchCategory.activity, label: 'Activités Majeures', icon: Icons.star_rounded),
    (value: AboutChurchCategory.group, label: 'Nos Groupes', icon: Icons.groups_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: SignmeSpacing.sm),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selected == cat.value;
          return GestureDetector(
            onTap: () => onChanged(cat.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? SignmeColors.primaryLight : SignmeColors.white,
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                border: Border.all(
                  color: isSelected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected ? Colors.white : SignmeColors.mediumGray,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: SignmeTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : SignmeColors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
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
