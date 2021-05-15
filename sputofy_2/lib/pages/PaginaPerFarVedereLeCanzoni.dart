import 'package:flutter/material.dart';
import 'package:sputofy_2/model/PlaylistSongModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/utils/Database.dart';

class ListaCanzoni extends StatefulWidget {
  @override
  _ListaCanzoniState createState() => _ListaCanzoniState();
}

class _ListaCanzoniState extends State<ListaCanzoni> {
  @override
  Widget build(BuildContext context) {
    DBHelper _database = DBHelper();
    List<Song> toADD = [];
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
                          onLongPress: () {
                            _database.deleteSong(canzoni[index].id);
                            setState(() {});
                          },
                          child: Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(canzoni[index].path.toString())));
                    },
                  ),
                ),
                MaterialButton(
                    child: Text("Salva canzone"),
                    color: Colors.red,
                    onPressed: () {
                      _database.saveSong(
                        Song(
                          null,
                          'tsukasa',
                          "title",
                          "andrea",
                          "cover",
                          Duration(milliseconds: 282096),
                        ),
                      );
                      setState(() {});
                    }),
                MaterialButton(
                    child: Text("ADD TO PLAYLIST"),
                    color: Colors.red,
                    onPressed: () {
                      print("da aggiungere ${toADD[0].id}");
                      PlaylistSong canz = PlaylistSong(null, 1, toADD[0].id);
                      print(canz.playlistID);
                      _database
                          .savePlaylistSong(PlaylistSong(null, 1, toADD[0].id));
                    }),
                Expanded(
                  child: FutureBuilder(
                    future: _database.getPlaylistSongs(1),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Song> canzoni = snapshot.data;
                        print("CANZONI ${canzoni[0].author}");
                        return ListView.builder(
                          itemCount: canzoni.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.amber,
                              child: Text(canzoni[index].path),
                            );
                          },
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ],
            );
          } else
            return CircularProgressIndicator();
        },
      ),
    );
  }
}
