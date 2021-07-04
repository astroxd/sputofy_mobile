import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/services/database.dart';
import 'package:sputofy_2/theme/palette.dart';

class SelectSongList extends StatefulWidget {
  final int playlistID;
  final List<Song> playlistSongs;

  const SelectSongList(
      {Key? key, required this.playlistID, required this.playlistSongs})
      : super(key: key);

  @override
  _SelectSongListState createState() => _SelectSongListState();
}

class _SelectSongListState extends State<SelectSongList> {
  DBHelper _database = DBHelper();

  List<Song> toAddSongs = [];

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
                    color: toAddSongs.length == 0
                        ? kSecondaryColor
                        : kAccentColor),
              ),
              onPressed: toAddSongs.length == 0 ? null : saveSongs,
            ),
            Expanded(
                child: FutureBuilder<List<Song>>(
              future: _database.getSongs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Song> songs = snapshot.data ?? [];
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
      onChanged: (bool? value) {
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
    List<PlaylistSong> playlistSongs = [];
    List<MediaItem> songs = [];
    for (var i = 0; i < toAddSongs.length; i++) {
      playlistSongs.add(PlaylistSong(
        null,
        widget.playlistID,
        toAddSongs[i].id!,
      ));

      songs.add(
        toAddSongs[i].toMediaItem().copyWith(album: '${widget.playlistID}'),
      );
    }
    Provider.of<DBProvider>(context, listen: false)
        .savePlaylistSongs(widget.playlistID, playlistSongs);
    Navigator.pop(context, songs);
  }
}