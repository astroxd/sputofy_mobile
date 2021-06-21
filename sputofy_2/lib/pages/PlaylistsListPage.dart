import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sputofy_2/model/PlaylistModel.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';
import 'package:sputofy_2/pages/PlaylistScreenPage.dart';
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
          ),
          Expanded(
            child: FutureBuilder(
              future: _database.getPlaylists(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  List<Playlist> _playlists = snapshot.data;

                  return ListView.builder(
                    itemCount: _playlists.length,
                    itemBuilder: (context, index) {
                      Playlist _playlist = _playlists[index];

                      return GestureDetector(
                          onLongPress: () {
                            _database.deletePlaylist(_playlist.id);
                            setState(() {});
                          },
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return PlaylistScreen(_playlist);
                              },
                            )).then((value) {
                              setState(() {});
                            });
                          },
                          child: Container(
                              // width: 40,
                              height: 100,
                              color: Colors.red,
                              child: Column(
                                children: [
                                  Text(_playlist.id.toString()),
                                  Text(_playlist.creationDate.toString()),
                                  Text(_playlist.name.toString()),
                                ],
                              )));
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
      bottomSheet: MiniPlayer(),
      //  StreamBuilder(
      //   stream: AudioService.currentMediaItemStream,
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       return MiniPlayer();
      //     } else {
      //       return Container(
      //         height: 0,
      //       );
      //     }
      //   },
      // )
      //TODO could work
    );
  }
}
