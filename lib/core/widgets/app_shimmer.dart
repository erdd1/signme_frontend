import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

/// Widget shimmer réutilisable — boîte de chargement animée
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8.0,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:     AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width:  width,
        height: height,
        decoration: BoxDecoration(
          color:        AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Shimmer — carte publication
class PublicationCardShimmer extends StatelessWidget {
  const PublicationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.shimmerBase,
                highlightColor: AppColors.shimmerHighlight,
                child: Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.shimmerBase,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: 100, height: 12, radius: 6),
                  const SizedBox(height: 4),
                  AppShimmerBox(width: 160, height: 10, radius: 5),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppShimmerBox(width: double.infinity, height: 14, radius: 6),
          const SizedBox(height: 6),
          AppShimmerBox(width: 200, height: 12, radius: 5),
          const SizedBox(height: 8),
          AppShimmerBox(width: double.infinity, height: 12, radius: 5),
          const SizedBox(height: 4),
          AppShimmerBox(width: 280, height: 12, radius: 5),
        ],
      ),
    );
  }
}

/// Shimmer compact — case du tableau « Ma Carte » (montant)
class TableCellShimmer extends StatelessWidget {
  const TableCellShimmer({
    super.key,
    this.width = 36,
    this.height = 10,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppShimmerBox(width: width, height: height, radius: 4),
    );
  }
}

/// Shimmer — ligne de tableau
class TableRowShimmer extends StatelessWidget {
  const TableRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(width: 60, height: 12, decoration: BoxDecoration(color: AppColors.shimmerBase, borderRadius: BorderRadius.circular(6))),
            const Spacer(),
            Container(width: 40, height: 12, decoration: BoxDecoration(color: AppColors.shimmerBase, borderRadius: BorderRadius.circular(6))),
            const Spacer(),
            Container(width: 80, height: 12, decoration: BoxDecoration(color: AppColors.shimmerBase, borderRadius: BorderRadius.circular(6))),
          ],
        ),
      ),
    );
  }
}

/// Shimmer — carte "Ma Carte" header
class CarteHeaderShimmer extends StatelessWidget {
  const CarteHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Shimmer — profil header
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Row(
        children: [
          Container(width: 64, height: 64, decoration: const BoxDecoration(color: AppColors.shimmerBase, shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 40, height: 11, decoration: BoxDecoration(color: AppColors.shimmerBase, borderRadius: BorderRadius.circular(6))),
              const SizedBox(height: 6),
              Container(width: 120, height: 14, decoration: BoxDecoration(color: AppColors.shimmerBase, borderRadius: BorderRadius.circular(7))),
            ],
          ),
        ],
      ),
    );
  }
}
