import 'package:flutter/material.dart';
import 'package:verd/core/theme/app_design_system.dart';

/// Centralized design tokens for VERD Agricultural App
class AppColors {
  // Primary green palette
  static const primary50 = Color(0xFFE8F5E9);
  static const primary100 = Color(0xFFC8E6C9);
  static const primary200 = Color(0xFFA5D6A7);
  static const primary300 = Color(0xFF81C784);
  static const primary400 = Color(0xFF66BB6A);
  static const primary500 = Color(0xFF4CAF50);
  static const primary600 = Color(0xFF43A047);
  static const primary700 = Color(0xFF388E3C);
  static const primary800 = Color(0xFF2E7D32);
  static const primary900 = Color(0xFF1B5E20);
  static const primary = primary500;

  // Gray scale
  static const gray50 = Color(0xFFFAFAFA);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray600 = Color(0xFF757575);
  static const gray700 = Color(0xFF616161);
  static const gray800 = Color(0xFF424242);
  static const gray900 = Color(0xFF212121);
  static const gray950 = Color(0xFF121212);

  // Semantic colors
  static const successLight = Color(0xFF81C784);
  static const success = Color(0xFF4CAF50);
  static const successDark = Color(0xFF2E7D32);

  static const errorLight = Color(0xFFEF5350);
  static const error = Color(0xFFf44336);
  static const errorDark = Color(0xFFC62828);

  static const warningLight = Color(0xFFFFB74D);
  static const warning = Color(0xFFFF9800);
  static const warningDark = Color(0xFFF57C00);

  static const infoLight = Color(0xFF64B5F6);
  static const info = Color(0xFF2196F3);
  static const infoDark = Color(0xFF1565C0);

  // Backgrounds
  static const backgroundPrimary = Color(0xFFF5F5F5);
  static const backgroundSecondary = Color(0xFFFFFFFF);
  static const backgroundTertiary = Color(0xFFE0E0E0);

  // Text colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF616161);
  static const textDisabled = Color(0xFF9E9E9E);
  static const textWhite = Color(0xFFFFFFFF);
}

class AppTypography {
  // Font families
  static const String primaryFont = 'Inter';
  static const String secondaryFont = 'SF Pro';

  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Font sizes (in logical pixels)
  static const double xs = 11;
  static const double sm = 12;
  static const double base = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;
  static const double xxxxl = 32;
  static const double xxxxxl = 36;

  // Line heights (as multiples of font size)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  static const double lineHeightLoose = 2.0;

  // Predefined text styles
  static const h1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: xxxxl,
    fontWeight: bold,
    height: lineHeightTight,
  );

  static const h2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: xxl,
    fontWeight: bold,
    height: 1.3,
  );

  static const h3 = TextStyle(
    fontFamily: primaryFont,
    fontSize: xl,
    fontWeight: semibold,
    height: 1.4,
  );

  static const h4 = TextStyle(
    fontFamily: primaryFont,
    fontSize: lg,
    fontWeight: semibold,
    height: 1.4,
  );

  static const bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: md,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  static const body = TextStyle(
    fontFamily: primaryFont,
    fontSize: base,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  static const bodySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: sm,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  static const caption = TextStyle(
    fontFamily: primaryFont,
    fontSize: xs,
    fontWeight: regular,
    height: 1.4,
  );

  static const button = TextStyle(
    fontFamily: primaryFont,
    fontSize: md,
    fontWeight: semibold,
    height: 1.0,
  );

  static const buttonSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: base,
    fontWeight: semibold,
    height: 1.0,
  );
}

class AppSpacing {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;
  static const double xxxxl = 32;
  static const double xxxxxl = 36;
  static const double huge = 40;
  static const double huge2 = 48;
  static const double huge3 = 56;
  static const double huge4 = 64;
  static const double huge5 = 80;
  static const double huge6 = 96;

  // Common use shortcuts
  static const double screenPadding = xxl; // 24
  static const double cardPadding = lg; // 16
  static const double elementGap = md; // 12
}

class AppRadius {
  static const double none = 0;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 16;
  static const double xxxl = 24;
  static const double full = 9999;

  // Component specific
  static const double button = xl; // 12
  static const double card = xl; // 12
  static const double input = lg; // 10
}

class AppShadows {
  static BoxShadow sm = const BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 2,
    color: Color(0x0D000000),
  );

  static BoxShadow md = const BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -1,
    color: Color(0x1A000000),
  );

  static BoxShadow lg = const BoxShadow(
    offset: Offset(0, 10),
    blurRadius: 15,
    spreadRadius: -3,
    color: Color(0x1A000000),
  );

  static BoxShadow xl = const BoxShadow(
    offset: Offset(0, 20),
    blurRadius: 25,
    spreadRadius: -5,
    color: Color(0x1A000000),
  );

  static BoxShadow xxl = const BoxShadow(
    offset: Offset(0, 25),
    blurRadius: 50,
    spreadRadius: -12,
    color: Color(0x40000000),
  );

  static BoxShadow inner = const BoxShadow(
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
    color: Color(0x0F000000),
    blurStyle: BlurStyle.inner,
  );

  static BoxShadow card = sm;
  static BoxShadow cardHover = md;
}

class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
  );

  static const success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
  );

  static const error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFf44336), Color(0xFFd32f2f)],
  );

  static const warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
  );

  static const info = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
  );

  static const neutral = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textWhite,
      primaryContainer: AppColors.primary100,
      onPrimaryContainer: AppColors.primary900,
      secondary: AppColors.gray600,
      onSecondary: AppColors.textWhite,
      secondaryContainer: AppColors.gray200,
      onSecondaryContainer: AppColors.gray900,
      error: AppColors.error,
      onError: AppColors.textWhite,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.errorDark,
      // ✅ Replaced deprecated 'background' → 'surface'
      surface: AppColors.backgroundSecondary,
      onSurface: AppColors.textPrimary,
      // ✅ Replaced deprecated 'surfaceVariant' → 'surfaceContainerHighest'
      surfaceContainerHighest: AppColors.backgroundTertiary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.gray400,
      outlineVariant: AppColors.gray300,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.gray800,
      onInverseSurface: AppColors.textWhite,
      inversePrimary: AppColors.primary200,
    ),
    fontFamily: AppTypography.primaryFont,
    textTheme: const TextTheme(
      displayLarge: AppTypography.h1,
      displayMedium: AppTypography.h2,
      displaySmall: AppTypography.h3,
      headlineMedium: AppTypography.h4,
      titleLarge: AppTypography.h3,
      titleMedium: AppTypography.bodyLarge,
      titleSmall: AppTypography.body,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.buttonSmall,
      labelSmall: AppTypography.caption,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.gray300, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.gray300, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.errorDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      hintStyle: const TextStyle(color: AppColors.gray500),
    ),
    // ✅ Fixed: CardTheme → CardThemeData
    cardTheme: CardThemeData(
      color: AppColors.backgroundSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        disabledBackgroundColor: AppColors.gray400,
        disabledForegroundColor: AppColors.gray500,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTypography.button,
        elevation: 0,
        // ✅ Replaced deprecated withOpacity → withValues
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ).copyWith(
        // ✅ Replaced deprecated MaterialStateProperty → WidgetStateProperty
        // ✅ Replaced deprecated MaterialState → WidgetState
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          return 8;
        }),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.backgroundSecondary,
        disabledForegroundColor: AppColors.gray500,
        side: const BorderSide(color: AppColors.gray300, width: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.buttonSmall,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: AppTypography.h4,
      toolbarHeight: 60,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundTertiary,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textPrimary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.gray300,
      thickness: 1,
      space: AppSpacing.lg,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.gray100,
      disabledColor: AppColors.gray200,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.primary100,
      labelStyle: AppTypography.bodySmall,
      secondaryLabelStyle: AppTypography.bodySmall,
      brightness: Brightness.light,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.gray900,
      contentTextStyle: AppTypography.body.copyWith(color: AppColors.textWhite),
      actionTextColor: AppColors.primary200,
    ),
    extensions: [AppDesignSystem.dark()],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary300,           // Light green accent
      onPrimary: const Color(0xFF0A1A0F),      // Deep forest on primary
      primaryContainer: AppColors.primary900,
      onPrimaryContainer: AppColors.primary100,
      secondary: AppColors.primary200,
      onSecondary: const Color(0xFF0A1A0F),
      secondaryContainer: const Color(0xFF1C3D24),
      onSecondaryContainer: AppColors.primary100,
      error: AppColors.errorLight,
      onError: const Color(0xFF0A1A0F),
      errorContainer: AppColors.errorDark,
      onErrorContainer: AppColors.errorLight,
      surface: DarkColors.surface,
      onSurface: DarkColors.textPrimary,
      surfaceContainerHighest: DarkColors.surfaceContainer,
      surfaceContainerHigh: DarkColors.surfaceContainerHigh,
      onSurfaceVariant: DarkColors.textSecondary,
      outline: const Color(0xFF2E5938),         // Muted green outline
      outlineVariant: const Color(0xFF1C3D24),  // Subtle green border
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.primary100,
      onInverseSurface: const Color(0xFF0A1A0F),
      inversePrimary: AppColors.primary700,
    ),
    fontFamily: AppTypography.primaryFont,
    textTheme: TextTheme(
      displayLarge: AppTypography.h1.copyWith(color: DarkColors.textPrimary),
      displayMedium: AppTypography.h2.copyWith(color: DarkColors.textPrimary),
      displaySmall: AppTypography.h3.copyWith(color: DarkColors.textPrimary),
      headlineMedium: AppTypography.h4.copyWith(color: DarkColors.textPrimary),
      titleLarge: AppTypography.h3.copyWith(color: DarkColors.textPrimary),
      titleMedium: AppTypography.bodyLarge.copyWith(color: DarkColors.textPrimary),
      titleSmall: AppTypography.body.copyWith(color: DarkColors.textPrimary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: DarkColors.textPrimary),
      bodyMedium: AppTypography.body.copyWith(color: DarkColors.textPrimary),
      bodySmall: AppTypography.bodySmall.copyWith(color: DarkColors.textSecondary),
      labelLarge: AppTypography.button.copyWith(color: DarkColors.textPrimary),
      labelMedium: AppTypography.buttonSmall.copyWith(color: DarkColors.textPrimary),
      labelSmall: AppTypography.caption.copyWith(color: DarkColors.textSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: Color(0xFF2E5938), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: Color(0xFF2E5938), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.primary300, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      hintStyle: TextStyle(color: DarkColors.textSecondary.withValues(alpha: 0.6)),
    ),
    cardTheme: CardThemeData(
      color: DarkColors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF1C3D24),
        disabledForegroundColor: DarkColors.textSecondary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTypography.button,
        elevation: 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          return 8;
        }),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DarkColors.textPrimary,
        backgroundColor: DarkColors.surfaceContainer,
        disabledForegroundColor: DarkColors.textSecondary,
        side: const BorderSide(color: Color(0xFF2E5938), width: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary300,       // Light green accent
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.buttonSmall,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: DarkColors.background,
      foregroundColor: DarkColors.textPrimary,
      elevation: 0,
      titleTextStyle: AppTypography.h4.copyWith(color: DarkColors.textPrimary),
      toolbarHeight: 60,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: DarkColors.surfaceContainer,
      selectedItemColor: AppColors.primary300,
      unselectedItemColor: DarkColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1C3D24),
      thickness: 1,
      space: AppSpacing.lg,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1C3D24),
      disabledColor: const Color(0xFF0F2416),
      selectedColor: AppColors.primary700,
      secondarySelectedColor: AppColors.primary900,
      labelStyle: AppTypography.bodySmall.copyWith(color: DarkColors.textPrimary),
      secondaryLabelStyle: AppTypography.bodySmall.copyWith(color: DarkColors.textPrimary),
      brightness: Brightness.dark,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1C3D24),
      contentTextStyle: AppTypography.body.copyWith(color: DarkColors.textPrimary),
      actionTextColor: AppColors.primary300,
    ),
    extensions: [AppDesignSystem.dark()],
  );
}

/// Dark mode color tokens — earthy green agricultural theme.
class DarkColors {
  static const background       = Color(0xFF0A1A0F);  // Deepest forest
  static const surface          = Color(0xFF0F2416);  // Dark forest green
  static const surfaceContainer = Color(0xFF16321D);  // Card / elevated surface
  static const surfaceContainerHigh = Color(0xFF1C3D24); // Higher elevation
  static const textPrimary      = Color(0xFFF1F8E9);  // Warm white-green
  static const textSecondary    = Color(0xFFA5D6A7);  // Muted light green
}