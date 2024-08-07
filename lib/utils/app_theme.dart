import 'package:flutter/material.dart';
import 'package:untitled/utils/colors/app_colors_ext.dart';

class AppTheme {
  //
  // Light theme
  //

  static final light = ThemeData.light().copyWith(
    extensions: [
      lightAppColors,
    ],
  );

  static final lightAppColors = AppColorsExtension(
    primary: const Color(0xff6200ee),
    background: Colors.white,

  );

  //
  // Dark theme
  //

  static final dark = ThemeData.dark().copyWith(
    extensions: [
      _darkAppColors,
    ],
  );

  static final _darkAppColors = AppColorsExtension(
    primary: const Color(0xffbb86fc),
    background: const Color(0xff121212),
  );
}
