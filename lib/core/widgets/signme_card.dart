import 'package:flutter/material.dart';
import '../design_system/index.dart';

// ============================================================================
// SIGNME CARD COMPONENTS
// ============================================================================

/// BASIC CARD - Elevated container with shadow and styling
/// 
/// Used for: Content grouping, sections, data display
/// 
/// Usage:
/// ```dart
/// SignmeCard(
///   child: Column(
///     children: [
///       Text('Title', style: SignmeTypography.headlineSmall),
///       SizedBox(height: SignmeSpacing.md),
///       Text('Content'),
///     ],
///   ),
/// )
/// ```
class SignmeCard extends StatelessWidget {
  const SignmeCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
    this.elevation = 0,
    this.onTap,
    this.border,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(
          borderRadius ?? SignmeSpacing.cardBorderRadius,
        ),
        color: backgroundColor ?? SignmeColors.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? SignmeSpacing.cardBorderRadius,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: border ??
                  Border.all(
                    color: borderColor ?? SignmeColors.lightGray,
                    width: 0.8,
                  ),
              borderRadius: BorderRadius.circular(
                borderRadius ?? SignmeSpacing.cardBorderRadius,
              ),
            ),
            padding: padding ?? SignmeSpacing.cardContentPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// GRADIENT CARD - Card with gradient background
/// 
/// Used for: Featured content, highlights, promotions
/// 
/// Usage:
/// ```dart
/// SignmeGradientCard(
///   gradient: LinearGradient(colors: SignmeColors.primaryGradient),
///   child: Text('Featured', style: SignmeTypography.headlineMedium),
/// )
/// ```
class SignmeGradientCard extends StatelessWidget {
  const SignmeGradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final Gradient gradient;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(
          borderRadius ?? SignmeSpacing.cardBorderRadius,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? SignmeSpacing.cardBorderRadius,
          ),
          child: Padding(
            padding: padding ?? SignmeSpacing.cardContentPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// HERO CARD - Carte héros au dégradé de marque (solde, total, résumé).
///
/// Référence unique des cartes bleues de l'app (caisse du groupe, soldes,
/// totaux) : même dégradé, même rayon, même ombre partout.
class SignmeHeroCard extends StatelessWidget {
  const SignmeHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SignmeSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.primaryLight.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Montant principal d'une [SignmeHeroCard] : blanc, très gras, et réduit
/// automatiquement s'il ne tient pas sur la largeur (grands montants, petits
/// écrans).
class SignmeHeroAmount extends StatelessWidget {
  const SignmeHeroAmount(this.amount, {super.key});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        amount,
        maxLines: 1,
        style: SignmeTypography.headlineLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 30,
        ),
      ),
    );
  }
}

/// OUTLINE CARD - Bordered card without background
/// 
/// Used for: Secondary content, minimal design
/// 
/// Usage:
/// ```dart
/// SignmeOutlineCard(
///   child: MyWidget(),
/// )
/// ```
class SignmeOutlineCard extends StatelessWidget {
  const SignmeOutlineCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderRadius,
    this.borderWidth = 1.5,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? borderColor;
  final double? borderRadius;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? SignmeColors.primary,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(
          borderRadius ?? SignmeSpacing.cardBorderRadius,
        ),
      ),
      child: Material(
        color: SignmeColors.surface,
        borderRadius: BorderRadius.circular(
          borderRadius ?? SignmeSpacing.cardBorderRadius,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? SignmeSpacing.cardBorderRadius,
          ),
          child: Padding(
            padding: padding ?? SignmeSpacing.cardContentPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// STAT CARD - Display metric/statistic in a card
/// 
/// Used for: Dashboard stats, KPIs, metrics
/// 
/// Usage:
/// ```dart
/// SignmeStatCard(
///   label: 'Total Signatures',
///   value: '1,234',
///   icon: Icons.assignment,
/// )
/// ```
class SignmeStatCard extends StatelessWidget {
  const SignmeStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.backgroundColor,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SignmeCard(
      backgroundColor: backgroundColor ?? SignmeColors.background,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(bottom: SignmeSpacing.md),
              child: Icon(
                icon,
                size: SignmeSpacing.iconLg,
                color: SignmeColors.primary,
              ),
            ),
          Text(
            value,
            style: SignmeTypography.displaySmall,
          ),
          SizedBox(height: SignmeSpacing.sm),
          Text(
            label,
            style: SignmeTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// LIST ITEM CARD - Card designed as list item
/// 
/// Used for: Lists, menus, selectable items
/// 
/// Usage:
/// ```dart
/// SignmeListItemCard(
///   title: 'Item Title',
///   subtitle: 'Item description',
///   leading: Icon(Icons.check_circle),
///   trailing: Icon(Icons.arrow_forward),
///   onTap: () {},
/// )
/// ```
class SignmeListItemCard extends StatelessWidget {
  const SignmeListItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.margin,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return SignmeCard(
      margin: margin ?? EdgeInsets.only(bottom: SignmeSpacing.sm),
      borderColor:
          selected ? SignmeColors.primary : SignmeColors.lightGray,
      backgroundColor:
          selected ? SignmeColors.background : SignmeColors.surface,
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: SignmeSpacing.lg,
        vertical: SignmeSpacing.md,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            SizedBox(
              width: SignmeSpacing.iconMd,
              height: SignmeSpacing.iconMd,
              child: leading,
            ),
            SizedBox(width: SignmeSpacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: SignmeTypography.titleLarge,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: SignmeSpacing.xs),
                  Text(
                    subtitle!,
                    style: SignmeTypography.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: SignmeSpacing.lg),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// EXPANDABLE CARD - Card that can be expanded/collapsed
/// 
/// Used for: Accordions, collapsible sections
/// 
/// Usage:
/// ```dart
/// SignmeExpandableCard(
///   title: 'Details',
///   child: Text('Expandable content'),
/// )
/// ```
class SignmeExpandableCard extends StatefulWidget {
  const SignmeExpandableCard({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.onExpanded,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpanded;

  @override
  State<SignmeExpandableCard> createState() => _SignmeExpandableCardState();
}

class _SignmeExpandableCardState extends State<SignmeExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: SignmeSpacing.animationMedium,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    if (_isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onExpanded?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return SignmeCard(
      margin: EdgeInsets.only(bottom: SignmeSpacing.sm),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SignmeSpacing.lg,
                  vertical: SignmeSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: SignmeTypography.titleLarge,
                      ),
                    ),
                    RotationTransition(
                      turns: _animation,
                      child: Icon(
                        Icons.expand_more,
                        color: SignmeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Padding(
              padding: EdgeInsets.only(
                top: SignmeSpacing.md,
                bottom: SignmeSpacing.md,
                left: SignmeSpacing.lg,
                right: SignmeSpacing.lg,
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LEGACY COMPATIBILITY - Aliases for existing code
// ============================================================================

/// @deprecated Use SignmeCard instead
class AppCard extends SignmeCard {
  const AppCard({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.borderColor,
    super.backgroundColor,
    super.borderRadius,
    super.elevation,
    super.onTap,
    super.border,
  });
}
