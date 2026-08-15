import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens — palette drawn from the Zimbabwean flag + flame lily:
/// flame red for actions, forest green for success/secondary, marigold
/// for highlights.
class AppColors {
  static const flame = Color(0xFFDA2C38);
  static const flameDark = Color(0xFFB01F2A);
  static const forest = Color(0xFF226F54);
  static const forestSoft = Color(0xFFE3F0EA);
  static const marigold = Color(0xFFF4C95D);

  // Light theme
  static const ink = Color(0xFF16130F);
  static const inkSoft = Color(0xFF6B645C);
  static const paper = Color(0xFFFFFFFF);
  static const mist = Color(0xFFF6F4EF);
  static const line = Color(0xFFE7E2D9);

  // Dark theme
  static const inkOnDark = Color(0xFFF5F2EC);
  static const inkSoftOnDark = Color(0xFFB6AFA5);
  static const paperDark = Color(0xFF1B1915);
  static const mistDark = Color(0xFF242119);
  static const lineDark = Color(0xFF3A362C);
  static const forestSoftDark = Color(0xFF23342C);
}

class AppRadius {
  static const r = 14.0;
  static const rLg = 22.0;
}

class AppTheme {
  static TextTheme _textTheme(Color ink, Color inkSoft) {
    final display = GoogleFonts.bricolageGrotesqueTextTheme();
    final body = GoogleFonts.interTextTheme();
    return body
        .copyWith(
          displayLarge: display.displayLarge?.copyWith(fontWeight: FontWeight.w800, color: ink),
          displayMedium: display.displayMedium?.copyWith(fontWeight: FontWeight.w800, color: ink),
          displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: ink),
          headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: ink),
          headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: ink),
          headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: ink),
          titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: ink),
          titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: ink),
          titleSmall: body.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: ink),
          bodyLarge: body.bodyLarge?.copyWith(color: ink),
          bodyMedium: body.bodyMedium?.copyWith(color: inkSoft),
          bodySmall: body.bodySmall?.copyWith(color: inkSoft),
          labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: ink),
        )
        .apply(bodyColor: ink, displayColor: ink);
  }

  static ThemeData light() {
    const ink = AppColors.ink;
    const inkSoft = AppColors.inkSoft;
    final colorScheme = const ColorScheme.light(
      primary: AppColors.flame,
      onPrimary: Colors.white,
      secondary: AppColors.forest,
      onSecondary: Colors.white,
      surface: AppColors.paper,
      onSurface: ink,
      error: AppColors.flame,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      canvasColor: AppColors.paper,
      dividerColor: AppColors.line,
      textTheme: _textTheme(ink, inkSoft),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: AppColors.paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.rLg),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      extensions: const [ZimTokens.light],
    );
  }

  static ThemeData dark() {
    const ink = AppColors.inkOnDark;
    const inkSoft = AppColors.inkSoftOnDark;
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.flame,
      onPrimary: Colors.white,
      secondary: AppColors.forest,
      onSecondary: Colors.white,
      surface: AppColors.paperDark,
      onSurface: ink,
      error: AppColors.flame,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paperDark,
      canvasColor: AppColors.paperDark,
      dividerColor: AppColors.lineDark,
      textTheme: _textTheme(ink, inkSoft),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paperDark,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: AppColors.paperDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.rLg),
          side: const BorderSide(color: AppColors.lineDark),
        ),
      ),
      extensions: const [ZimTokens.dark],
    );
  }
}

/// Extra tokens that don't map cleanly onto [ColorScheme].
class ZimTokens extends ThemeExtension<ZimTokens> {
  final Color mist;
  final Color line;
  final Color ink;
  final Color inkSoft;
  final Color forestSoft;
  final Color marigold;

  const ZimTokens({
    required this.mist,
    required this.line,
    required this.ink,
    required this.inkSoft,
    required this.forestSoft,
    required this.marigold,
  });

  static const light = ZimTokens(
    mist: AppColors.mist,
    line: AppColors.line,
    ink: AppColors.ink,
    inkSoft: AppColors.inkSoft,
    forestSoft: AppColors.forestSoft,
    marigold: AppColors.marigold,
  );

  static const dark = ZimTokens(
    mist: AppColors.mistDark,
    line: AppColors.lineDark,
    ink: AppColors.inkOnDark,
    inkSoft: AppColors.inkSoftOnDark,
    forestSoft: AppColors.forestSoftDark,
    marigold: AppColors.marigold,
  );

  @override
  ZimTokens copyWith({Color? mist, Color? line, Color? ink, Color? inkSoft, Color? forestSoft, Color? marigold}) {
    return ZimTokens(
      mist: mist ?? this.mist,
      line: line ?? this.line,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      forestSoft: forestSoft ?? this.forestSoft,
      marigold: marigold ?? this.marigold,
    );
  }

  @override
  ZimTokens lerp(ThemeExtension<ZimTokens>? other, double t) {
    if (other is! ZimTokens) return this;
    return ZimTokens(
      mist: Color.lerp(mist, other.mist, t)!,
      line: Color.lerp(line, other.line, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      forestSoft: Color.lerp(forestSoft, other.forestSoft, t)!,
      marigold: Color.lerp(marigold, other.marigold, t)!,
    );
  }
}

extension ZimTokensX on BuildContext {
  ZimTokens get zim => Theme.of(this).extension<ZimTokens>()!;
}

String money(double n) => '\$${n.toStringAsFixed(2)}';
