import 'package:flutter/material.dart';
import 'package:sputofy_2/theme/palette.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: kAccentColor,
    accentColor: kAccentColor,
    hintColor: kThirdColor,
    dividerColor: kPrimaryColor,
    buttonColor: kAccentColor,
    scaffoldBackgroundColor: kBackgroundColor,
    canvasColor: Colors.black,
    fontFamily: 'Poppins',
    iconTheme: IconThemeData(color: kPrimaryColor, size: 28.0),
    textTheme: TextTheme(
      subtitle1: TextStyle(color: kThirdColor, fontSize: 16.0),
      subtitle2: TextStyle(color: kPrimaryColor),
      headline6: TextStyle(color: kThirdColor),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: kBackgroundColor,
      textStyle: TextStyle(color: kThirdColor, fontSize: 16.0),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: kSecondaryBackgroundColor,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) => kAccentColor),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: kSecondaryBackgroundColor,
      elevation: 0.0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF323232),
      contentTextStyle: TextStyle(color: kThirdColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: kThirdColor),
      fillColor: kAccentColor,
    ),
    //! Made in a hurry
    colorScheme: ColorScheme(
      primary: kAccentColor,
      primaryVariant: kSecondAccentColor,
      secondary: kAccentColor,
      secondaryVariant: kSecondAccentColor,
      surface: kSecondaryBackgroundColor,
      background: kBackgroundColor,
      error: Colors.red,
      onPrimary: kThirdColor,
      onSecondary: kThirdColor,
      onSurface: kThirdColor,
      onBackground: kThirdColor,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),
  );
}
