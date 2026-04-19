import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium White Theme — Hackathon Edition
class AppTheme {
  // === BRAND COLORS ===
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFEEEDFF);
  static const Color primaryDark = Color(0xFF4A42D4);
  static const Color accentColor = Color(0xFF00BFFF);
  static const Color accentSecondary = Color(0xFFFF6B6B);

  // === BACKGROUNDS ===
  static const Color backgroundColor = Color(0xFFF8F9FF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF3F4FE);
  static const Color surfaceHighlight = Color(0xFFEEEDFF);
  
  // === CHAT SPECIFIC ===
  static const Color chatBackground = Color(0xFFF8FAFC);
  static const Color chatBubbleReceived = Color(0xFFF1F5F9);

  // === STATUS ===
  static const Color errorColor = Color(0xFFFF4757);
  static const Color warningColor = Color(0xFFFFB300);
  static const Color successColor = Color(0xFF00C853);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color onlineColor = Color(0xFF00C853);

  // === TEXT ===
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5A5A7A);
  static const Color textMuted = Color(0xFF9090B0);
  static const Color textDisabled = Color(0xFFBBBBCC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // === BORDERS / DIVIDERS ===
  static const Color borderColor = Color(0xFFE8E8F0);
  static const Color borderFocus = Color(0xFF6C63FF);
  static const Color dividerColor = Color(0xFFF0F0F8);

  // Legacy aliases
  static const Color neutral10 = Color(0xFFF3F4FE);
  static const Color neutral20 = Color(0xFFEEEDFF);
  static const Color neutral30 = Color(0xFFE8E8F0);
  static const Color neutral40 = Color(0xFFD0D0E0);
  static const Color neutral50 = Color(0xFFBBBBCC);
  static const Color neutral60 = Color(0xFF9090B0);

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00BFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFEEEDFF), Color(0xFFE0F7FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00BFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === BORDER RADIUS ===
  static const double radiusXS = 6.0;
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusXL = 28.0;
  static const double radiusRound = 50.0;

  // === SPACING ===
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // === FONT SIZES ===
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 30.0;
  static const double fontSize4XL = 36.0;

  // === SYSTEM UI ===
  static void setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF8F9FF),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Both light and dark alias the same white theme
  static ThemeData get darkTheme => lightTheme;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: fontSizeXL,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: fontSize3XL,
            fontWeight: FontWeight.w900,
            color: textPrimary,
            letterSpacing: -0.8),
        displayMedium: TextStyle(
            fontSize: fontSize2XL,
            fontWeight: FontWeight.w800,
            color: textPrimary),
        displaySmall: TextStyle(
            fontSize: fontSizeXL,
            fontWeight: FontWeight.w700,
            color: textPrimary),
        headlineMedium: TextStyle(
            fontSize: fontSizeXL,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        headlineSmall: TextStyle(
            fontSize: fontSizeL,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        titleLarge: TextStyle(
            fontSize: fontSizeL,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        bodyLarge: TextStyle(
            fontSize: fontSizeL, color: textSecondary, height: 1.6),
        bodyMedium:
            TextStyle(fontSize: fontSizeM, color: textSecondary),
        bodySmall: TextStyle(fontSize: fontSizeS, color: textMuted),
        labelLarge: TextStyle(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w500,
            color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        hintStyle:
            const TextStyle(color: textMuted, fontSize: fontSizeM),
        labelStyle: const TextStyle(
            color: textSecondary, fontSize: fontSizeM),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide:
              const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingM, vertical: spacingM),
        prefixIconColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused)
                ? primaryColor
                : textMuted),
        suffixIconColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused)
                ? primaryColor
                : textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          elevation: 4,
          shadowColor: const Color(0x406C63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
              fontSize: fontSizeL,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(
              horizontal: spacingL, vertical: spacingM),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
              fontSize: fontSizeL, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(
              horizontal: spacingL, vertical: spacingM),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: borderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
          color: dividerColor, thickness: 1, space: spacingM),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceElevated,
        circularTrackColor: surfaceElevated,
      ),
    );
  }
}
