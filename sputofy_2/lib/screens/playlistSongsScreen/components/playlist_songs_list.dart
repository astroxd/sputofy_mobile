import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/screens/playlistSongsScreen/components/song_tile.dart';

class buildWidgetPlaylistList extends StatelessWidget {
  final BuildContext context;
  final Playlist playlist;
  final List<Song> songs;
  final MediaItem? playingItem;

  const buildWidgetPlaylistList(
      this.context, this.playlist, this.songs, this.playingItem,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          Song song = songs[index];
          return SongTile(song, songs, playlist, playingItem, index);
        },
      ),
    );
  }
}
