import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/appBar.dart';

import 'package:sputofy_2/model/audioPlayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyAudio>(
      create: (_) => MyAudio(),
      child: MaterialApp(
        title: 'Sputofy',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    return Scaffold(
        appBar: CustomAppBar(index),
        body: PageView(
          controller: pageController,
          onPageChanged: (value) {
            setState(() {
              index = value;
            });
          },
          children: [
            Container(
              color: Colors.amber,
            ),
            Container(color: Colors.brown),
          ],
        ));
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int index;

  @override
  final Size preferredSize;

  CustomAppBar(this.index) : preferredSize = Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: index == 0 ? Colors.red : Colors.blue,
      ),
    );
  }
}
