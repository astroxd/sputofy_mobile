import 'package:flutter/material.dart';
import 'package:sputofy_2/theme/palette.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: kAccentColor,
    accentColor: kAccentColor,
    hintColor: kThirdColor,
    dividerColor: kSecondaryColor,
    buttonColor: kAccentColor,
    scaffoldBackgroundColor: kPrimaryColor,
    canvasColor: Colors.black,
    iconTheme: IconThemeData(color: kThirdColor, size: 28.0),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: kAccentColor),
      bodyText2: TextStyle(color: kSecondaryColor),
      subtitle1: TextStyle(color: kThirdColor, fontSize: 16.0),
    ),
    unselectedWidgetColor: kAccentColor,
    disabledColor: kAccentColor,
  );
}
