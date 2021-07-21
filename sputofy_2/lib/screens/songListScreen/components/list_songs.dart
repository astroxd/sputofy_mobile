import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/components/get_song_duration.dart';
import 'package:sputofy_2/components/songsPage/load_song.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'package:sputofy_2/components/load_queue.dart';
import 'package:sputofy_2/components/song_menu_button.dart';

import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';

import 'package:sputofy_2/theme/palette.dart';

class ListSongs extends StatelessWidget {
  final BuildContext context;
  final List<Song> songs;
  final MediaItem? playingItem;
  ListSongs(this.context, this.songs, this.playingItem);

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty)
      return Expanded(
        child: Center(
          child: GestureDetector(
            onTap: () => loadSongs(context),
            child: Text(
              'Load Songs...',
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: kSecondaryColor,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ),
      );
    return Expanded(
      child: ListView.builder(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          Song song = songs[index];

          return InkWell(
            onTap: () async {
              if (playingItem?.album != '-2') {
                await loadQueue(-2, songs, songPath: song.path);
              } else {
                await AudioService.skipToQueueItem(song.path);
                await AudioService.play();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kPrimaryColor),
                ),
              ),
              margin: const EdgeInsets.only(left: 16.0),
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "${index + 1}",
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          song.title,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: playingItem?.id == song.path
                                      ? kAccentColor
                                      : null),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(getSongDuration(song.duration),
                            style: Theme.of(context).textTheme.subtitle2),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (song.isFavorite) {
                        Provider.of<DBProvider>(context, listen: false)
                            .updateSong(song.copyWith(isFavorite: false));

                        //* Favorite playlist has id:0
                        Provider.of<DBProvider>(context, listen: false)
                            .deletePlaylistSong(0, song.id!);

                        if (playingItem?.album == '-2') {
                          AudioService.updateMediaItem(
                              song.copyWith(isFavorite: false).toMediaItem());
                        }
                      } else {
                        Provider.of<DBProvider>(context, listen: false)
                            .updateSong(song.copyWith(isFavorite: true));
                        Provider.of<DBProvider>(context, listen: false)
                            .savePlaylistSongs(
                          0,
                          [PlaylistSong(null, 0, song.id!)],
                        );
                        if (playingItem?.album == '0') {
                          AudioService.addQueueItem(
                            song
                                .toMediaItem(playlistTitle: 'Favorites')
                                .copyWith(album: '0'),
                          );
                        }
                        if (playingItem?.album == '-2') {
                          AudioService.updateMediaItem(
                            song.copyWith(isFavorite: true).toMediaItem(),
                          );
                        }
                      }
                    },
                    icon: Icon(song.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border),
                  ),
                  // _buildWidgetMenuButton(song, context),
                  songMenuButton(song, context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
