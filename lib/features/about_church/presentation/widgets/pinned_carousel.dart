import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../domain/entities/about_article_entity.dart';

/// Carrousel horizontal réutilisable pour les 3 rows épinglées (pasteurs,
/// groupes, activités) : 1 photo + 1 titre par item, défilement automatique
/// toutes les 3 secondes + swipe manuel. Le tap sur un item déclenche
/// [onItemTap] (utilisé par l'écran pour scroller vers l'article correspondant
/// plus bas dans la même page).
class PinnedCarousel extends StatefulWidget {
  const PinnedCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    this.itemWidth = 150,
    this.itemHeight = 170,
    this.autoScroll = true,
  });

  final String title;
  final List<AboutArticleEntity> items;
  final ValueChanged<AboutArticleEntity> onItemTap;
  final double itemWidth;
  final double itemHeight;
  final bool autoScroll;

  @override
  State<PinnedCarousel> createState() => _PinnedCarouselState();
}

class _PinnedCarouselState extends State<PinnedCarousel> {
  late final PageController _controller;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.42);
    if (widget.autoScroll && widget.items.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_controller.hasClients || widget.items.isEmpty) return;
      _currentPage = (_currentPage + 1) % widget.items.length;
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SignmeSpacing.sm),
        SizedBox(
          height: widget.itemHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            padEnds: false,
            onPageChanged: (i) => _currentPage = i,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.only(right: SignmeSpacing.sm),
                child: _CarouselItem(
                  item: item,
                  width: widget.itemWidth,
                  onTap: () => widget.onItemTap(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CarouselItem extends StatelessWidget {
  const _CarouselItem({required this.item, required this.width, required this.onTap});

  final AboutArticleEntity item;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          border: Border.all(color: SignmeColors.lightGrayBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: item.firstImage != null
                  ? Image.network(
                      item.firstImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).round(),
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const _ImagePlaceholder(),
                      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                    )
                  : const _ImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(SignmeSpacing.sm),
              child: Text(
                item.titre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: SignmeTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SignmeColors.accentSky.withOpacity(0.3),
      child: const Icon(Icons.image_rounded, color: SignmeColors.primaryLight, size: 28),
    );
  }
}
