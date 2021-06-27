import 'package:flutter/material.dart';
import 'package:sputofy_2/theme/palette.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: kAccentColor,
    accentColor: kAccentColor,
    hintColor: kThirdColor,
    dividerColor: kThirdColor,
    buttonColor: kAccentColor,
    scaffoldBackgroundColor: kPrimaryColor,
    canvasColor: Colors.black,
  );
}
