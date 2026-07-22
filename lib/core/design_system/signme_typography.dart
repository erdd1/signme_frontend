import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signme_colors.dart';

/// SIGNME Design System - Typography
/// 
/// Complete Material 3 text hierarchy using:
/// - Poppins for Headlines & Display (bold, prominent)
/// - Inter for Body & Labels (clean, readable)
///
/// Text styles are organized by category and usage:
/// - Display: Largest, page headlines
/// - Headline: Section titles
/// - Title: Component titles
/// - Body: Main content paragraphs
/// - Label: Small emphasis (buttons, tags)
///
/// Usage:
/// ```dart
/// Text(
///   'Welcome to SIGNME',
///   style: SignmeTypography.displayMedium,
/// )
/// ```
abstract class SignmeTypography {
  // ==================== BASE FONTS ====================
  static TextTheme get _poppinsTheme => GoogleFonts.poppinsTextTheme();
  static TextTheme get _interTheme => GoogleFonts.interTextTheme();

  // ==================== DISPLAY STYLES (Page Headlines) ====================
  /// 32px, Bold, Poppins - Main page headline
  /// Usage: App main titles, splash screen titles
  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.25,
        color: SignmeColors.onSurface,
      );

  /// 28px, Bold, Poppins - Page section headline
  /// Usage: Feature screen headers
  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: SignmeColors.onSurface,
      );

  /// 24px, W600, Poppins - Prominent headline
  /// Usage: Dialog titles, card headers
  static TextStyle get displaySmall => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: SignmeColors.onSurface,
      );

  // ==================== HEADLINE STYLES (Section Titles) ====================
  /// 20px, W600, Poppins - Large section title
  /// Usage: Feature area titles
  static TextStyle get headlineLarge => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: SignmeColors.onSurface,
      );

  /// 18px, W600, Poppins - Medium section title
  /// Usage: Subsection headers, important labels
  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: SignmeColors.onSurface,
      );

  /// 16px, W600, Poppins - Small section title
  /// Usage: Card subtitles, list headers
  static TextStyle get headlineSmall => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: SignmeColors.onSurface,
      );

  // ==================== TITLE STYLES (Component Titles) ====================
  /// 16px, W600, Poppins - Large component title
  /// Usage: Input labels, form titles
  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: SignmeColors.onSurface,
      );

  /// 14px, W500, Poppins - Medium component title
  /// Usage: Regular labels, emphasis text
  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.57,
        color: SignmeColors.onSurface,
      );

  /// 12px, W500, Poppins - Small component title
  /// Usage: Small labels, metadata
  static TextStyle get titleSmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.66,
        color: SignmeColors.onSurface,
      );

  // ==================== BODY STYLES (Main Content) ====================
  /// 16px, W400, Inter - Large body text
  /// Usage: Main paragraph content, explanations
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: SignmeColors.onSurface,
      );

  /// 14px, W400, Inter - Medium body text
  /// Usage: Form content, descriptions
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.57,
        color: SignmeColors.onSurface,
      );

  /// 12px, W400, Inter - Small body text
  /// Usage: Helper text, hints, captions
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.66,
        color: SignmeColors.textSecondary,
      );

  // ==================== LABEL STYLES (Buttons, Tags) ====================
  /// 14px, W500, Poppins - Large label
  /// Usage: Button text, important tags
  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.57,
        letterSpacing: 0.5,
        color: SignmeColors.onSurface,
      );

  /// 12px, W500, Poppins - Medium label
  /// Usage: Regular tags, badges
  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.66,
        letterSpacing: 0.4,
        color: SignmeColors.onSurface,
      );

  /// 11px, W500, Poppins - Small label
  /// Usage: Small badges, fine print
  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.72,
        letterSpacing: 0.3,
        color: SignmeColors.onSurface,
      );

  // ==================== SPECIFIC USE CASES ====================
  /// Button text style - 16px, W600, white color
  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: SignmeColors.onPrimary,
      );

  /// Input label style - 14px, W500, on surface
  static TextStyle get inputLabel => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.57,
        color: SignmeColors.onSurface,
      );

  /// Helper/error text style - 12px, W400, secondary
  static TextStyle get helperText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.66,
        color: SignmeColors.textSecondary,
      );

  /// Placeholder text - dimmed appearance
  static TextStyle get placeholder => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.57,
        color: SignmeColors.darkGray,
      );

  /// Link/action text - primary color
  static TextStyle get link => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.57,
        color: SignmeColors.primary,
        decoration: TextDecoration.underline,
      );

  /// Error text - error color
  static TextStyle get error => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.66,
        color: SignmeColors.error,
      );

  /// Success text - success color
  static TextStyle get success => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.66,
        color: SignmeColors.success,
      );

  // ==================== MATERIAL 3 TEXT THEME ====================
  /// Complete Material 3 TextTheme for use in ThemeData
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  // ==================== UTILITY METHODS ====================
  /// Apply color to any text style
  static TextStyle applyColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  /// Apply opacity to text
  static TextStyle applyOpacity(TextStyle style, double opacity) =>
      style.copyWith(
        color: style.color?.withOpacity(opacity) ?? Colors.transparent,
      );

  /// Combine multiple text styles
  static TextStyle merge(TextStyle style1, TextStyle style2) =>
      style1.merge(style2);

  /// Get text style with custom height
  static TextStyle withLineHeight(TextStyle style, double height) =>
      style.copyWith(height: height);
}
