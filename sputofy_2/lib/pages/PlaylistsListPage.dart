import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sputofy_2/model/PlaylistModel.dart';
import 'package:sputofy_2/utils/Database.dart';

class PlaylistsList extends StatefulWidget {
  @override
  _PlaylistsListState createState() => _PlaylistsListState();
}

class _PlaylistsListState extends State<PlaylistsList> {
  @override
  Widget build(BuildContext context) {
    DBHelper _database = DBHelper();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: _database.getPlaylists(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  List<Playlist> canzoni = snapshot.data;
                  return ListView.builder(
                    itemCount: canzoni.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            _database.deletePlaylist(canzoni[index].id);
                            setState(() {});
                          },
                          child: Container(
                              child: Text(
                                  canzoni[index].creationDate.toString())));
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          MaterialButton(
            color: Colors.red,
            onPressed: () {
              _database.savePlaylist(
                Playlist(
                  null,
                  'playlsit',
                  'cover',
                  DateTime.now(),
                  Duration(milliseconds: 300),
                ),
              );
              setState(() {});
            },
            child: Text("data"),
          )
        ],
      ),
    );
  }
}
