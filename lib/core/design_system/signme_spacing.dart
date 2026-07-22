import 'package:flutter/material.dart';

/// SIGNME Design System - Spacing & Sizing
/// 
/// Systematic spacing scale and component dimensions for consistency.
/// All values are carefully chosen for visual harmony and accessibility.
///
/// Usage:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(SignmeSpacing.md),
///   child: Container(
///     height: SignmeSpacing.buttonHeight,
///     child: MyButton(),
///   ),
/// )
/// ```
abstract class SignmeSpacing {
  // ==================== SPACING SCALE (Base unit: 4px) ====================
  /// 4px - Minimal spacing
  static const double xs = 4.0;

  /// 8px - Small spacing
  static const double sm = 8.0;

  /// 12px - Medium spacing (common)
  static const double md = 12.0;

  /// 16px - Large spacing (common)
  static const double lg = 20.0;//16.0

  /// 20px - Extra large spacing
  static const double xl = 20.0;

  /// 24px - 2x Extra large spacing
  static const double xxl = 24.0;

  /// 32px - 3x Extra large spacing
  static const double xxxl = 32.0;

  /// 48px - Huge spacing
  static const double huge = 48.0;

  /// 64px - Massive spacing (rarely used)
  static const double massive = 64.0;

  // ==================== COMPONENT HEIGHTS ====================
  /// Standard button height
  static const double buttonHeight = 52.0;

  /// Small button height
  static const double buttonHeightSmall = 40.0;

  /// Text field / Input height
  static const double textFieldHeight = 56.0;

  /// AppBar height (Material standard)
  static const double appBarHeight = 56.0;

  /// Tab bar height
  static const double tabBarHeight = 48.0;

  /// List item height (default)
  static const double listItemHeight = 56.0;

  /// Card minimum height
  static const double cardMinHeight = 100.0;

  // ==================== COMPONENT WIDTHS ====================
  /// Minimum touch target size (accessibility: 48x48 is recommended)
  static const double touchTarget = 48.0;

  /// Card min width
  static const double cardMinWidth = 100.0;

  // ==================== PADDING & MARGIN ====================
  /// Screen/page padding - main horizontal padding
  static const double screenPaddingHorizontal = 16.0;

  /// Screen/page padding - vertical
  static const double screenPaddingVertical = 20.0;

  /// Card padding (inside)
  static const double cardPadding = 16.0;

  /// Content padding (medium)
  static const double contentPadding = 16.0;

  /// Dense padding (compact content)
  static const double densePadding = 8.0;

  // ==================== ICON SIZES ====================
  /// Extra small icon - 16px
  static const double iconXs = 16.0;

  /// Small icon - 20px
  static const double iconSm = 20.0;

  /// Medium icon - 24px (most common)
  static const double iconMd = 24.0;

  /// Large icon - 32px
  static const double iconLg = 32.0;

  /// Extra large icon - 48px
  static const double iconXl = 48.0;

  /// 2x Extra large icon - 64px
  static const double iconXxl = 64.0;

  // ==================== BORDER RADIUS ====================
  /// Extra small radius - 4px (subtle)
  static const double radiusXs = 4.0;

  /// Small radius - 8px
  static const double radiusSm = 8.0;

  /// Medium radius - 12px (common)
  static const double radiusMd = 12.0;

  /// Large radius - 16px
  static const double radiusLg = 16.0;

  /// Extra large radius - 20px
  static const double radiusXl = 20.0;

  /// 2x Extra large radius - 24px
  static const double radiusXxl = 24.0;

  /// Full radius - circle (9999)
  static const double radiusFull = 9999.0;

  // ==================== BORDER WIDTHS ====================
  /// Thin border
  static const double borderThin = 1.0;

  /// Medium border
  static const double borderMedium = 1.5;

  /// Thick border
  static const double borderThick = 2.0;

  // ==================== SHADOW / ELEVATION ====================
  /// Subtle shadow (elevation 1)
  static const double shadowElevation1 = 2.0;

  /// Light shadow (elevation 2)
  static const double shadowElevation2 = 4.0;

  /// Medium shadow (elevation 3)
  static const double shadowElevation3 = 8.0;

  /// Heavy shadow (elevation 4)
  static const double shadowElevation4 = 12.0;

  // ==================== DIVIDER & LINE ====================
  /// Divider height
  static const double dividerHeight = 1.0;

  /// Thick divider/line
  static const double dividerThick = 2.0;

  // ==================== GAPS (Spacer widgets) ====================
  /// Extra small gap - used in SizedBox or Spacer
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);

  /// Small gap
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);

  /// Medium gap
  static const SizedBox gapMd = SizedBox(width: md, height: md);

  /// Large gap
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);

  /// Extra large gap
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);

  /// 2x Extra large gap
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);

  /// 3x Extra large gap
  static const SizedBox gapXxxl = SizedBox(width: xxxl, height: xxxl);

  /// Huge gap
  static const SizedBox gapHuge = SizedBox(width: huge, height: huge);

  // ==================== VERTICAL GAPS ====================
  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
  static const SizedBox vGapXxl = SizedBox(height: xxl);
  static const SizedBox vGapXxxl = SizedBox(height: xxxl);
  static const SizedBox vGapHuge = SizedBox(height: huge);

  // ==================== HORIZONTAL GAPS ====================
  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapLg = SizedBox(width: lg);
  static const SizedBox hGapXl = SizedBox(width: xl);
  static const SizedBox hGapXxl = SizedBox(width: xxl);
  static const SizedBox hGapXxxl = SizedBox(width: xxxl);
  static const SizedBox hGapHuge = SizedBox(width: huge);

  // ==================== EDGEINSETS PRESETS ====================
  /// All sides - extra small
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  /// Symmetric horizontal
  static const EdgeInsets symmHXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets symmHSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets symmHMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets symmHLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets symmHXl = EdgeInsets.symmetric(horizontal: xl);

  /// Symmetric vertical
  static const EdgeInsets symmVXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets symmVSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets symmVMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets symmVLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets symmVXl = EdgeInsets.symmetric(vertical: xl);

  /// Symmetric horizontal + vertical
  static const EdgeInsets symmMdMd =
      EdgeInsets.symmetric(horizontal: md, vertical: md);
  static const EdgeInsets symmLgLg =
      EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets symmLgMd =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // ==================== ONLY EDGEINSETS ====================
  static const EdgeInsets onlyTopSm = EdgeInsets.only(top: sm);
  static const EdgeInsets onlyTopMd = EdgeInsets.only(top: md);
  static const EdgeInsets onlyTopLg = EdgeInsets.only(top: lg);

  static const EdgeInsets onlyBottomSm = EdgeInsets.only(bottom: sm);
  static const EdgeInsets onlyBottomMd = EdgeInsets.only(bottom: md);
  static const EdgeInsets onlyBottomLg = EdgeInsets.only(bottom: lg);

  static const EdgeInsets onlyLeftMd = EdgeInsets.only(left: md);
  static const EdgeInsets onlyLeftLg = EdgeInsets.only(left: lg);

  static const EdgeInsets onlyRightMd = EdgeInsets.only(right: md);
  static const EdgeInsets onlyRightLg = EdgeInsets.only(right: lg);

  // ==================== ANIMATION DURATIONS ====================
  /// Fast animations (quick feedback)
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Medium animations (standard)
  static const Duration animationMedium = Duration(milliseconds: 300);

  /// Slow animations (smooth transitions)
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Very slow (leisurely)
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // ==================== INPUT FIELD SPECIFIC ====================
  /// Input field border radius
  static const double inputBorderRadius = radiusMd; // 12px

  /// Input field horizontal padding
  static const double inputPaddingHorizontal = lg; // 16px

  /// Input field vertical padding
  static const double inputPaddingVertical = md; // 12px

  /// Input field content padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: inputPaddingHorizontal,
    vertical: inputPaddingVertical,
  );

  // ==================== BUTTON SPECIFIC ====================
  /// Button border radius
  static const double buttonBorderRadius = radiusMd; // 12px

  /// Button horizontal padding
  static const double buttonPaddingHorizontal = lg; // 16px

  /// Button vertical padding
  static const double buttonPaddingVertical = md; // 12px

  /// Button content padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );

  // ==================== NAVBAR FLOTTANTE ====================
  /// Padding bas à appliquer à tout contenu scrollable/bottom-sheet pour ne
  /// pas être masqué par la navbar flottante de MainShell (overlay au-dessus
  /// du contenu de route, y compris les bottom sheets modaux).
  static const double navbarClearance = 120.0;

  // ==================== CARD SPECIFIC ====================
  /// Card border radius
  static const double cardBorderRadius = radiusLg; // 16px

  /// Card padding
  static const EdgeInsets cardContentPadding = EdgeInsets.all(lg); // 16px

  /// Card elevation shadow blur
  static const double cardShadowBlur = shadowElevation2; // 4px

  // ==================== UTILITY METHODS ====================
  /// Create a custom EdgeInsets
  static EdgeInsets custom({
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
  }) =>
      EdgeInsets.only(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
      );

  /// Create a custom symmetric EdgeInsets
  static EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  /// Horizontal padding for screens
  static EdgeInsets get screenPaddingH =>
      EdgeInsets.symmetric(horizontal: screenPaddingHorizontal);

  /// Vertical padding for screens
  static EdgeInsets get screenPaddingV =>
      EdgeInsets.symmetric(vertical: screenPaddingVertical);

  /// Both horizontal and vertical screen padding
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: screenPaddingHorizontal,
        vertical: screenPaddingVertical,
      );
}
