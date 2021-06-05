import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sputofy_2/model/PlaylistSongModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/palette.dart';

class SelectSongList extends StatefulWidget {
  final int playlistID;
  final List<Song> playlistSongs;

  const SelectSongList({Key key, this.playlistID, this.playlistSongs})
      : super(key: key);

  @override
  _SelectSongListState createState() => _SelectSongListState();
}

class _SelectSongListState extends State<SelectSongList> {
  DBHelper _database = DBHelper();

  List<Song> toAddSongs = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MaterialButton(
              child: Text(
                "ADD SONGS",
                style: TextStyle(
                    color:
                        toAddSongs.length == 0 ? secondaryColor : accentColor),
              ),
              onPressed: toAddSongs.length == 0 ? null : saveSongs,
            ),
            Expanded(
                child: FutureBuilder(
              future: _database.getSongs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Song> songs = snapshot.data;
                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      Song song = songs[index];

                      return Theme(
                        data: ThemeData(disabledColor: Colors.red),
                        child: widget.playlistSongs
                                .any((element) => element.id == song.id)
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
            Expanded(
                child: ListView.builder(
              itemCount: toAddSongs.length,
              itemBuilder: (context, index) {
                return Text(toAddSongs[index].path);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _unselectableSong(Song song) {
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
      value: toAddSongs.any((element) => element.id == song.id),
      onChanged: (bool value) {
        if (toAddSongs.any((element) => element.id == song.id)) {
          setState(() {
            toAddSongs.removeWhere((element) => element.id == song.id);
          });
        } else {
          setState(() {
            toAddSongs.add(song);
          });
        }
      },
    );
  }

  void saveSongs() {
    List<Map<String, dynamic>> songMaps = [];
    for (var i = 0; i < toAddSongs.length; i++) {
      _database.savePlaylistSong(PlaylistSong(
        null,
        widget.playlistID,
        toAddSongs[i].id,
      ));
      songMaps.add(toAddSongs[i].toMap());
    }

    Navigator.pop(context, songMaps);
  }
}
