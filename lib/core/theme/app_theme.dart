import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// SIGNME Theme - Material 3 with modern design system
/// 
/// Uses SignmeColors, SignmeTypography, and SignmeSpacing for consistency
/// across the entire app. Built on navy blue (#001F3F) and modern blue (#2979F0)
/// with cyan accents.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: SignmeColors.colorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: SignmeColors.background,
      textTheme: SignmeTypography.textTheme,

      // ── AppBar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: SignmeColors.surface,
        foregroundColor: SignmeColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: SignmeTypography.headlineMedium,
        iconTheme: const IconThemeData(
          color: SignmeColors.onSurface,
          size: 24,
        ),
      ),

      // ── Tab Bar ──────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: SignmeColors.primary,
        unselectedLabelColor: SignmeColors.textSecondary,
        indicatorColor: SignmeColors.primary,
        labelStyle: SignmeTypography.titleMedium.copyWith(
          color: SignmeColors.primary,
        ),
        unselectedLabelStyle: SignmeTypography.titleMedium.copyWith(
          color: SignmeColors.textSecondary,
        ),
        dividerColor: SignmeColors.lightGray,
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SignmeColors.primary,
          foregroundColor: SignmeColors.onPrimary,
          elevation: 0,
          textStyle: SignmeTypography.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SignmeSpacing.buttonBorderRadius),
          ),
          minimumSize: const Size(double.infinity, SignmeSpacing.buttonHeight),
          padding: SignmeSpacing.buttonPadding,
        ),
      ),

      // ── Input Decoration ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SignmeColors.surface,
        hintStyle: SignmeTypography.placeholder,
        labelStyle: SignmeTypography.inputLabel,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignmeSpacing.inputBorderRadius),
          borderSide: const BorderSide(color: SignmeColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignmeSpacing.inputBorderRadius),
          borderSide: const BorderSide(color: SignmeColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignmeSpacing.inputBorderRadius),
          borderSide: const BorderSide(
            color: SignmeColors.primary,
            width: SignmeSpacing.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignmeSpacing.inputBorderRadius),
          borderSide: const BorderSide(color: SignmeColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SignmeSpacing.inputBorderRadius),
          borderSide: const BorderSide(
            color: SignmeColors.error,
            width: SignmeSpacing.borderMedium,
          ),
        ),
        contentPadding: SignmeSpacing.inputPadding,
        errorStyle: SignmeTypography.error,
        helperStyle: SignmeTypography.helperText,
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: SignmeColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(SignmeSpacing.cardBorderRadius),
          side: const BorderSide(
            color: SignmeColors.lightGray,
            width: 0.8,
          ),
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: SignmeColors.lightGray,
        thickness: SignmeSpacing.dividerHeight,
        space: SignmeSpacing.dividerHeight,
      ),

      // ── Bottom App Bar ───────────────────────────────────────────────────
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: SignmeColors.surface,
        elevation: 8,
        shadowColor: Colors.black12,
      ),

      // ── Popup Menu ───────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: SignmeColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        ),
        textStyle: SignmeTypography.bodyMedium,
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: SignmeColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
        ),
        titleTextStyle: SignmeTypography.displaySmall,
        contentTextStyle: SignmeTypography.bodyMedium,
        elevation: 4,
      ),

      // ── Snack Bar ────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        ),
        contentTextStyle: SignmeTypography.bodyMedium.copyWith(
          color: SignmeColors.onPrimary,
        ),
        backgroundColor: SignmeColors.primary,
      ),

      // ── Floating Action Button ────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SignmeColors.primary,
        foregroundColor: SignmeColors.onPrimary,
        elevation: 4,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: SignmeColors.lightGray,
        labelStyle: SignmeTypography.labelMedium,
        side: const BorderSide(color: Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SignmeColors.primary,
          textStyle: SignmeTypography.titleMedium,
          minimumSize: const Size(0, SignmeSpacing.buttonHeightSmall),
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SignmeColors.primary,
          side: const BorderSide(color: SignmeColors.primary),
          textStyle: SignmeTypography.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SignmeSpacing.buttonBorderRadius),
          ),
          minimumSize:
              const Size(double.infinity, SignmeSpacing.buttonHeight),
          padding: SignmeSpacing.buttonPadding,
        ),
      ),
    );
  }
}
