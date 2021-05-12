import 'package:flutter/material.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/model/PlaylistModel.dart';
import 'package:sputofy_2/model/PlaylistSongModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/pages/SelectSongPage.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/palette.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  PlaylistScreen(this.playlist);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  // Widget build(BuildContext context) {
  // DBHelper _database = DBHelper();
  // return Scaffold(
  //   body: FutureBuilder(
  //     future: _database.getSongs(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         List<Song> canzoni = snapshot.data;
  //         return Column(
  //           children: <Widget>[
  //             Container(
  //               height: 300,
  //               width: double.infinity,
  //               child: ListView.builder(
  //                 itemCount: canzoni.length,
  //                 itemBuilder: (context, index) {
  //                   return GestureDetector(
  //                       onTap: () {
  //                         _database.deleteSong(canzoni[index].id);
  //                         setState(() {});
  //                       },
  //                       child: Container(
  //                           color: Colors.red,
  //                           padding: const EdgeInsets.all(16.0),
  //                           child: Text(canzoni[index].path.toString())));
  //                 },
  //               ),
  //             ),
  //             MaterialButton(
  //                 child: Text("BOTTONE"),
  //                 color: Colors.red,
  //                 onPressed: () {
  //                   _database.saveSong(
  //                     Song(
  //                       null,
  //                       'percorsoooo',
  //                       "title",
  //                       "andrea",
  //                       "cover",
  //                       Duration(milliseconds: 282096),
  //                     ),
  //                   );
  //                   setState(() {});
  //                 }),
  //           ],
  //         );
  //       } else
  //         return CircularProgressIndicator();
  //     },
  //   ),
  // );
  // }
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double safePadding = mediaQueryData.padding.top;
    DBHelper _database = DBHelper();
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
          child: FutureBuilder(
        future: _database.getPlaylistSongs(widget.playlist.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Song> playlistSongs = snapshot.data;
            return Column(
              children: <Widget>[
                _buildWidgetPlaylistInfo(
                    widthScreen, context, safePadding, playlistSongs),
                SizedBox(height: 16.0),
                _buildWidgetPlaylistSongsList(playlistSongs),
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      )),
    );
  }

  Widget _buildWidgetPlaylistInfo(double widthScreen, BuildContext context,
      double safePadding, List<Song> playlistSongs) {
    return Container(
      width: widthScreen,
      color: secondaryColor,
      child: Column(
        children: <Widget>[
          _buildTopBar(),
          _buildPlaylistData(),
          SizedBox(height: 10.0),
          _buildPlaylistActionButtons(widthScreen),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios),
          ),
          GestureDetector(
            onTap: () {
              // _showPopupMenu();
            },
            child: Icon(
              Icons.more_vert,
              color: accentColor,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaylistData() {
    return Container(
      padding: const EdgeInsets.only(left: 32.0, top: 16.0, right: 32.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 140,
            height: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset('cover.jpeg'), //TODO custom image?
            ),
          ),
          SizedBox(
            width: 16.0,
          ),
          Container(
            height: 140,
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 108,
                  child: Text(
                    widget.playlist.name ?? "noTITLE",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: accentColor),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Icon(
                            Icons.play_arrow,
                            size: 32.0,
                            color: accentColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return SelectSongList();
                            },
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Icon(
                            Icons.add,
                            size: 32.0,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaylistActionButtons(double widthScreen) {
    return Container(
      width: widthScreen,
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                height: 36,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
              Container(
                height: 36,
                width: widthScreen,
                color: mainColor,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Text(
                    "TODO Songs",
                    style: TextStyle(fontSize: 16.0, color: accentColor),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: thirdColor,
                          borderRadius: BorderRadius.circular(64.0)),
                      child: Icon(
                        Icons.repeat,
                        size: 32.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(64.0)),
                      child: Icon(
                        AppIcon.shuffle,
                        size: 32.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetPlaylistSongsList(List<Song> playlistSongs) {
    _showPopupMenu(Offset offset, Song song) async {
      double left = offset.dx;
      double top = offset.dy;
      await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(left, top, 0.0,
            0.0), //position where you want to show the menu on screen
        color: mainColor,
        items: [
          PopupMenuItem(
            child: const Text("Remove song"),
            value: '1',
            textStyle: TextStyle(color: Colors.red, fontSize: 18),
          )
        ],
        elevation: 6.0,
      ).then<void>((String itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          // Provider.of<MyAudio>(context, listen: false)
          //     .changeListener(context, playlist.id);

        } else if (itemSelected == "2") {
          //code here
        } else {
          //code here
        }
      });
    }

    return Expanded(
      child: ListView.builder(
        itemCount: playlistSongs.length,
        itemBuilder: (context, index) {
          String songTitle = playlistSongs[index].title;

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {},
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${index + 1}',
                        style: TextStyle(fontSize: 20, color: accentColor),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          songTitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _showPopupMenu(
                              details.globalPosition, playlistSongs[index]);
                        },
                        child: Icon(
                          Icons.more_vert,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  indent: 16.0,
                  color: Colors.black,
                )
              ],
            ),
          );
        },
      ),
      //
    );
  }
}
