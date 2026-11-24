import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NadaColors {
  NadaColors._();

  // Brand & Surface Tokens
  static const Color primary = Color(0xFF2D5A43); // Deep Forest Sage
  static const Color primaryPressed = Color(0xFF3B7257);
  static const Color primaryDeep = Color(0xFF14422D);
  static const Color primarySoft = Color.fromRGBO(45, 90, 67, 0.12);

  static const Color canvas = Color(0xFFF4EFE6); // Warm Cream / Ivory
  static const Color surfaceTranslucent = Color(0xFFF9F6F0);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceOutline = Color(0xFFE6DFD5);

  static const Color tertiaryGold = Color(0xFFD4A373); // Warm Gold / Teak Brass
  static const Color woodBrown = Color(0xFF8C5E3C);

  static const Color textPrimary = Color(0xFF0D1C2F);
  static const Color textBody = Color(0xFF334155); // Slate Charcoal
  static const Color textMuted = Color(0xFF64748B);
  static const Color error = Color(0xFFBA1A1A);
}

class NadaSpacing {
  NadaSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0; // Card gutter
  static const double pageMargin = 20.0; // Mobile canvas margin
  static const double lg = 24.0;
  static const double sectionBreak = 36.0;
}

class NadaRadius {
  NadaRadius._();

  static const double md = 16.0;
  static const double card = 20.0;
  static const double sheetTop = 28.0;
  static const double pill = 999.0;
}

class NadaShadows {
  NadaShadows._();

  static const List<BoxShadow> warmAmbient = [
    BoxShadow(
      color: Color.fromRGBO(45, 90, 67, 0.08),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color.fromRGBO(140, 94, 60, 0.04),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}

class NadaTheme {
  NadaTheme._();

  static ThemeData light() {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NadaColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: NadaColors.primary,
        onPrimary: Colors.white,
        primaryContainer: NadaColors.primaryDeep,
        secondary: NadaColors.woodBrown,
        tertiary: NadaColors.tertiaryGold,
        surface: NadaColors.surfaceCard,
        onSurface: NadaColors.textPrimary,
        outline: NadaColors.surfaceOutline,
        error: NadaColors.error,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 44 / 36,
          letterSpacing: -0.72,
          color: NadaColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 32 / 24,
          letterSpacing: -0.24,
          color: NadaColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
          color: NadaColors.textPrimary,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 24 / 16,
          color: NadaColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 26 / 16,
          color: NadaColors.textBody,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 22 / 14,
          color: NadaColors.textBody,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          letterSpacing: 0.48,
          color: NadaColors.textBody,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 14 / 10,
          letterSpacing: 0.6,
          color: NadaColors.woodBrown,
        ),
      ),
    );
  }
}