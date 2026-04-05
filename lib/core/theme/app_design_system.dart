import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Single Source of Truth for the application's Design Tokens.
/// Avoid hardcoding hex values or raw dimensions outside of this extension.
class AppDesignSystem extends ThemeExtension<AppDesignSystem> {
  // --- Colors ---
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color accentGreen;
  final Color textMain;
  final Color textDim;
  final Color semanticError;
  final Color semanticWarning;

  // --- Dimensions & Borders ---
  final double radiusStandard;
  final double touchTargetMin;

  // --- Typography ---
  final TextStyle displayLarge;
  final TextStyle titleLarge;
  final TextStyle bodyRegular;

  const AppDesignSystem({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.accentGreen,
    required this.textMain,
    required this.textDim,
    required this.semanticError,
    required this.semanticWarning,
    required this.radiusStandard,
    required this.touchTargetMin,
    required this.displayLarge,
    required this.titleLarge,
    required this.bodyRegular,
  });

  /// Safer lookup for the [AppDesignSystem] extension.
  /// Falls back to [AppDesignSystem.dark()] if the extension is not registered
  /// on the current [ThemeData], preventing null pointer exceptions during transitions.
  static AppDesignSystem of(BuildContext context) {
    return Theme.of(context).extension<AppDesignSystem>() ?? AppDesignSystem.dark();
  }

  /// Factory establishing the default dark theme parameters adapted from [new_design_plan]
  factory AppDesignSystem.dark() {
    const textMainColor = Colors.white;
    return AppDesignSystem(
      primary: const Color(0xFF00D6B1),
      secondary: const Color(0xFF6C3AFA),
      background: const Color(0xFF0D0F14),
      surface: const Color(0xFF1A1D24),
      accentGreen: const Color(0xFF10B981),
      textMain: textMainColor,
      textDim: const Color(0x66FFFFFF),
      semanticError: const Color(0xFFEF5350),
      semanticWarning: const Color(0xFFFF9800),
      radiusStandard: 24.0,
      touchTargetMin: 44.0, // WCAG AA Compliance
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        letterSpacing: -2,
        fontStyle: FontStyle.italic,
        color: textMainColor,
      ),
      titleLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        color: textMainColor,
      ),
      bodyRegular: const TextStyle(
        fontSize: 16,
        color: textMainColor,
      ),
    );
  }

  /// Structural paradigm for Glassmorphic cards
  BoxDecoration glassDecoration({double opacity = 0.05, double blur = 10.0}) {
    return BoxDecoration(
      color: textMain.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radiusStandard),
      border: Border.all(color: textMain.withOpacity(0.1)),
    );
  }

  @override
  AppDesignSystem copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? accentGreen,
    Color? textMain,
    Color? textDim,
    Color? semanticError,
    Color? semanticWarning,
    double? radiusStandard,
    double? touchTargetMin,
    TextStyle? displayLarge,
    TextStyle? titleLarge,
    TextStyle? bodyRegular,
  }) {
    return AppDesignSystem(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      accentGreen: accentGreen ?? this.accentGreen,
      textMain: textMain ?? this.textMain,
      textDim: textDim ?? this.textDim,
      semanticError: semanticError ?? this.semanticError,
      semanticWarning: semanticWarning ?? this.semanticWarning,
      radiusStandard: radiusStandard ?? this.radiusStandard,
      touchTargetMin: touchTargetMin ?? this.touchTargetMin,
      displayLarge: displayLarge ?? this.displayLarge,
      titleLarge: titleLarge ?? this.titleLarge,
      bodyRegular: bodyRegular ?? this.bodyRegular,
    );
  }

  @override
  AppDesignSystem lerp(covariant ThemeExtension<AppDesignSystem>? other, double t) {
    if (other is! AppDesignSystem) return this;
    return AppDesignSystem(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      semanticError: Color.lerp(semanticError, other.semanticError, t)!,
      semanticWarning: Color.lerp(semanticWarning, other.semanticWarning, t)!,
      radiusStandard: ui.lerpDouble(radiusStandard, other.radiusStandard, t) ?? radiusStandard,
      touchTargetMin: ui.lerpDouble(touchTargetMin, other.touchTargetMin, t) ?? touchTargetMin,
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      bodyRegular: TextStyle.lerp(bodyRegular, other.bodyRegular, t)!,
    );
  }
}

