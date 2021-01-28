import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/miniPlayer.dart';
import 'package:sputofy_2/model/audioPlayer.dart';
import 'package:sputofy_2/model/databaseValues.dart';
import 'package:sputofy_2/model/playlistModel.dart';
import 'package:sputofy_2/palette.dart';
import 'package:sputofy_2/playlistScreen.dart';

import 'package:sputofy_2/utils/Database.dart';

class PlaylistList extends StatefulWidget {
  @override
  _PlaylistListState createState() => _PlaylistListState();
}

class _PlaylistListState extends State<PlaylistList> {
  final dbProvider = DBProvider.instance;
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double paddingBottom = mediaQueryData.padding.bottom;
    return Scaffold(
      body: Container(
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
      future: dbProvider.queryRowCount(),
      builder: (context, snapshot) {
        Widget retVal;
        if (snapshot.connectionState == ConnectionState.done) {
          retVal = GridView.count(
            crossAxisCount: 2,
            children: List.generate(snapshot.data, (index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PlaylistScreen(index))),
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('cover.jpeg'),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Provider.of<MyAudio>(context, listen: false)
                                  .playSong(0);
                              showMiniPlayer(context);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 112, left: 112),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueGrey[800]),
                                child: Consumer<MyAudio>(
                                  builder: (context, audioPlayer, child) {
                                    if (audioPlayer.isPlaying) {
                                      return Icon(
                                        Icons.pause,
                                        color: Colors.white,
                                        size: 32.0,
                                      );
                                    } else {
                                      return Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32.0,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        width: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Playlist',
                              style:
                                  Theme.of(context).textTheme.subtitle2.merge(
                                        TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0),
                                      ),
                            ),
                            GestureDetector(
                              child: Icon(Icons.more_vert),
                            )
                          ],
                        ),
                      ),
                      Text(
                        '1000 songs',
                        style: Theme.of(context).textTheme.headline4.merge(
                              TextStyle(color: Colors.black, fontSize: 14.0),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        } else {
          retVal = CircularProgressIndicator();
        }
        return retVal;
      },
    ));

    // return Expanded(
    //   child: GridView.count(
    //     padding: EdgeInsets.only(left: 20.0),
    //     crossAxisCount: 2,
    //     children: List.generate(
    //       5,
    //       (index) {
    //         return GestureDetector(
    //           onTap: () => Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => PlaylistScreen(),
    //             ),
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Stack(
    //                 children: <Widget>[
    //                   Container(
    //                     width: 165.0,
    //                     height: 150.0,
    //                     decoration: BoxDecoration(
    //                       image: DecorationImage(
    //                         image: AssetImage("cover.jpeg"),
    //                       ),
    //                     ),
    //                   ),
    //                   Align(
    //                     alignment: Alignment.bottomRight,
    //                     child: Padding(
    //                       padding:
    //                           const EdgeInsets.only(top: 115.0, right: 30.0),
    //                       child: GestureDetector(
    //                         onTap: () => print("play"),
    //                         child: Container(
    //                           decoration: BoxDecoration(
    //                             shape: BoxShape.circle,
    //                             color: Colors.blueGrey[800],
    //                           ),
    //                           child: Icon(Icons.play_arrow,
    //                               color: Colors.white, size: 32.0),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: <Widget>[
    //                   Padding(
    //                     padding: const EdgeInsets.only(top: 0.0, left: 10.0),
    //                     child: Text(
    //                       'Playlist',
    //                       style: Theme.of(context).textTheme.subtitle2.merge(
    //                             TextStyle(color: Colors.black, fontSize: 14.0),
    //                           ),
    //                     ),
    //                   ),
    //                   GestureDetector(
    //                     onTap: () => print("more vert"),
    //                     child: Padding(
    //                       padding: const EdgeInsets.only(top: 0.0, right: 21.0),
    //                       child: Icon(Icons.more_vert_outlined),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Text(
    //                 "data",
    //                 style: Theme.of(context)
    //                     .textTheme
    //                     .headline6
    //                     .merge(TextStyle(fontSize: 8.0)),
    //               )
    //             ],
    //           ),
    //         );
    //       },
    //     ),
    //   ),
    // );
  }
}

class NewPlaylistDialog extends StatefulWidget {
  NewPlaylistDialog(this.padding);
  final EdgeInsets padding;

  @override
  _NewPlaylistDialogState createState() => _NewPlaylistDialogState();
}

class _NewPlaylistDialogState extends State<NewPlaylistDialog> {
  final textController = TextEditingController(text: "cacca");
  final dbProvider = DBProvider.instance;

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
                  onTap: _delete,
                  // () => Navigator.of(context).pop(),
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
    List playlistNames =
        await Provider.of<DatabaseValue>(context, listen: false)
            .getDatabaseName();
    bool isIn = false;

    for (int i = 0; i < playlistNames.length; i++) {
      if (textController.text == playlistNames[i]) {
        isIn = true;
        break;
      }
    }

    if (isIn) {
      print("gia esiste");
    } else {
      Map<String, dynamic> row = {
        DBProvider.columnName: textController.text,
        DBProvider.columnSongPath: ''
      };

      final id = await dbProvider.insert(row);
      print("Inserita $id");
      Navigator.of(context).pop();
    }
  }

  void _query() async {
    final allRows = await dbProvider.queryAllRows();
    print("query all rows:");
    allRows.forEach((row) => print(row['id']));
    print(allRows[0]['name']);
  }

  _delete() async {
    // // Assuming that the number of rows is the id for the last row.
    // final id = await Provider.of<DatabaseValue>(context, listen: false)
    //     .getDatabaseName();
    // final rowsDeleted = await dbProvider.delete(id);

    // print('deleted $rowsDeleted row(s): row $id');
    Provider.of<DatabaseValue>(context, listen: false).deletePlaylist();
  }
}
