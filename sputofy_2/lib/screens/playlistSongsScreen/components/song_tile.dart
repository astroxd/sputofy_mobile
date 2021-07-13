import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/theme/palette.dart';

import '../../../main.dart';
import '../playlist_songs_screen.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final List<Song> songs;
  final Playlist playlist;
  final MediaItem? playingItem;
  final int index;

  const SongTile(
      this.song, this.songs, this.playlist, this.playingItem, this.index,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (playingItem?.album != '${playlist.id}') {
          await loadQueue(playlist.id!, songs,
              songPath: song.path, playlistTitle: playlist.name);
        } else {
          await AudioService.skipToQueueItem(song.path);
          await AudioService.play();
        }
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: kPrimaryColor))),
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
        child: Row(
          children: <Widget>[
            Text(
              "${index + 1}",
              style: Theme.of(context).textTheme.subtitle2,
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                song.title,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: playingItem?.id == song.path ? kAccentColor : null,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.0),
            Text(
              getSongDuration(song.duration),
              style: Theme.of(context).textTheme.subtitle2,
            ),
            songMenuButton(
              song,
              context,
              playlist: playlist,
              icon: Icons.more_vert,
            ),
          ],
        ),
      ),
    );
  }
}
