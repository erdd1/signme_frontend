import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../domain/entities/publication_entity.dart';

class PublicationCard extends StatelessWidget {
  const PublicationCard({
    super.key,
    required this.publication,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  final PublicationEntity publication;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(publication.typeColor);

    return Material(
      color: SignmeColors.white,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(SignmeSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(SignmeSpacing.radiusSm),
                    ),
                    child: Text(
                      publication.typeIcon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: SignmeSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          publication.typeLabel,
                          style: SignmeTypography.labelSmall.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          publication.auteurNom,
                          style: SignmeTypography.labelSmall.copyWith(
                            color: SignmeColors.mediumGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (showActions && (onEdit != null || onDelete != null))
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: SignmeColors.mediumGray,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 20, color: SignmeColors.error),
                                SizedBox(width: 8),
                                Text('Supprimer',
                                    style: TextStyle(color: SignmeColors.error)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.sm),
              Text(
                publication.titre,
                style: SignmeTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                publication.contenu,
                style: SignmeTypography.bodySmall.copyWith(
                  color: SignmeColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SignmeSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    publication.formattedDate,
                    style: SignmeTypography.labelSmall.copyWith(
                      color: SignmeColors.mediumGray,
                    ),
                  ),
                  if (publication.isMeditation &&
                      publication.referenceBiblique != null)
                    Flexible(
                      child: Text(
                        publication.referenceBiblique!,
                        style: SignmeTypography.labelSmall.copyWith(
                          color: SignmeColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
