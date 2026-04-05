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
  final Color accentRed; // Added for the new UI

  // --- Dimensions & Borders ---
  final double radiusStandard;
  final double touchTargetMin;

  // --- Typography ---
  final TextStyle displayLarge;
  final TextStyle displayMedium; // Added for the new UI
  final TextStyle titleLarge;
  final TextStyle bodyRegular;
  final TextStyle bodySmall; // Added for the new UI

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
    required this.accentRed,
    required this.radiusStandard,
    required this.touchTargetMin,
    required this.displayLarge,
    required this.displayMedium,
    required this.titleLarge,
    required this.bodyRegular,
    required this.bodySmall,
  });

  /// Safer lookup for the [AppDesignSystem] extension.
  static AppDesignSystem of(BuildContext context) {
    return Theme.of(context).extension<AppDesignSystem>() ?? AppDesignSystem.dark();
  }

  /// Factory establishing the default dark theme parameters.
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
      accentRed: const Color(0xFFEF5350), // Map to semantic error
      radiusStandard: 24.0,
      touchTargetMin: 44.0,
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        letterSpacing: -2,
        fontStyle: FontStyle.italic,
        color: textMainColor,
      ),
      displayMedium: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
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
      bodySmall: const TextStyle(
        fontSize: 12,
        color: textMainColor,
      ),
    );
  }

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
    Color? accentRed,
    double? radiusStandard,
    double? touchTargetMin,
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? titleLarge,
    TextStyle? bodyRegular,
    TextStyle? bodySmall,
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
      accentRed: accentRed ?? this.accentRed,
      radiusStandard: radiusStandard ?? this.radiusStandard,
      touchTargetMin: touchTargetMin ?? this.touchTargetMin,
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      titleLarge: titleLarge ?? this.titleLarge,
      bodyRegular: bodyRegular ?? this.bodyRegular,
      bodySmall: bodySmall ?? this.bodySmall,
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
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      radiusStandard: ui.lerpDouble(radiusStandard, other.radiusStandard, t) ?? radiusStandard,
      touchTargetMin: ui.lerpDouble(touchTargetMin, other.touchTargetMin, t) ?? touchTargetMin,
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      bodyRegular: TextStyle.lerp(bodyRegular, other.bodyRegular, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
    );
  }
}
