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
      ),
      // bottomSheet: WidgetMiniPlayer(),
      // bottomNavigationBar: WidgetMiniPlayer(),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int index;
  final PageController pageController;

  @override
  final Size preferredSize;

  CustomAppBar(this.index, this.pageController)
      : preferredSize = Size.fromHeight(140.0);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
                        child: Icon(
                          Icons.library_add,
                          size: 32.0,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: widthScreen,
              height: 46.0,
              color: Colors.teal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width: (widthScreen - 32) / 2,
                      height: 46.0,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 3.0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Songs",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      width: (widthScreen - 32) / 2,
                      height: 46.0,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 3.0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Playlist",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
    // return SafeArea(
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: <Widget>[
    //       Align(
    //         alignment: Alignment.center,
    //         child: Padding(
    //           padding: const EdgeInsets.only(left: 48.0),
    //           child: GestureDetector(
    //             onTap: () {
    //               pageController.animateToPage(0,
    //                   duration: Duration(microseconds: 250),
    //                   curve: Curves.bounceInOut);
    //             },
    //             child: Icon(
    //               Icons.list,
    //               size: 64.0,
    //               color: Colors.red,
    //             ),
    //           ),
    //         ),
    //       ),
    //       Align(
    //         alignment: Alignment.center,
    //         child: Padding(
    //           padding: const EdgeInsets.only(right: 48.0),
    //           child: GestureDetector(
    //             onTap: () {
    //               pageController.animateToPage(1,
    //                   duration: Duration(microseconds: 250),
    //                   curve: Curves.bounceInOut);
    //             },
    //             child: Icon(
    //               Icons.list,
    //               size: 64.0,
    //               color: Colors.red,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
