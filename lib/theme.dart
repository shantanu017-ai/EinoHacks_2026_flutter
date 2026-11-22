import 'package:material_ui/material_ui.dart';

import 'models/protocol.dart';

abstract final class AppColors {
  static const paper = Color(0xFFFAF7F0);
  static const ink = Color(0xFF17211C);
  static const muted = Color(0xFF5B6660);
  static const line = Color(0xFFE4DFD3);
  static const pine = Color(0xFF0F433B);
  static const pineDeep = Color(0xFF0B352F);
  static const pineSoft = Color(0xFFE7EFE9);
  static const saffron = Color(0xFFA25710);
  static const saffronSoft = Color(0xFFF6EBDA);
  static const riskRed = Color(0xFFB4232A);
  static const riskAmber = Color(0xFFA16207);
  static const riskGreen = Color(0xFF17795E);
}

extension RiskVisuals on Risk {
  Color get color => switch (this) {
        Risk.red => AppColors.riskRed,
        Risk.amber => AppColors.riskAmber,
        Risk.green => AppColors.riskGreen,
      };

  Color get soft => switch (this) {
        Risk.red => const Color(0xFFFBEDEC),
        Risk.amber => const Color(0xFFFDF5E4),
        Risk.green => const Color(0xFFEAF4F0),
      };

  String get code => name.toUpperCase();
}

const displayStyle = TextStyle(
  fontFamily: 'Fraunces',
  fontSize: 40,
  height: 1.06,
  letterSpacing: -0.6,
  color: AppColors.ink,
);

const displayItalic = TextStyle(
  fontFamily: 'Fraunces',
  fontStyle: FontStyle.italic,
  fontSize: 40,
  height: 1.06,
  letterSpacing: -0.4,
  color: AppColors.pine,
);

const sectionTitle = TextStyle(
  fontFamily: 'Fraunces',
  fontSize: 26,
  height: 1.15,
  color: AppColors.ink,
);

const eyebrow = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.4,
  color: AppColors.muted,
);

const bodyMuted = TextStyle(
  fontSize: 15,
  height: 1.55,
  color: AppColors.muted,
);

const hindiQuestion = TextStyle(
  fontFamily: 'NotoSansDevanagari',
  fontSize: 22,
  height: 1.55,
  fontWeight: FontWeight.w600,
  color: AppColors.ink,
);

const refStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 11.5,
  color: AppColors.pine,
);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    fontFamilyFallback: const ['NotoSansDevanagari'],
  );

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pine,
      primary: AppColors.pine,
      secondary: AppColors.saffron,
      surface: AppColors.paper,
      error: AppColors.riskRed,
    ),
    scaffoldBackgroundColor: AppColors.paper,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.paper,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.pineSoft,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.pine,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.pine, width: 1.4),
      ),
    ),
    dividerColor: AppColors.line,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.pineDeep,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
