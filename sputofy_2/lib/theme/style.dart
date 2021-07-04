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
    fontFamily: 'RobotoMono',
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
    // cardTheme: CardTheme(color: kSecondaryColor),
  );
}
