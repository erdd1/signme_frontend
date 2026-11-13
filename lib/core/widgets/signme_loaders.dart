import 'package:flutter/material.dart';
import '../design_system/index.dart';
import 'app_button.dart';

// ============================================================================
// SIGNME LOADING & STATE INDICATORS
// ============================================================================

/// CIRCULAR LOADER - Animated circular progress indicator
///
/// Usage:
/// ```dart
/// SignmeLoader()
/// ```
class SignmeLoader extends StatelessWidget {
  const SignmeLoader({
    super.key,
    this.size = 48,
    this.strokeWidth = 3,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(
          color ?? SignmeColors.primary,
        ),
      ),
    );
  }
}

/// LINEAR LOADER - Linear progress bar
///
/// Usage:
/// ```dart
/// SignmeLinearLoader(value: 0.65)
/// ```
class SignmeLinearLoader extends StatelessWidget {
  const SignmeLinearLoader({
    super.key,
    this.value,
    this.minHeight = 4,
    this.color,
    this.backgroundColor,
  });

  final double? value;
  final double minHeight;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(minHeight),
        child: LinearProgressIndicator(
          value: value,
          minHeight: minHeight,
          valueColor: AlwaysStoppedAnimation(
            color ?? SignmeColors.primary,
          ),
          backgroundColor: backgroundColor ?? SignmeColors.lightGray,
        ),
      ),
    );
  }
}

/// SKELETON LOADER - Shimmer placeholder for loading states
///
/// Usage:
/// ```dart
/// SignmeSkeleton(width: 100, height: 20)
/// ```
class SignmeSkeleton extends StatefulWidget {
  const SignmeSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.color,
  });

  final double width;
  final double height;
  final double? borderRadius;
  final Color? color;

  @override
  State<SignmeSkeleton> createState() => _SignmeSkeletonState();
}

class _SignmeSkeletonState extends State<SignmeSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? SignmeSpacing.radiusMd,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _controller.value - 0.1,
                _controller.value,
                _controller.value + 0.1,
              ],
              colors: [
                widget.color ?? SignmeColors.lightGray,
                SignmeColors.white,
                widget.color ?? SignmeColors.lightGray,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// SKELETON LIST - Multiple skeleton rows (like loading list)
///
/// Usage:
/// ```dart
/// SignmeSkeletonList(itemCount: 5)
/// ```
class SignmeSkeletonList extends StatelessWidget {
  const SignmeSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 60,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: SignmeSpacing.md),
          child: SignmeSkeleton(
            width: double.infinity,
            height: itemHeight,
            borderRadius: SignmeSpacing.radiusMd,
          ),
        ),
      ),
    );
  }
}

/// SKELETON DE PAGE - Chargement plein écran (détails, listes) : remplace le
/// spinner centré par un aperçu de la mise en page, comme l'écran du groupe.
class SignmePageSkeleton extends StatelessWidget {
  const SignmePageSkeleton({super.key, this.itemCount = 4, this.itemHeight = 110});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
      children: [SignmeSkeletonList(itemCount: itemCount, itemHeight: itemHeight)],
    );
  }
}

// ============================================================================
// SIGNME EMPTY & ERROR STATES
// ============================================================================

/// EMPTY STATE - Display when no content available
///
/// Usage:
/// ```dart
/// SignmeEmptyState(
///   icon: Icons.inbox,
///   title: 'No Items',
///   message: 'Create your first item to get started',
///   action: SignmePrimaryButton(label: 'Create', onPressed: () {}),
/// )
/// ```
class SignmeEmptyState extends StatelessWidget {
  const SignmeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.iconSize = 64,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: SignmeSpacing.allLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: SignmeColors.mediumGray,
            ),
            SizedBox(height: SignmeSpacing.xl),
            Text(
              title,
              style: SignmeTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SignmeSpacing.md),
            Text(
              message,
              style: SignmeTypography.bodyMedium.copyWith(
                color: SignmeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: SignmeSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// ERROR STATE - Display when error occurred
///
/// Usage:
/// ```dart
/// SignmeErrorState(
///   title: 'Something Went Wrong',
///   message: 'Please try again later',
///   onRetry: () => context.refresh(),
/// )
/// ```
class SignmeErrorState extends StatelessWidget {
  const SignmeErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconSize = 64,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: SignmeSpacing.allLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: SignmeColors.error,
            ),
            SizedBox(height: SignmeSpacing.xl),
            Text(
              title,
              style: SignmeTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SignmeSpacing.md),
            Text(
              message,
              style: SignmeTypography.bodyMedium.copyWith(
                color: SignmeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: SignmeSpacing.xl),
              SizedBox(
                width: 200,
                child: SignmePrimaryButton(
                  label: 'Réessayer',
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// NO PERMISSION STATE - Display when permission denied
///
/// Usage:
/// ```dart
/// SignmeNoPermissionState(
///   title: 'Camera Permission',
///   message: 'Enable camera access to continue',
///   onSettings: () => openAppSettings(),
/// )
/// ```
class SignmeNoPermissionState extends StatelessWidget {
  const SignmeNoPermissionState({
    super.key,
    required this.title,
    required this.message,
    this.onSettings,
    this.icon = Icons.lock_outline,
    this.iconSize = 64,
  });

  final String title;
  final String message;
  final VoidCallback? onSettings;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: SignmeSpacing.allLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: SignmeColors.warning,
            ),
            SizedBox(height: SignmeSpacing.xl),
            Text(
              title,
              style: SignmeTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SignmeSpacing.md),
            Text(
              message,
              style: SignmeTypography.bodyMedium.copyWith(
                color: SignmeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onSettings != null) ...[
              SizedBox(height: SignmeSpacing.xl),
              SizedBox(
                width: 200,
                child: SignmePrimaryButton(
                  label: 'Open Settings',
                  onPressed: onSettings,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LEGACY COMPATIBILITY
// ============================================================================

/// @deprecated Use SignmeLoader instead
class AppShimmer extends SignmeSkeletonList {
  const AppShimmer({
    super.key,
    super.itemCount,
  });
}
