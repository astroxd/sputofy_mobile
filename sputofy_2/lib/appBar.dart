import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget {
  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    return Drawer(
      child: Container(
        width: 10.0,
        height: 15.0,
        color: Colors.black,
      ),
    );
  }
}
