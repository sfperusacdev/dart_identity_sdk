import 'package:example/configs/app_colors.dart';
import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primaryColor: const Color(0xFF0B284E),
  primarySwatch: AppColors.materialPrimaryWatch,
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B284E)),
  useMaterial3: false,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF0B284E),
    secondary: const Color(0xFF6EA514),
    surface: Colors.white,
    onPrimary: Colors.white,
  ),
);
