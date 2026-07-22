/// SIGNME Design System
/// 
/// Complete design system export with:
/// - SignmeColors: Color palette
/// - SignmeTypography: Text styles
/// - SignmeSpacing: Spacing & sizing
///
/// Usage:
/// ```dart
/// import 'design_system/index.dart';
///
/// Container(
///   padding: EdgeInsets.all(SignmeSpacing.lg),
///   color: SignmeColors.surface,
///   child: Text(
///     'Welcome',
///     style: SignmeTypography.displayMedium,
///   ),
/// )
/// ```

export 'signme_colors.dart';
export 'signme_typography.dart';
export 'signme_spacing.dart';
