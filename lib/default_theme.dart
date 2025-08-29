import 'package:flutter/material.dart';

class AppColors {
  static MaterialColor get materialPrimaryWatch => const MaterialColor(
        0xff0B284E,
        {
          50: Color(0xff13265c),
          100: Color(0xff112253),
          200: Color(0xff0f1e4a),
          300: Color(0xff0B284E),
          400: Color(0xff0b1737),
          500: Color(0xff0a132e),
          600: Color(0xff080f25),
          700: Color(0xff060b1c),
        },
      );
}

final defaultAppTheme = ThemeData(
  primaryColor: const Color(0xFF0B284E),
  primarySwatch: AppColors.materialPrimaryWatch,
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B284E)),
  useMaterial3: false,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF0B284E),
    secondary: const Color(0xFF6EA514),
    surface: Colors.white,
  ),
);
