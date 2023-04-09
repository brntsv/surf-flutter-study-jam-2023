import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary = Color(0xFF6441A5);
  static const addButton = Color(0xFFece0fc);
  static const lightPurple = Color(0xFFD1D1CC);

  static const scaffoldBackgroundColor = Color(0xFFEFF0E8);
  static const backgroundColor = Color(0xFFE5E7D8);
}

abstract class AppTextStyle {
  static const titleAppBar = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    color: Colors.black,
    height: 1.25,
    letterSpacing: 1,
  );
  static const floatingButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    color: AppColors.primary,
    height: 1.25,
    letterSpacing: 1,
  );
}

final themeData = ThemeData(
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
    colorScheme: ThemeData().colorScheme.copyWith(
        primary: AppColors.primary, background: AppColors.backgroundColor),
    appBarTheme: const AppBarTheme(
        elevation: 0,
        color: AppColors.lightPurple,
        titleTextStyle: AppTextStyle.titleAppBar),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.addButton,
      extendedTextStyle: AppTextStyle.floatingButton,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            const MaterialStatePropertyAll<Color>(AppColors.primary),
        minimumSize: MaterialStateProperty.all(const Size(150, 50)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
      iconColor: MaterialStateProperty.all(AppColors.primary),
    )));
