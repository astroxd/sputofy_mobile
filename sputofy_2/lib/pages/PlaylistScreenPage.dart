import 'package:flutter/material.dart';
import 'package:sputofy_2/model/playlistModels.dart';
import 'package:sputofy_2/model/playlistSongsModel.dart';
import 'package:sputofy_2/utils/palette.dart';

class PlaylistScreen extends StatelessWidget {
  // final Playlist playlist;
  // PlaylistScreen(this.playlist);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
    // MediaQueryData mediaQueryData = MediaQuery.of(context);
    // double widthScreen = mediaQueryData.size.width;
    // double safePadding = mediaQueryData.padding.top;
    // return Scaffold(
    //   backgroundColor: mainColor,
    //   body: SafeArea(
    //     child: FutureBuilder(
    //       future:
    //           Provider.of<DatabaseValue>(context).getPlaylistSongs(playlist.id),
    //       builder: (context, snapshot) {
    //         if (snapshot.hasData) {
    //           return Column(
    //             children: <Widget>[
    //               _buildWidgetPlaylistInfo(
    //                   widthScreen, context, safePadding, snapshot.data),
    //               SizedBox(height: 16.0),
    //               _buildWidgetPlaylistMusic(context, snapshot.data),
    //               SizedBox(
    //                 height:
    //                     75, //TODO se cambia la bottom bar questo deve cambiare
    //               )
    //             ],
    //           );
    //         } else {
    //           return CircularProgressIndicator();
    //         }
    //       },
    //     ),
    //   ),
    // );
  }

  // Widget _buildWidgetPlaylistInfo(double widthScreen, BuildContext context,
  //     double safePadding, List<PlaylistSongs> playlistSongs) {
  //   _showPopupMenu() {
  //     showMenu<String>(
  //       context: context,
  //       position: RelativeRect.fromLTRB(safePadding, safePadding, 0.0,
  //           0.0), //position where you want to show the menu on screen
  //       color: mainColor,
  //       items: [
  //         PopupMenuItem(
  //           child: const Text("Cancel Playlist"),
  //           value: '1',
  //           textStyle: TextStyle(color: Colors.red, fontSize: 18),
  //         ),
  //       ],
  //       elevation: 8.0,
  //     ).then<void>((String itemSelected) {
  //       if (itemSelected == null) return;

  //       if (itemSelected == "1") {
  //       } else if (itemSelected == "2") {
  //         //code here
  //       } else {
  //         //code here
  //       }
  //     });
  //   }

  //   return Container(
  //     width: widthScreen,
  //     color: secondaryColor,
  //     child: Column(
  //       children: <Widget>[
  //         Padding(
  //           padding:
  //               const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: <Widget>[
  //               GestureDetector(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Icon(Icons.arrow_back_ios),
  //               ),
  //               GestureDetector(
  //                 onTap: () {
  //                   _showPopupMenu();
  //                 },
  //                 child: Icon(
  //                   Icons.more_vert,
  //                   color: accentColor,
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //         Container(
  //           padding: const EdgeInsets.only(left: 32.0, top: 16.0, right: 32.0),
  //           child: Row(
  //             children: <Widget>[
  //               Container(
  //                 width: 140,
  //                 height: 140,
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(16.0),
  //                   child: Image.asset('cover.jpeg'), //TODO custom image?
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 16.0,
  //               ),
  //               Container(
  //                 height: 140,
  //                 width: 90,
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: <Widget>[
  //                     Container(
  //                       height: 108,
  //                       child: Text(
  //                         playlist.name,
  //                         style: TextStyle(
  //                             fontSize: 24.0,
  //                             fontWeight: FontWeight.bold,
  //                             color: accentColor),
  //                         overflow: TextOverflow.ellipsis,
  //                         maxLines: 3,
  //                       ),
  //                     ),
  //                     Container(
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: <Widget>[
  //                           GestureDetector(
  //                             onTap: () async {
  //                               Provider.of<MyAudio>(context, listen: false)
  //                                   .songList = playlistSongs;
  //                               // Provider.of<MyAudio>(context, listen: false)
  //                               //     .playSong(0);
  //                             },
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                   color: mainColor,
  //                                   borderRadius: BorderRadius.circular(12.0)),
  //                               child: Icon(
  //                                 Icons.play_arrow,
  //                                 size: 32.0,
  //                                 color: accentColor,
  //                               ),
  //                             ),
  //                           ),
  //                           GestureDetector(
  //                             onTap: () => Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) => SelectableSongList(
  //                                       playlistID: playlist.id,
  //                                       playlistSongs: playlistSongs),
  //                                 )),
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                   color: mainColor,
  //                                   borderRadius: BorderRadius.circular(12.0)),
  //                               child: Icon(
  //                                 Icons.add,
  //                                 size: 32.0,
  //                                 color: accentColor,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //         SizedBox(height: 10.0),
  //         Container(
  //           width: widthScreen,
  //           child: Stack(
  //             children: [
  //               Column(
  //                 children: <Widget>[
  //                   Container(
  //                     height: 36,
  //                     decoration: BoxDecoration(
  //                       border: Border(
  //                         bottom: BorderSide(color: Colors.black, width: 2.0),
  //                       ),
  //                     ),
  //                   ),
  //                   Container(
  //                     height: 36,
  //                     width: widthScreen,
  //                     color: mainColor,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(left: 16.0, top: 16.0),
  //                       child: Text(
  //                         "TODO Songs",
  //                         style: TextStyle(fontSize: 16.0, color: accentColor),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(right: 32.0),
  //                 child: Align(
  //                   alignment: Alignment.centerRight,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       GestureDetector(
  //                         onTap: () {
  //                           Provider.of<MyAudio>(context, listen: false)
  //                               .songList = playlistSongs;
  //                           //setLoop for all songs TODO
  //                         },
  //                         child: Container(
  //                           padding: const EdgeInsets.all(12.0),
  //                           decoration: BoxDecoration(
  //                               color: thirdColor,
  //                               borderRadius: BorderRadius.circular(64.0)),
  //                           child: Icon(
  //                             Icons.repeat,
  //                             size: 32.0,
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: 10.0,
  //                       ),
  //                       GestureDetector(
  //                         child: Container(
  //                           padding: const EdgeInsets.all(20.0),
  //                           decoration: BoxDecoration(
  //                               color: accentColor,
  //                               borderRadius: BorderRadius.circular(64.0)),
  //                           child: Icon(
  //                             AppIcon.shuffle,
  //                             size: 32.0,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildWidgetPlaylistMusic(
  //     BuildContext context, List<PlaylistSongs> playlistSongs) {
  //   _showPopupMenu(Offset offset, PlaylistSongs song, int index) async {
  //     double left = offset.dx;
  //     double top = offset.dy;
  //     await showMenu<String>(
  //       context: context,
  //       position: RelativeRect.fromLTRB(left, top, 0.0,
  //           0.0), //position where you want to show the menu on screen
  //       color: mainColor,
  //       items: [
  //         PopupMenuItem(
  //           child: const Text("Remove song"),
  //           value: '1',
  //           textStyle: TextStyle(color: Colors.red, fontSize: 18),
  //         )
  //       ],
  //       elevation: 6.0,
  //     ).then<void>((String itemSelected) {
  //       if (itemSelected == null) return;

  //       if (itemSelected == "1") {
  //         // Provider.of<MyAudio>(context, listen: false)
  //         //     .changeListener(context, playlist.id);
  //         print(
  //             "prima ${Provider.of<MyAudio>(context, listen: false).songList}");
  //         Provider.of<MyAudio>(context, listen: false)
  //             .songList
  //             .forEach((song) => print(song.songPath));
  //         Provider.of<MyAudio>(context, listen: false).songList.removeAt(index);
  //         Provider.of<DatabaseValue>(context, listen: false)
  //             .deletePlaylistSong(playlist.id, song.songPath);
  //         print(
  //             "dopo ${Provider.of<MyAudio>(context, listen: false).songList}");
  //         Provider.of<MyAudio>(context, listen: false)
  //             .songList
  //             .forEach((song) => print(song.songPath));
  //       } else if (itemSelected == "2") {
  //         //code here
  //       } else {
  //         //code here
  //       }
  //     });
  //   }

  //   return Expanded(
  //     child: ListView.builder(
  //       itemCount: playlistSongs.length,
  //       itemBuilder: (context, index) {
  //         String songTitle = playlistSongs[index].songPath.split('/').last;

  //         return GestureDetector(
  //           behavior: HitTestBehavior.translucent,
  //           onTap: () {
  //             Provider.of<MyAudio>(context, listen: false).songList =
  //                 playlistSongs;
  //             // Provider.of<MyAudio>(context, listen: false).playSong(index);
  //             Provider.of<MyAudio>(context, listen: false).pathPlay();
  //           },
  //           child: Column(
  //             children: <Widget>[
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     horizontal: 16.0, vertical: 8.0),
  //                 child: Row(
  //                   children: <Widget>[
  //                     Text(
  //                       '${index + 1}',
  //                       style: TextStyle(fontSize: 20, color: accentColor),
  //                     ),
  //                     SizedBox(width: 10.0),
  //                     Expanded(
  //                       child: Consumer<MyAudio>(
  //                         builder: (context, audioPlayer, child) => Text(
  //                           songTitle,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w500,
  //                             fontSize: 20,
  //                             color: audioPlayer.indexSongSelected == index &&
  //                                     audioPlayer
  //                                             .songList[
  //                                                 audioPlayer.indexSongSelected]
  //                                             .songPath ==
  //                                         playlistSongs[index].songPath
  //                                 ? accentColor
  //                                 : Colors.black,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     GestureDetector(
  //                       onTapDown: (TapDownDetails details) {
  //                         _showPopupMenu(details.globalPosition,
  //                             playlistSongs[index], index);
  //                       },
  //                       child: Icon(
  //                         Icons.more_vert,
  //                         color: accentColor,
  //                         size: 24,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Divider(
  //                 indent: 16.0,
  //                 color: Colors.black,
  //               )
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //     //
  //   );
  // }
}
