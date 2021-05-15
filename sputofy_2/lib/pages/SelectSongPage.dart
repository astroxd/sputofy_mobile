import 'package:flutter/material.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/utils/Database.dart';

class Canzoni {
  int id;
  String nome;
  bool clicked;

  Canzoni(this.id, this.nome, this.clicked);
}

class SelectSongList extends StatefulWidget {
  final int playlistID;

  const SelectSongList({Key key, this.playlistID}) : super(key: key);

  @override
  _SelectSongListState createState() => _SelectSongListState();
}

class _SelectSongListState extends State<SelectSongList> {
  DBHelper _database = DBHelper();
  Canzoni cacca = Canzoni(1, "canzone 1", false);
  Canzoni cacca2 = Canzoni(2, "canzone 2", false);
  List<Canzoni> canzs = [];

  List<Canzoni> prova = [];

  List<Song> playlistSongs = [];

  @override
  void initState() {
    print("pla id ${widget.playlistID}");
    canzs.add(cacca);
    canzs.add(cacca2);
    prova.add(cacca);
    loadPlaylistSongs();
    super.initState();
  }

  loadPlaylistSongs() async {
    playlistSongs = await _database.getPlaylistSongs(widget.playlistID);
    print(" CANOZNIENIENINFI$playlistSongs");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: canzs.length,
          //     itemBuilder: (context, index) {
          //       print("contiene ?${prova.contains(canzs[index])}");
          //       return CheckboxListTile(
          //         activeColor: Colors.orange,
          //         title: Text(canzs[index].nome),
          //         value: prova.contains(canzs[index]),
          //         onChanged: (bool value) {
          //           setState(() {
          //             canzs[index].clicked = value;
          //           });
          //         },
          //       );
          //     },
          //   ),
          // ),
          Expanded(
              child: FutureBuilder(
            future: _database.getSongs(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print("Canzoni palylist $playlistSongs");
                List<Song> songs = snapshot.data;
                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    Song song = songs[index];
                    print("la contine? ${playlistSongs.contains(song)}");

                    return Theme(
                      data: ThemeData(disabledColor: Colors.red),
                      child: playlistSongs.contains(song)
                          ? _unselectableSong(song)
                          : _selectableSong(song),
                    );
                  },
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          )),
          CustomTile(),
        ],
      ),
    );
  }

  Widget _unselectableSong(Song song) {
    // return InkWell(
    //   onTap: () => print(cacca),
    //   child: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Row(
    //       children: <Widget>[
    //         Expanded(child: Text(song.title)),
    //         Theme(
    //             data: ThemeData(disabledColor: Colors.red),
    //             child: Checkbox(value: true, onChanged: null)),
    //       ],
    //     ),
    //   ),
    // );
    return CheckboxListTile(
        title: Text(
          song.title,
          style: TextStyle(color: Colors.blue),
        ),
        value: true,
        onChanged: null);
  }

  Widget _selectableSong(Song song) {
    return CheckboxListTile(
      title: Text(song.path),
      value: false,
      onChanged: (bool value) {},
    );
  }

  Widget CustomTile() {
    return Theme(
        data: ThemeData(disabledColor: Colors.red),
        child: CheckboxListTile(
            title: Text(
              "cacca",
              style: TextStyle(color: Colors.blue),
            ),
            value: true,
            onChanged: null));
  }
}
