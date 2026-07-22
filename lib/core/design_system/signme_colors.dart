import 'package:flutter/material.dart';


abstract class SignmeColors {
  // ==================== PRIMARY COLORS ====================
  /// Navy Blue - Deep, professional primary color
  /// Used for: Key actions, headers, emphasis
  static const Color primaryDark = Color(0xFF001F3F);

  /// Modern Blue - Vibrant primary color
  /// Used for: Main interactions, buttons, links
  static const Color primaryLight = Color(0xFF2979F0);

  /// Cyan Accent - Bright, eye-catching accent
  /// Used for: Highlights, secondary actions, badges
  static const Color primaryCyan = Color(0xFF00D4FF);

  /// Primary (alias for primaryLight - main brand color)
  static const Color primary = primaryLight;

  // ==================== NEUTRAL COLORS ====================
  /// Pure Soft White - Main background color
  /// Used for: Page backgrounds, cards
  static const Color white = Color(0xFFFAFAFA);

  /// Off-White - Alternative light background
  /// Used for: Subtle background variations
  static const Color offWhite = Color(0xFFFDFDFD);

  /// Light Gray - Light surface elements
  /// Used for: Disabled states, subtle backgrounds
  static const Color lightGray = Color(0xFFF5F5F5);

  /// Medium Gray - Medium-weight neutral
  /// Used for: Borders, dividers
  static const Color mediumGray = Color(0xFF9E9E9E);

  /// Light Gray Border - Subtle borders and dividers
  /// Used for: Input borders, dividers, subtle separations
  static const Color lightGrayBorder = Color(0xFFE0E0E0);

  /// Dark Gray - Dark neutral text
  /// Used for: Secondary text, hints
  static const Color darkGray = Color(0xFF616161);

  /// Almost Black - Darkest neutral
  /// Used for: Primary text, dark elements
  static const Color black = Color(0xFF1A1A1A);

  // ==================== SEMANTIC BACKGROUNDS ====================
  /// Main page background
  static const Color background = offWhite;

  /// Surface for cards, containers
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant for subtle differentiation
  static const Color surfaceVariant = lightGray;

  // ==================== TEXT COLORS ====================
  /// Primary text color - high contrast
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Secondary text color - used for descriptions, hints
  static const Color textSecondary = Color(0xFF6B7A99);

  /// Text on light surfaces
  static const Color onSurface = Color(0xFF0D1B3E);

  // ==================== STATUS COLORS ====================
  /// Success - Green for confirmations
  static const Color success = Color(0xFF4CAF50);

  /// Error - Red for failures, warnings
  static const Color error = Color(0xFFFF5252);

  /// Warning - Amber for cautions
  static const Color warning = Color(0xFFFFC107);

  /// Info - Blue for informational messages
  static const Color info = Color(0xFF2196F3);

  // ==================== GRADIENTS ====================
  /// Primary gradient (Navy to Blue)
  /// Used for: Button backgrounds, feature highlights
  static const List<Color> primaryGradient = [
    primaryDark, // #001F3F
    primaryLight, // #2979F0
  ];

  /// Button gradient - bold and interactive
  static const List<Color> buttonGradient = [
    primaryDark, // #001F3F
    primaryLight, // #2979F0
  ];

  /// Splash gradient - for splash screens
  static const List<Color> splashGradient = [
    primaryDark,
    primaryLight,
  ];

  /// Subtle blue gradient - for backgrounds
  static const List<Color> subtleGradientBlue = [
    Color(0xFFE3F2FD), // Light blue
    Color(0xFFF5F5F5), // Light gray
  ];

  // ==================== ACCENT COLORS ====================
  /// Light sky blue - for backgrounds, illustrations
  static const Color accentSky = Color(0xFFE3F2FD);

  // ==================== DISABLED & INACTIVE ====================
  /// Color for disabled elements
  static const Color disabled = Color(0xFFBDBDBD);

  /// Color for inactive/skeleton states
  static const Color skeleton = Color(0xFFE0E0E0);

  // ==================== ROLE-BASED COLORS (Optional) ====================
  /// For role-specific applications (e.g., USER, SIGNER)
  /// Expand as needed for your features
  static const Color roleUser = primaryLight;
  static const Color roleSigner = primaryCyan;

  // ==================== UTILITY METHODS ====================
  /// Get primary color with opacity
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);

  /// Get gradient as LinearGradient widget
  static LinearGradient get primaryGradientLinear =>
      LinearGradient(colors: primaryGradient);

  static LinearGradient get buttonGradientLinear =>
      LinearGradient(colors: buttonGradient);

  /// Material ColorScheme for Material 3 theme
  static ColorScheme get colorScheme => ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: Color(0xFFE3F2FD),
        onPrimaryContainer: primaryDark,
        secondary: primaryCyan,
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFB3E5FF),
        onSecondaryContainer: Color(0xFF001F3F),
        tertiary: warning,
        onTertiary: Color(0xFFFFFFFF),
        error: error,
        onError: Color(0xFFFFFFFF),
        background: background,
        onBackground: onSurface,
        surface: surface,
        onSurface: onSurface,
        outline: mediumGray,
        outlineVariant: lightGray,
        scrim: Color(0xFF000000),
        shadow: Color(0xFF000000),
        inverseSurface: Color(0xFF1A1A1A),
        onInverseSurface: Color(0xFFFFFFFF),
        inversePrimary: primaryCyan,
        surfaceTint: primary,
      );
}
