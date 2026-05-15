
// Centralised design system - colours, typography, spacing

/*
Student numbers
223039784 Nido Maphosa
223035639 PM Lesekele
219007064 T Dasheka
221001040 K.Loape
224020157 KP Molelekeng

*/
import 'package:flutter/material.dart';

/// AppTheme - the unique design language of the system.
///
/// Aesthetic: "Academic Brutalist Minimalism"
/// - Deep charcoal canvas (not pure black) for reduced eye strain
/// - Single electric lime accent for hierarchy and action
/// - Sharp geometric shapes - small radii, hard edges
/// - Mono font for data/IDs, serif for headings, sans for body
class AppTheme {
  // ============= COLOUR PALETTE =============
  // Surfaces
  static const Color canvas = Color(0xFF0E0E10);       // page background
  static const Color surface = Color(0xFF17171A);      // cards
  static const Color surfaceHi = Color(0xFF1F1F23);    // elevated surfaces
  static const Color border = Color(0xFF2A2A2F);       // subtle dividers
  static const Color borderHi = Color(0xFF3A3A40);     // hover/focus borders

  // Accent
  static const Color accent = Color(0xFFD4FF00);       // electric lime
  static const Color accentDim = Color(0xFF7A9200);    // muted lime

  // Text
  static const Color textHi = Color(0xFFF5F5F0);       // primary text
  static const Color textMid = Color(0xFF9A9A95);      // secondary text
  static const Color textLow = Color(0xFF55555A);      // tertiary / hints

  // Status (used for application status pills)
  static const Color pending = Color(0xFFFFB020);
  static const Color approved = Color(0xFFD4FF00);
  static const Color rejected = Color(0xFFFF4D4D);

  // ============= SPACING SCALE =============
  static const double sp1 = 4;
  static const double sp2 = 8;
  static const double sp3 = 12;
  static const double sp4 = 16;
  static const double sp5 = 24;
  static const double sp6 = 32;
  static const double sp7 = 48;

  // ============= TYPOGRAPHY =============
  // Fonts chosen for strong visual identity:
  // - "serif" family used for display headings (gives academic gravitas)
  // - default sans for body
  // - "monospace" for IDs, codes, dates (data-feel)
  static const String fontDisplay = 'serif';
  static const String fontMono = 'monospace';

  static TextStyle get displayLg => const TextStyle(
        fontFamily: fontDisplay,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.05,
        letterSpacing: -0.5,
        color: textHi,
      );

  static TextStyle get displayMd => const TextStyle(
        fontFamily: fontDisplay,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.3,
        color: textHi,
      );

  static TextStyle get heading => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: textHi,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: textHi,
      );

  static TextStyle get bodyMuted => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: textMid,
      );

  static TextStyle get label => const TextStyle(
        fontFamily: fontMono,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.4,
        color: textMid,
      );

  static TextStyle get mono => const TextStyle(
        fontFamily: fontMono,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textHi,
      );

  // ============= MATERIAL THEME DATA =============
  static ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: canvas,
        primaryColor: accent,
        canvasColor: canvas,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: surface,
          onPrimary: canvas,
          onSurface: textHi,
        ),
        textTheme: TextTheme(
          displayLarge: displayLg,
          displayMedium: displayMd,
          headlineSmall: heading,
          bodyMedium: body,
          labelSmall: label,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: sp4, vertical: sp4),
          hintStyle: const TextStyle(color: textLow, fontSize: 14),
          labelStyle: const TextStyle(color: textMid, fontSize: 13),
          floatingLabelStyle: const TextStyle(color: accent, fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: rejected, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: rejected, width: 1.5),
          ),
          errorStyle: const TextStyle(color: rejected, fontSize: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: canvas,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(horizontal: sp5, vertical: sp4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: textHi),
          titleTextStyle: TextStyle(
            color: textHi,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
