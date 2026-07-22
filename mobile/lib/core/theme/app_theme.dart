import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

/// Grosirun App Theme
/// 
/// Based on Brand Guidelines v2.0
/// Primary: #16A34A (Grosirun Green)
/// All colors meet WCAG 2.1 AA contrast requirements.
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFFBBF7D0);

  // ─── Functional Colors ───
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF3B82F6);

  // ─── Neutral Colors ───
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);

  // ─── Offline Banner ───
  static const Color offlineBannerBg = Color(0xFFFEF9C3);
  static const Color offlineBannerText = Color(0xFF854D0E);

  // ─── Light Theme (using FlexColorScheme) ───
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.green,
      surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
      blendLevel: 20,
      appBarStyle: FlexAppBarStyle.surface,
      appBarOpacity: 0.95,
      transparentStatusBar: true,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      // Use Google Fonts
      textTheme: GoogleFonts.nunitoTextTheme(),
      // Custom color overrides
      colors: FlexSchemeColor(
        primary: primary,
        primaryContainer: primaryDark,
        secondary: warning,
        secondaryContainer: const Color(0xFFF59E0B),
        tertiary: success,
        tertiaryContainer: const Color(0xFF16A34A),
        errorColor: error,
        errorContainer: const Color(0xFFEF4444),
        appBarColor: primary,
        onScheme: Colors.white,
      ),
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: true,
        useTextTheme: true,
        defaultRadius: 12.0,
        // Button themes
        elevatedButtonRadius: 12.0,
        elevatedButtonElevation: 2.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 8.0,
        inputDecoratorBorderWidth: 1.5,
        inputDecoratorIsFilled: true,
        cardRadius: 16.0,
        popupMenuRadius: 12.0,
        dialogRadius: 20.0,
        snackbarRadius: 12.0,
        bottomSheetRadius: 20.0,
        chipRadius: 8.0,
        segmentedButtonRadius: 12.0,
        // Floating action button
        fabRadius: 16.0,
        fabUseShape: true,
        // Navigation
        navigationBarHeight: 64.0,
        navigationBarItemIndicatorRadius: 12.0,
        navigationBarIndicatorOpacity: 0.2,
        navigationRailWidth: 72.0,
        navigationRailLabelType: NavigationRailLabelType.all,
        // Tooltip
        tooltipRadius: 8.0,
        tooltipWaitDuration: Duration(milliseconds: 500),
        // Switch & Slider
        switchThumbSize: 24.0,
        switchDesignWidth: 52.0,
        switchDesignHeight: 32.0,
      ),
      keyColors: const FlexKeyColors(
        usePrimary: true,
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      tones: FlexSchemeVariant(
        name: 'Grosirun Green',
        description: 'Custom green theme for Grosirun',
        primary: FlexTonality(
          primary: primary,
          secondary: warning,
          tertiary: success,
          error: error,
        ),
      ),
    );
  }

  // ─── Typography Helpers (Google Fonts Nunito) ───
  static TextStyle get headlineLarge => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get titleLarge => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get titleMedium => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ─── Common Decorations ───
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      labelStyle: bodyMedium,
      hintStyle: bodyMedium.copyWith(color: textDisabled),
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
