import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sputofy_2/model/audioPlayer.dart';
import 'package:sputofy_2/playlistList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyAudio>(
      create: (_) => MyAudio(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
        appBar: CustomAppBar(index, pageController),
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
            PlaylistList(),
          ],
        ));
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int index;
  final PageController pageController;

  @override
  final Size preferredSize;

  CustomAppBar(this.index, this.pageController)
      : preferredSize = Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: GestureDetector(
                onTap: () {
                  pageController.animateToPage(0,
                      duration: Duration(microseconds: 250),
                      curve: Curves.bounceInOut);
                },
                child: Icon(
                  Icons.list,
                  size: 64.0,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(right: 48.0),
              child: GestureDetector(
                onTap: () {
                  pageController.animateToPage(1,
                      duration: Duration(microseconds: 250),
                      curve: Curves.bounceInOut);
                },
                child: Icon(
                  Icons.list,
                  size: 64.0,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
