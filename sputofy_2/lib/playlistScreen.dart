import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/miniPlayer.dart';
import 'package:sputofy_2/model/audioPlayer.dart';

class PlaylistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double paddingBottom = mediaQueryData.padding.bottom;
    return Scaffold(
      body: Container(
        width: widthScreen,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                _buildWidgetBackgroundCoverAlbum(widthScreen, context),
                _buildWidgetListMusic(context, paddingBottom),
              ],
            ),
            _buildWidgetButtonPlayAll(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetBackgroundCoverAlbum(
      double widthScreen, BuildContext context) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("cover.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.0),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.1),
                ],
                stops: [
                  0.0,
                  0.7,
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 24.0, left: 12.0, right: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: null,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: null,
                    child: Icon(Icons.plus_one, color: Colors.white),
                  )
                  // IconButton(
                  //     icon: Icon(
                  //       Icons.arrow_back,
                  //       color: Colors.white,
                  //     ),
                  //     onPressed: null),
                  // IconButton(
                  //     icon: Icon(Icons.plus_one, color: Colors.white),
                  //     onPressed: null)
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: widthScreen / 2.5,
              height: widthScreen / 2.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("cover.jpeg"), fit: BoxFit.cover),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 15.0,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: widthScreen / 1.45,
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  "Red (Deluxe Edition)",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .merge(TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  "22 songs 1 hr 30 min",
                  style: Theme.of(context).textTheme.subtitle2.merge(
                        TextStyle(color: Colors.grey),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetListMusic(BuildContext context, double paddingBottom) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: paddingBottom > 0 ? paddingBottom : 16.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Colors.blueGrey.withOpacity(0.7),
              Colors.white70.withOpacity(0.7),
            ],
            stops: [
              0.1,
              0.9,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 48.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Playlist",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                _buildWidgetShuffle(),
                SizedBox(width: 24.0),
                _buildWidgetRepeat(),
              ],
            ),
            SizedBox(height: 8.0),
            _buildWidgetPlaylistMusic(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetShuffle() {
    return Consumer<MyAudio>(
      builder: (context, audioPlayer, child) => GestureDetector(
        onTap: () {
          audioPlayer.isShuffle = !audioPlayer.isShuffle;
        },
        child: Icon(
          Icons.shuffle,
          color: Color(audioPlayer.isShuffle ? 0xFFAE1947 : 0xFF000000),
        ),
      ),
    );
  }

  Widget _buildWidgetRepeat() {
    return Consumer<MyAudio>(
      builder: (context, audioPlayer, child) => GestureDetector(
        onTap: () {
          audioPlayer.isLoop = !audioPlayer.isLoop;
        },
        child: Icon(
          Icons.repeat,
          color: Color(audioPlayer.isLoop ? 0xFFAE1947 : 0xFF000000),
        ),
      ),
    );
  }

  Widget _buildWidgetPlaylistMusic() {
    return Consumer<MyAudio>(
      builder: (context, audioPlayer, child) => Expanded(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            Music song = audioPlayer.songList[index];
            int durationMinute =
                song.durationSecond >= 60 ? song.durationSecond ~/ 60 : 0;
            int durationSecond = song.durationSecond >= 60
                ? song.durationSecond % 60
                : song.durationSecond;
            String strDuration = "$durationMinute:" +
                (durationSecond < 10 ? "0$durationSecond" : "$durationSecond");
            return GestureDetector(
              onTap: () {
                if (index != audioPlayer.indexSongSelected) {
                  audioPlayer.indexSongSelected = index;
                  audioPlayer.playSong(index);
                } else if (index == audioPlayer.indexSongSelected) {
                  audioPlayer.resumeSong();
                }
                showMiniPlayer(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            song.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(
                                  audioPlayer.indexSongSelected == index
                                      ? 0xFFAE1947
                                      : 0xFF000000),
                            ),
                          ),
                          Text(
                            '${song.artist} • $strDuration',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.more_vert),
                  ],
                ),
              ),
            );
          },
          itemCount: audioPlayer.songList.length,
        ),
      ),
    );
  }

  Widget _buildWidgetButtonPlayAll() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 92.0,
        decoration: BoxDecoration(
          color: Color(0xFFAE1947),
          borderRadius: BorderRadius.all(Radius.circular(48.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              color: Color(0xFFAE1947),
            )
          ],
        ),
        child: Consumer<MyAudio>(
          builder: (context, audioPlayer, child) => IconButton(
            icon: Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              audioPlayer.playSong(0);
              audioPlayer.indexSongSelected = 0;

              showMiniPlayer(context);
            },
          ),
        ),
      ),
    );
  }
}
