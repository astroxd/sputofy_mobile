import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/app_icons.dart';
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

    return Container(
      color: mainColor,
      width: widthScreen,
      child: Column(
        children: <Widget>[
          _buildWidgetButtonController(widthScreen),
          _buildWidgetPlaylistList(),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetButtonController(double widthScreen) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 10.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                child: Icon(
                  AppIcon.shuffle,
                  size: 24.0,
                ),
              ),
              SizedBox(
                width: 12.0,
              ),
              GestureDetector(
                child: Icon(
                  Icons.repeat,
                  size: 28.0,
                ),
              ),
            ],
          ),
          GestureDetector(
            child: Icon(
              AppIcon.arrow_up_down,
              size: 22.0,
              color: accentColor,
            ),
          ),
        ],
      ),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.asset('cover.jpeg'),
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
