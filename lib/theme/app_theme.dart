import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Тёплая "редакционная" палитра — тёмный пергамент + янтарный акцент,
/// напоминает старые газетные вырезки "в этот день в истории".
class AppTheme {
  static const _ink = Color(0xFF17140F);
  static const _paper = Color(0xFFFBF6EC);
  static const _amber = Color(0xFFE0A548);
  static const _amberDeep = Color(0xFFC97F2A);
  static const _muted = Color(0xFF8A8378);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.sourceSerif4TextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.sourceSerif4(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: _paper,
        height: 1.15,
      ),
      headlineMedium: GoogleFonts.sourceSerif4(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _paper,
      ),
      bodyLarge: GoogleFonts.sourceSerif4(
        fontSize: 19,
        height: 1.5,
        color: _paper.withOpacity(0.92),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: _muted,
        letterSpacing: 0.2,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: _amber,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: _ink,
      colorScheme: base.colorScheme.copyWith(
        primary: _amber,
        secondary: _amberDeep,
        surface: const Color(0xFF211C14),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _ink,
        elevation: 0,
        titleTextStyle: textTheme.headlineMedium,
      ),
      iconTheme: const IconThemeData(color: _amber),
      dividerColor: _muted.withOpacity(0.25),
    );
  }

  static const ink = _ink;
  static const paper = _paper;
  static const amber = _amber;
  static const amberDeep = _amberDeep;
  static const muted = _muted;
}
