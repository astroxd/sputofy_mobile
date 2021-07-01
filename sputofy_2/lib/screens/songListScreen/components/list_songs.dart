import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/theme/palette.dart';

import '../song_list_screen.dart';

class ListSongs extends StatelessWidget {
  final BuildContext context;
  final List<Song> songs;
  final MediaItem? playingItem;
  ListSongs(this.context, this.songs, this.playingItem);

  final List<Song> songss = List.generate(
      10,
      (index) => Song(index, "path", "titlaaaaaaaaaaaaaaaaaaaaaaaaaaaaeaaa",
          "author", "cover", Duration(milliseconds: 300000)));

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
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
                  border: Border(bottom: BorderSide(color: kPrimaryColor))),
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
                      //TODO
                      //* add isFavorite field to song model
                      //* can't use updateMediaItem because i need to create favorite playlist

                      // AudioService.updateMediaItem(song.toMediaItem());
                    },
                    icon: Icon(Icons.favorite_border),
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
        return {'Delete Song'}.map((String choice) {
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