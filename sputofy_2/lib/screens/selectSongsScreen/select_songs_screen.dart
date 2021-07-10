import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/services/database.dart';
import 'package:sputofy_2/theme/palette.dart';

class SelectSongList extends StatefulWidget {
  final Playlist playlist;
  final List<Song> playlistSongs;

  const SelectSongList(
      {Key? key, required this.playlist, required this.playlistSongs})
      : super(key: key);

  @override
  _SelectSongListState createState() => _SelectSongListState();
}

class _SelectSongListState extends State<SelectSongList> {
  DBHelper _database = DBHelper();
  Playlist get playlist => widget.playlist;
  List<Song> get playlistSongs => widget.playlistSongs;

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

                        return playlistSongs
                                .any((element) => element.id == song.id)
                            ? _unselectableSong(song)
                            : _selectableSong(song);
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
      ),
    );
  }

  Widget _unselectableSong(Song song) {
    return Theme(
      data: ThemeData(disabledColor: kSecondaryBackgroundColor),
      child: CheckboxListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          title: Text(
            song.title,
            style:
                Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 16.0),
          ),
          value: true,
          onChanged: null),
    );
  }

  Widget _selectableSong(Song song) {
    bool isSelected = toAddSongs.any((element) => element.id == song.id);
    return CheckboxListTile(
      title: Text(
        song.title,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: isSelected ? kAccentColor : null),
      ),
      value: isSelected,
      onChanged: (bool? value) {
        if (isSelected) {
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
        playlist.id!,
        toAddSongs[i].id!,
      ));

      //TODO review
      songs.add(
        toAddSongs[i].toMediaItem().copyWith(album: '${playlist.id}'),
      );
      if (playlist.id! == 0) {
        Provider.of<DBProvider>(context, listen: false)
            .updateSong(toAddSongs[i].copyWith(isFavorite: true));
      }
    }

    Provider.of<DBProvider>(context, listen: false)
        .savePlaylistSongs(playlist.id!, playlistSongs);
    Navigator.pop(context, songs);
  }
}
