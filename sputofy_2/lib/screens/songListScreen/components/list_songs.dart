import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/theme/palette.dart';
import 'package:share_plus/share_plus.dart';

import '../song_list_screen.dart';

class ListSongs extends StatelessWidget {
  final BuildContext context;
  final List<Song> songs;
  final MediaItem? playingItem;
  ListSongs(this.context, this.songs, this.playingItem);

  @override
  Widget build(BuildContext context) {
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
                await loadQueue(songs, songPath: song.path);
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
                    // "${index + 1}",
                    "${song.id}",
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
                        Text(_getSongDuration(song.duration),
                            style: Theme.of(context).textTheme.subtitle2),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (song.isFavorite) {
                        Provider.of<DBProvider>(context, listen: false)
                            .updateSong(song.copyWith(isFavorite: false));
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
                              song.toMediaItem().copyWith(album: '0'));
                        }
                        if (playingItem?.album == '-2') {
                          AudioService.updateMediaItem(
                              song.copyWith(isFavorite: true).toMediaItem());
                        }
                      }

                      //TODO
                      //* add isFavorite field to song model
                      //* can't use updateMediaItem because i need to create favorite playlist

                      // AudioService.updateMediaItem(song.toMediaItem());
                    },
                    icon: Icon(song.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border),
                  ),
                  _buildWidgetMenuButton(song),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSongDuration(Duration? songDuration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitSeconds = twoDigits(songDuration!.inSeconds.remainder(60));
    return "${songDuration.inMinutes}:$twoDigitSeconds";
  }

  Widget _buildWidgetMenuButton(Song song) {
    return PopupMenuButton<List>(
      onSelected: _handleClick,
      icon: Icon(Icons.more_horiz),
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        return {'Delete Song', 'Share Song'}.map((String choice) {
          return PopupMenuItem<List>(
            value: [choice, song],
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  void _handleClick(List params) {
    //* params = [choice, song]
    switch (params[0]) {
      case 'Delete Song':
        _deleteSong(params[1]);
        break;
      case 'Share Song':
        Share.shareFiles([params[1].path]);
        break;
    }
  }

  void _deleteSong(Song song) {
    if (playingItem?.album == '-2') {
      AudioService.removeQueueItem(song.toMediaItem());
      Provider.of<DBProvider>(context, listen: false).deleteSong(song.id!);
    } else {
      Provider.of<DBProvider>(context, listen: false).deleteSong(song.id!);
    }
  }
}
