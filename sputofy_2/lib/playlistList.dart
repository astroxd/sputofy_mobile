import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/main.dart';
import 'package:sputofy_2/miniPlayer.dart';
import 'package:sputofy_2/model/audioPlayer.dart';
import 'package:sputofy_2/model/databaseValues.dart';
import 'package:sputofy_2/model/playlistModel.dart';
import 'package:sputofy_2/palette.dart';
import 'package:sputofy_2/playlistScreen.dart';

class PlaylistList extends StatefulWidget {
  @override
  _PlaylistListState createState() => _PlaylistListState();
}

class _PlaylistListState extends State<PlaylistList> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double paddingBottom = mediaQueryData.padding.bottom;
    return Container(
      color: mainColor,
      width: widthScreen,
      child: Column(
        children: <Widget>[
          _buildWidgetButtonController(widthScreen),
          _buildWidgetPlaylistList(),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  Widget _buildWidgetButtonController(double widthScreen) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.shuffle,
                    size: 20.0,
                  ),
                  Text(
                    " Shuffle playback ",
                    style: Theme.of(context).textTheme.subtitle2.merge(
                          TextStyle(color: Colors.black),
                        ),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showNewPlaylistDialog(widthScreen),
            child: Icon(Icons.add),
          )
        ],
      ),
    );
  }

  void _showNewPlaylistDialog(double widthScreen) {
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

  Widget _buildWidgetPlaylistList() {
    return Expanded(
      child: FutureBuilder(
        future: Provider.of<DatabaseValue>(context).playlists,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return playlistList(snapshot.data);
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget playlistList(List<Playlist> playlists) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      crossAxisCount: 2,
      childAspectRatio: 170 / 210,
      children: List.of(
        playlists.map(
          (playlist) => GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PlaylistScreen(playlist.songPath.length))),
            child: playlistTile(playlist),
          ),
        ),
      ),
    );
  }

  Widget playlistTile(Playlist playlist) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Container(
            width: 170.0,
            height: 170.0,
            child: Stack(
              children: [
                Image.asset('cover.jpeg'),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
                    child: Consumer<MyAudio>(
                      builder: (context, audioplayer, child) => GestureDetector(
                        onTap: () {
                          audioplayer.playSong(0);
                          showMiniPlayer(context);
                        },
                        child: Icon(
                          audioplayer.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled_sharp,
                          size: 36.0,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            width: 170,
            height: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 140,
                      child: Text(
                        playlist.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Provider.of<DatabaseValue>(context, listen: false)
                            .deletePlaylist(playlist.id);
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${playlist.songPath.length} songs",
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(color: accentColor, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
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
