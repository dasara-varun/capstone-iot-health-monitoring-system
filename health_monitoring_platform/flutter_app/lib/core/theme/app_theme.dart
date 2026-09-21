import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Editorial serif design tokens for the health monitoring client.
///
/// Tokens are centralized here so screens compose from one palette instead of
/// one-off hex values. Status colors stay desaturated so they read as labels,
/// not as a second brand palette.
class AppTheme {
  static const Color background = Color(0xFFFAFAF8);
  static const Color foreground = Color(0xFF1A1A1A);
  static const Color muted = Color(0xFFF5F3F0);
  static const Color mutedForeground = Color(0xFF6B6B6B);
  static const Color accent = Color(0xFFB8860B);
  static const Color accentSecondary = Color(0xFFD4A84B);
  static const Color accentForeground = Color(0xFFFFFFFF);
  static const Color accentMuted = Color(0x0FB8860B);
  static const Color border = Color(0xFFE8E4DF);
  static const Color borderHover = Color(0xFFD4CFC8);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ring = Color(0xFFB8860B);

  static const Color healthy = Color(0xFF4F6F52);
  static const Color healthySoft = Color(0xFFE8EFE6);
  static const Color observe = Color(0xFFA16207);
  static const Color observeSoft = Color(0xFFF6EBD3);
  static const Color review = Color(0xFF8B3A3A);
  static const Color reviewSoft = Color(0xFFF3E4E2);

  /// Backward-compatible aliases used by remaining call sites.
  static const Color navyDark = foreground;
  static const Color navyMedium = Color(0xFF2C2C2C);
  static const Color tealHealthy = healthy;
  static const Color tealLight = healthySoft;
  static const Color amberWarning = observe;
  static const Color amberLight = observeSoft;
  static const Color roseAlert = review;
  static const Color roseLight = reviewSoft;
  static const Color borderLight = border;
  static const Color slateBg = background;
  static const Color slateCard = card;

  static TextStyle get display {
    return GoogleFonts.playfairDisplay(
      color: foreground,
      fontWeight: FontWeight.w400,
      height: 1.15,
      letterSpacing: -0.02 * 16,
    );
  }

  static TextStyle get body {
    return GoogleFonts.sourceSans3(
      color: foreground,
      fontWeight: FontWeight.w400,
      height: 1.75,
      letterSpacing: 0.01 * 16,
      fontSize: 16,
    );
  }

  static TextStyle get smallCaps {
    return GoogleFonts.ibmPlexMono(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15 * 12,
      color: accent,
    );
  }

  static List<BoxShadow> get shadowSm => const [
        BoxShadow(color: Color(0x0A1A1A1A), blurRadius: 2, offset: Offset(0, 1)),
      ];

  static List<BoxShadow> get shadowMd => const [
        BoxShadow(color: Color(0x0F1A1A1A), blurRadius: 12, offset: Offset(0, 4)),
      ];

  static ThemeData get lightTheme {
    final sourceSans = GoogleFonts.sourceSans3TextTheme();
    final playfair = GoogleFonts.playfairDisplayTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      canvasColor: background,
      dividerColor: border,
      colorScheme: const ColorScheme.light(
        primary: accent,
        onPrimary: accentForeground,
        secondary: accentSecondary,
        onSecondary: foreground,
        surface: card,
        onSurface: foreground,
        error: review,
        onError: accentForeground,
        outline: border,
      ),
      textTheme: sourceSans.copyWith(
        displayLarge: playfair.displayLarge?.copyWith(
          color: foreground,
          fontSize: 48,
          height: 1.1,
          letterSpacing: -0.8,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: playfair.headlineLarge?.copyWith(
          color: foreground,
          fontSize: 32,
          height: 1.2,
          letterSpacing: -0.3,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: playfair.headlineMedium?.copyWith(
          color: foreground,
          fontSize: 24,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: playfair.titleLarge?.copyWith(
          color: foreground,
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: sourceSans.bodyLarge?.copyWith(
          color: foreground,
          fontSize: 16,
          height: 1.75,
          letterSpacing: 0.16,
        ),
        bodyMedium: sourceSans.bodyMedium?.copyWith(
          color: mutedForeground,
          fontSize: 15,
          height: 1.7,
        ),
        labelSmall: GoogleFonts.ibmPlexMono(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.8,
          color: accent,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: foreground,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border, width: 1),
        ),
        shadowColor: const Color(0x0A1A1A1A),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: GoogleFonts.sourceSans3(color: mutedForeground, fontSize: 14),
        hintStyle: GoogleFonts.sourceSans3(color: mutedForeground.withValues(alpha: 0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentForeground,
          minimumSize: const Size(44, 44),
          elevation: 0,
          shadowColor: const Color(0x1AB8860B),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: GoogleFonts.sourceSans3(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            fontSize: 14,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(accentSecondary.withValues(alpha: 0.15)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size(44, 44),
          side: const BorderSide(color: foreground),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mutedForeground,
          minimumSize: const Size(44, 44),
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: card,
        indicatorColor: muted,
        selectedIconTheme: const IconThemeData(color: accent, size: 22),
        unselectedIconTheme: const IconThemeData(color: mutedForeground, size: 22),
        selectedLabelTextStyle: GoogleFonts.sourceSans3(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.6,
        ),
        unselectedLabelTextStyle: GoogleFonts.sourceSans3(
          color: mutedForeground,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: accent,
        unselectedItemColor: mutedForeground,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.sourceSans3(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4),
        unselectedLabelStyle: GoogleFonts.sourceSans3(fontSize: 11, letterSpacing: 0.3),
        elevation: 0,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(muted),
        dividerThickness: 1,
        headingTextStyle: GoogleFonts.ibmPlexMono(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: mutedForeground,
        ),
        dataTextStyle: GoogleFonts.sourceSans3(fontSize: 13, color: foreground),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: foreground,
        contentTextStyle: GoogleFonts.sourceSans3(color: accentForeground),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
      ),
    );
  }
}
