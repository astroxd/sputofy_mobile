import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sputofy_2/model/audioPlayer.dart';
import 'package:sputofy_2/model/databaseValues.dart';
import 'package:sputofy_2/model/playlistModel.dart';
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
      appBar: CustomAppBar(index, widthScreen, context),
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
  final double widthScreen;
  final BuildContext context;

  @override
  final Size preferredSize;

  CustomAppBar(this.index, this.widthScreen, this.context)
      : preferredSize = Size.fromHeight(95.0);

  @override
  Widget build(BuildContext context) {
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
                    index == 0
                        ? cacca()
                        : _showNewPlaylistDialog(widthScreen, context);
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

  void _showNewPlaylistDialog(double widthScreen, BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) =>
          NewPlaylistDialog(MediaQuery.of(context).viewInsets),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      backgroundColor: mainColor,
    );
  }
}

class NewPlaylistDialog extends StatefulWidget {
  NewPlaylistDialog(this.padding);
  final EdgeInsets padding;

  @override
  _NewPlaylistDialogState createState() => _NewPlaylistDialogState();
}

class _NewPlaylistDialogState extends State<NewPlaylistDialog> {
  var textController = TextEditingController(text: "cacca");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                "Playlist Title",
                style: Theme.of(context).textTheme.headline6.merge(
                      TextStyle(
                        color: accentColor,
                      ),
                    ),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "Enter playlist title",
              style: Theme.of(context).textTheme.subtitle1.merge(
                    TextStyle(
                      color: accentColor,
                      fontSize: 16,
                    ),
                  ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: textController,
              autofocus: true,
              cursorColor: accentColor,
              cursorHeight: 20.0,
              decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: secondaryColor,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 180,
                    height: 50,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.all((Radius.circular(24.0))),
                    ),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.headline6.merge(
                              TextStyle(
                                color: accentColor,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _insert,
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.all((Radius.circular(24.0))),
                    ),
                    child: Center(
                      child: Text(
                        "Save",
                        style: Theme.of(context).textTheme.headline6.merge(
                              TextStyle(color: Colors.black),
                            ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _insert() async {
    List<Playlist> playlists =
        await Provider.of<DatabaseValue>(context, listen: false).playlists;
    // print(playlists.map((e) => print(e.name.toString())));
    int max = playlists.length;
    bool isIn = false;

    for (int i = 0; i < max; i++) {
      if (textController.text == playlists[i].name) {
        isIn = true;
        break;
      }
    }

    if (isIn) {
      print("gia esiste");
    } else {
      Playlist playlist = Playlist(null, textController.text, '');
      Provider.of<DatabaseValue>(context, listen: false).savePlaylist(playlist);

      Navigator.of(context).pop();
    }
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
