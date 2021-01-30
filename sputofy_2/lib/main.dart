import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sputofy_2/model/audioPlayer.dart';
import 'package:sputofy_2/model/databaseValues.dart';
import 'package:sputofy_2/palette.dart';
import 'package:sputofy_2/playlistList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAudio()),
        ChangeNotifierProvider(create: (_) => DatabaseValue()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sputofy',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
        // home: test(),
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
      body: Column(
        children: <Widget>[
          PageButtons(widthScreen, index, pageController),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (value) {
                setState(() {
                  index = value;
                });
              },
              children: [
                Container(
                  color: mainColor,
                ),
                PlaylistList(),
                // Container(
                //   color: mainColor,
                // )
              ],
            ),
          ),
        ],
      ),

      // bottomSheet: WidgetMiniPlayer(),
      // bottomNavigationBar: WidgetMiniPlayer(),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int index;

  @override
  final Size preferredSize;

  CustomAppBar(this.index) : preferredSize = Size.fromHeight(95.0);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    return Container(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
      color: secondaryColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Sputofy",
              style: Theme.of(context).textTheme.subtitle2.merge(
                    TextStyle(color: accentColor, fontSize: 24.0),
                  ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 30.0,
                  width: 280.0,
                  color: Colors.red,
                ),
                GestureDetector(
                  onTap: () {
                    index == 0 ? cacca() : popo();
                  },
                  child: Icon(
                    index == 0 ? Icons.menu_rounded : Icons.library_add,
                    size: 32.0,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  cacca() {
    print(0);
  }

  popo() {
    print(1);
  }
}

class PageButtons extends StatelessWidget {
  final double widthScreen;
  final int index;
  final PageController pageController;

  PageButtons(this.widthScreen, this.index, this.pageController);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthScreen,
      height: 40.0,
      color: mainColor,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              pageController.animateToPage(0,
                  duration: Duration(microseconds: 250),
                  curve: Curves.bounceInOut);
            },
            child: Container(
              width: (widthScreen - 32) / 2,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: index == 0 ? accentColor : secondaryColor,
                      width: 3.0),
                ),
              ),
              child: Center(
                child: Text(
                  "Songs",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: index == 0 ? Colors.white : secondaryColor),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              pageController.animateToPage(1,
                  duration: Duration(microseconds: 250),
                  curve: Curves.bounceInOut);
            },
            child: Container(
              width: (widthScreen - 32) / 2,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: index == 1 ? accentColor : secondaryColor,
                      width: 3.0),
                ),
              ),
              child: Center(
                child: Text(
                  "Playlist",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: index == 1 ? Colors.white : secondaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
