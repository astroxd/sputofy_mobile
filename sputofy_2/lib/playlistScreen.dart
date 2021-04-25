import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/main.dart';
import 'package:sputofy_2/miniPlayer.dart';
import 'package:sputofy_2/model/audioPlayer.dart';
import 'package:sputofy_2/model/databaseValues.dart';
import 'package:sputofy_2/model/folderPathmodel.dart';
import 'package:sputofy_2/model/playlistModels.dart';
import 'package:sputofy_2/model/playlistSongsModel.dart';
import 'package:sputofy_2/utils/palette.dart';
import 'package:sputofy_2/selectableSongList.dart';
import 'package:sqflite/sqflite.dart';

// class PlaylistScreen1 extends StatelessWidget {
//   final int index;

//   PlaylistScreen1(this.index);

//   @override
//   Widget build(BuildContext context) {
//     MediaQueryData mediaQueryData = MediaQuery.of(context);
//     double widthScreen = mediaQueryData.size.width;
//     double paddingBottom = mediaQueryData.padding.bottom;
//     return Scaffold(
//       body: Container(
//         width: widthScreen,
//         child: Stack(
//           children: <Widget>[
//             Column(
//               children: <Widget>[
//                 _buildWidgetBackgroundCoverAlbum(widthScreen, context),
//                 _buildWidgetListMusic(context, paddingBottom),
//               ],
//             ),
//             _buildWidgetButtonPlayAll(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWidgetBackgroundCoverAlbum(
//       double widthScreen, BuildContext context) {
//     return Expanded(
//       child: Stack(
//         children: <Widget>[
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("cover.jpeg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.0),
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [
//                   Colors.black,
//                   Colors.black.withOpacity(0.1),
//                 ],
//                 stops: [
//                   0.0,
//                   0.7,
//                 ],
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.topCenter,
//             child: Padding(
//               padding:
//                   const EdgeInsets.only(top: 24.0, left: 12.0, right: 12.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                       // Navigator.maybePop(context);
//                       // Navigator.replaceRouteBelow(context, anchorRoute: null);
//                       // showMiniPlayer(context);
//                     },
//                     child: Icon(Icons.arrow_back, color: Colors.white),
//                   ),
//                   GestureDetector(
//                     onTap: null,
//                     child: Icon(Icons.plus_one, color: Colors.white),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.center,
//             child: Container(
//               width: widthScreen / 2.5,
//               height: widthScreen / 2.5,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: AssetImage("cover.jpeg"), fit: BoxFit.cover),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.black,
//                   width: 15.0,
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.center,
//             child: Column(
//               children: <Widget>[
//                 SizedBox(
//                   height: widthScreen / 1.45,
//                 ),
//                 SizedBox(
//                   height: 4.0,
//                 ),
//                 Text(
//                   "Red (Deluxe Edition)",
//                   style: Theme.of(context)
//                       .textTheme
//                       .headline6
//                       .merge(TextStyle(color: Colors.white)),
//                 ),
//                 SizedBox(
//                   height: 4.0,
//                 ),
//                 Text(
//                   "$index songs 1 hr 30 min",
//                   style: Theme.of(context).textTheme.subtitle2.merge(
//                         TextStyle(color: Colors.grey),
//                       ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWidgetListMusic(BuildContext context, double paddingBottom) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.only(
//           left: 16.0,
//           right: 16.0,
//           bottom: paddingBottom > 0 ? paddingBottom : 16.0,
//         ),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.bottomRight,
//             end: Alignment.topLeft,
//             colors: [
//               Colors.blueGrey.withOpacity(0.7),
//               Colors.white70.withOpacity(0.7),
//             ],
//             stops: [
//               0.1,
//               0.9,
//             ],
//           ),
//         ),
//         child: Column(
//           children: <Widget>[
//             SizedBox(height: 48.0),
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Text(
//                     "Playlist",
//                     style: Theme.of(context).textTheme.headline6,
//                   ),
//                 ),
//                 _buildWidgetShuffle(),
//                 SizedBox(width: 24.0),
//                 _buildWidgetRepeat(),
//               ],
//             ),
//             SizedBox(height: 8.0),
//             _buildWidgetPlaylistMusic(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWidgetShuffle() {
//     return Consumer<MyAudio>(
//       builder: (context, audioPlayer, child) => GestureDetector(
//         onTap: () {
//           audioPlayer.isShuffle = !audioPlayer.isShuffle;
//         },
//         child: Icon(
//           Icons.shuffle,
//           color: Color(audioPlayer.isShuffle ? 0xFFAE1947 : 0xFF000000),
//         ),
//       ),
//     );
//   }

//   Widget _buildWidgetRepeat() {
//     return Consumer<MyAudio>(
//       builder: (context, audioPlayer, child) => GestureDetector(
//         onTap: () {
//           audioPlayer.isLoop = !audioPlayer.isLoop;
//         },
//         child: Icon(
//           Icons.repeat,
//           color: Color(audioPlayer.isLoop ? 0xFFAE1947 : 0xFF000000),
//         ),
//       ),
//     );
//   }

//   Widget _buildWidgetPlaylistMusic() {
//     return Consumer<MyAudio>(
//       builder: (context, audioPlayer, child) => Expanded(
//         child: ListView.builder(
//           padding: EdgeInsets.zero,
//           itemBuilder: (context, index) {
//             // Music song = audioPlayer.songList[index];
//             // int durationMinute =
//             //     song.durationSecond >= 60 ? song.durationSecond ~/ 60 : 0;
//             // int durationSecond = song.durationSecond >= 60
//             //     ? song.durationSecond % 60
//             //     : song.durationSecond;
//             // String strDuration = "$durationMinute:" +
//             //     (durationSecond < 10 ? "0$durationSecond" : "$durationSecond");
//             return GestureDetector(
//               onTap: () {
//                 if (index != audioPlayer.indexSongSelected) {
//                   // audioPlayer.playSong(index);
//                 } else if (index == audioPlayer.indexSongSelected) {
//                   audioPlayer.resumeSong();
//                 }
//                 // showMiniPlayer(context);
//               },
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Expanded(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             song.title,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               color: Color(
//                                   audioPlayer.indexSongSelected == index
//                                       ? 0xFFAE1947
//                                       : 0xFF000000),
//                             ),
//                           ),
//                           Text(
//                             '${song.artist} • $strDuration',
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(Icons.more_vert),
//                   ],
//                 ),
//               ),
//             );
//           },
//           itemCount: audioPlayer.songList.length,
//         ),
//       ),
//     );
//   }

//   Widget _buildWidgetButtonPlayAll() {
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         width: 92.0,
//         decoration: BoxDecoration(
//           color: Color(0xFFAE1947),
//           borderRadius: BorderRadius.all(Radius.circular(48.0)),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 10.0,
//               color: Color(0xFFAE1947),
//             )
//           ],
//         ),
//         child: Consumer<MyAudio>(
//           builder: (context, audioPlayer, child) => IconButton(
//             icon: Icon(
//               Icons.play_arrow,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               audioPlayer.playSong(0);
//               audioPlayer.indexSongSelected = 0;

//               showMiniPlayer(context);
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

class PlaylistScreen extends StatelessWidget {
  final Playlist playlist;
  PlaylistScreen(this.playlist);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double safePadding = mediaQueryData.padding.top;
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: FutureBuilder(
          future:
              Provider.of<DatabaseValue>(context).getPlaylistSongs(playlist.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  _buildWidgetPlaylistInfo(
                      widthScreen, context, safePadding, snapshot.data),
                  SizedBox(height: 16.0),
                  _buildWidgetPlaylistMusic(context, snapshot.data),
                  SizedBox(
                    height:
                        75, //TODO se cambia la bottom bar questo deve cambiare
                  )
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWidgetPlaylistInfo(double widthScreen, BuildContext context,
      double safePadding, List<PlaylistSongs> playlistSongs) {
    _showPopupMenu() {
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(safePadding, safePadding, 0.0,
            0.0), //position where you want to show the menu on screen
        color: mainColor,
        items: [
          PopupMenuItem(
            child: const Text("Cancel Playlist"),
            value: '1',
            textStyle: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ],
        elevation: 8.0,
      ).then<void>((String itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
        } else if (itemSelected == "2") {
          //code here
        } else {
          //code here
        }
      });
    }

    return Container(
      width: widthScreen,
      color: secondaryColor,
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    _showPopupMenu();
                  },
                  child: Icon(
                    Icons.more_vert,
                    color: accentColor,
                  ),
                )
              ],
            ),
          ),
          Container(
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
                          playlist.name,
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
                              onTap: () async {
                                Provider.of<MyAudio>(context, listen: false)
                                    .songList = playlistSongs;
                                // Provider.of<MyAudio>(context, listen: false)
                                //     .playSong(0);
                              },
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
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectableSongList(
                                        playlistID: playlist.id,
                                        playlistSongs: playlistSongs),
                                  )),
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
                          onTap: () {
                            Provider.of<MyAudio>(context, listen: false)
                                .songList = playlistSongs;
                            //setLoop for all songs TODO
                          },
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

  Widget _buildWidgetPlaylistMusic(
      BuildContext context, List<PlaylistSongs> playlistSongs) {
    _showPopupMenu(Offset offset, PlaylistSongs song, int index) async {
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
          print(
              "prima ${Provider.of<MyAudio>(context, listen: false).songList}");
          Provider.of<MyAudio>(context, listen: false)
              .songList
              .forEach((song) => print(song.songPath));
          Provider.of<MyAudio>(context, listen: false).songList.removeAt(index);
          Provider.of<DatabaseValue>(context, listen: false)
              .deletePlaylistSong(playlist.id, song.songPath);
          print(
              "dopo ${Provider.of<MyAudio>(context, listen: false).songList}");
          Provider.of<MyAudio>(context, listen: false)
              .songList
              .forEach((song) => print(song.songPath));
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
          String songTitle = playlistSongs[index].songPath.split('/').last;

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Provider.of<MyAudio>(context, listen: false).songList =
                  playlistSongs;
              // Provider.of<MyAudio>(context, listen: false).playSong(index);
              Provider.of<MyAudio>(context, listen: false).pathPlay();
            },
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
                        child: Consumer<MyAudio>(
                          builder: (context, audioPlayer, child) => Text(
                            songTitle,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: audioPlayer.indexSongSelected == index &&
                                      audioPlayer
                                              .songList[
                                                  audioPlayer.indexSongSelected]
                                              .songPath ==
                                          playlistSongs[index].songPath
                                  ? accentColor
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _showPopupMenu(details.globalPosition,
                              playlistSongs[index], index);
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

    // return Consumer<MyAudio>(
    //   builder: (context, audioPlayer, child) => Expanded(
    //     child: audioPlayer.songList.length == 0
    //         ? Center(
    //             child: MaterialButton(
    //               onPressed: () {
    //                 Provider.of<DatabaseValue>(context, listen: false)
    //                     .addSongs(playlist.id, [
    //                   "/storage/emulated/0/Download/Yahari Ore no Seishun Love Comedy wa Machigatteiru Zoku  OP FULL   [LYRICS]   (1).mp3",
    //                   "/storage/emulated/0/Download/Darling in the FranXX Ending 3 Full - Beautiful World  XXme.mp3"
    //                 ]);
    //                 print("aggiunge");
    //                 Provider.of<DatabaseValue>(
    //                   context,
    //                   listen: false,
    //                 ).retrieveSongs(playlist.id);
    //               },
    //               // Navigator.of(context).push(MaterialPageRoute(
    //               //   builder: (context) => SelectableSongList(),

    //               child: Text(
    //                 "è vuoto\naggingi una canzone",
    //                 style: TextStyle(fontSize: 32),
    //               ),
    //             ),
    //           )
    //         : ListView.builder(
    //             itemBuilder: (context, index) {
    //               Music song = audioPlayer.songList[index];
    //               int durationMinute =
    //                   song.durationSecond >= 60 ? song.durationSecond ~/ 60 : 0;
    //               int durationSecond = song.durationSecond >= 60
    //                   ? song.durationSecond % 60
    //                   : song.durationSecond;
    //               String strDuration = "$durationMinute:" +
    //                   (durationSecond < 10
    //                       ? "0$durationSecond"
    //                       : "$durationSecond");

    //               return GestureDetector(
    //                 behavior: HitTestBehavior.translucent,
    //                 onTap: () {
    //                   if (index != audioPlayer.indexSongSelected) {
    //                     audioPlayer.playSong(index);
    //                   } else if (index == audioPlayer.indexSongSelected) {
    //                     audioPlayer.resumeSong();
    //                   }
    //                   showMiniPlayer(context);
    //                 },
    //                 child: Column(
    //                   children: [
    //                     Padding(
    //                       padding: const EdgeInsets.symmetric(
    //                           horizontal: 16.0, vertical: 8.0),
    //                       child: Row(
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: <Widget>[
    //                           Expanded(
    //                             child: Row(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: <Widget>[
    //                                 Text(
    //                                   '${index + 1}',
    //                                   style: TextStyle(
    //                                       fontSize: 20, color: accentColor),
    //                                 ),
    //                                 SizedBox(width: 10.0),
    //                                 Text(
    //                                   song.title,
    //                                   style: TextStyle(
    //                                     fontWeight: FontWeight.w500,
    //                                     fontSize: 20,
    //                                     color: audioPlayer.indexSongSelected ==
    //                                             index
    //                                         ? accentColor
    //                                         : Colors.black,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           Text(
    //                             "$strDuration",
    //                             style: TextStyle(
    //                               fontWeight: FontWeight.w700,
    //                               fontSize: 20,
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             width: 8,
    //                           ),
    //                           GestureDetector(
    //                             onTapDown: (TapDownDetails details) {
    //                               _showPopupMenu(details.globalPosition);
    //                             },
    //                             child: Icon(
    //                               Icons.more_vert,
    //                               color: accentColor,
    //                               size: 24,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     Divider(
    //                       color: Colors.black,
    //                       thickness: .5,
    //                       indent: 16.0,
    //                     ),
    //                   ],
    //                 ),
    //               );
    //             },
    //             itemCount: audioPlayer.songList.length,
    //           ),
    //   ),
    // );
  }
}
