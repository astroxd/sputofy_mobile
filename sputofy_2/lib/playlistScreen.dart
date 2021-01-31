import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/main.dart';
import 'package:sputofy_2/miniPlayer.dart';
import 'package:sputofy_2/model/audioPlayer.dart';
import 'package:sputofy_2/palette.dart';

class PlaylistScreen1 extends StatelessWidget {
  final int index;

  PlaylistScreen1(this.index);

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
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.maybePop(context);
                      // Navigator.replaceRouteBelow(context, anchorRoute: null);
                      // showMiniPlayer(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: null,
                    child: Icon(Icons.plus_one, color: Colors.white),
                  )
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
                  "$index songs 1 hr 30 min",
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

class PlaylistScreen extends StatelessWidget {
  final int index;

  PlaylistScreen(this.index);
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    return Scaffold(
      body: Container(
        width: widthScreen,
        child: Column(
          children: <Widget>[
            _buildWidgetPlaylistInfo(widthScreen),
            _buildWidgetPlaylistMusic()
          ],
        ),
        color: mainColor,
      ),
    );
  }

  Widget _buildWidgetPlaylistInfo(double widthScreen) {
    return Container(
      width: widthScreen,
      color: secondaryColor,
      child: Column(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.arrow_back_ios),
                  Icon(
                    Icons.more_vert,
                    color: accentColor,
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 32.0, top: 16.0, right: 32.0),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 140,
                  height: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset('cover.jpeg'),
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
                          "Playlistdadaadawdadawdddadawddwadawd",
                          style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: accentColor),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 3,
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
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
          ),
          SizedBox(height: 10.0),
          Container(
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
                          "13 songs, 1.32 hours",
                          style: TextStyle(fontSize: 16.0, color: accentColor),
                        ),
                      ),
                    )
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
          )
        ],
      ),
    );
  }

  Widget _buildWidgetPlaylistMusic() {
    return Consumer<MyAudio>(
      builder: (context, audioPlayer, child) => Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  audioPlayer.playSong(index);
                } else if (index == audioPlayer.indexSongSelected) {
                  audioPlayer.resumeSong();
                }
                showMiniPlayer(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
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
                              color: audioPlayer.indexSongSelected == index
                                  ? accentColor
                                  : Colors.black,
                            ),
                          ),
                          Text(
                            '${song.artist}',
                            style: TextStyle(color: thirdColor),
                          ),
                        ],
                      ),
                    ),
                    Text("$strDuration"),
                    Icon(
                      Icons.more_vert,
                      color: accentColor,
                    ),
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
}
