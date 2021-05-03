import 'package:flutter/material.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/model/playlistModels.dart';
import 'package:sputofy_2/model/playlistSongsModel.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/palette.dart';

class PlaylistScreen extends StatefulWidget {
  // final Playlist playlist;
  // PlaylistScreen(this.playlist);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   color: Colors.red,
    // );
    DBHelper _database = DBHelper();
    return Scaffold(
      body: FutureBuilder(
        future: _database.getSongs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Song> canzoni = snapshot.data;
            return Column(
              children: <Widget>[
                Container(
                  height: 300,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: canzoni.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () => _database.deleteSong(index),
                          child: Text(canzoni[index].path));
                    },
                  ),
                ),
                MaterialButton(
                    child: Text("BOTTONE"),
                    color: Colors.red,
                    onPressed: () {
                      _database.saveSong(
                        Song(
                            null,
                            "/storage/emulated/0/Download/BLESS YoUr NAME - ChouCho (Highschool DXD BorN OP Full).mp3",
                            "title",
                            "andrea",
                            "cover",
                            null),
                      );
                      setState(() {});
                    }),
              ],
            );
          } else
            return CircularProgressIndicator();
        },
      ),
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
}
