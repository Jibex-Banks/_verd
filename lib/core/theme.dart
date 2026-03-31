import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerdTheme {
  // Brand Colors
  static const Color primary = Color(0xFF00D6B1); // Bitget Turquoise
  static const Color background = Color(0xFF0D0F14); // Deep Black/Navy
  static const Color surface = Color(0xFF1A1D24);
  
  static const Color secondary = Color(0xFF6C3AFA); // Neural Purple
  static const Color accentGreen = Color(0xFF10B981); // GreenFamily Emerald
  
  static const Color textMain = Colors.white;
  static const Color textDim = Color(0x66FFFFFF); // White 40%
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          letterSpacing: -2,
          fontStyle: FontStyle.italic,
          color: textMain,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: textMain,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
    );
  }

  static BoxDecoration glassDecoration({double opacity = 0.05, double blur = 10.0}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    );
  }
}
