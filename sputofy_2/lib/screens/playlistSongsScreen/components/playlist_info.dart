import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/selectSongsScreen/select_songs_screen.dart';
import 'package:sputofy_2/theme/palette.dart';

import '../playlist_songs_screen.dart';

class buildWidgetPlaylistInfo extends StatelessWidget {
  final BuildContext context;
  final Playlist playlist;
  final List<Song> playlistSongs;
  final MediaItem? playingItem;
  const buildWidgetPlaylistInfo(
      this.context, this.playlist, this.playlistSongs, this.playingItem,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildWidgetTopBar(playlist),
        SizedBox(height: 16.0),
        _buildWidgetPlaylistDescription(playlist, playingItem, playlistSongs),
        _buildWidgetShuffleButton(playlist, playingItem, playlistSongs),
      ],
    );
  }
}

class _buildWidgetTopBar extends StatelessWidget {
  final Playlist playlist;
  const _buildWidgetTopBar(this.playlist, {Key? key}) : super(key: key);

  void _handleClick(List params, BuildContext context) {
    //* params = [choice, song]
    switch (params[0]) {
      case 'Delete Playlist':
        Provider.of<DBProvider>(context, listen: false)
            .deletePlaylist(params[1].id);
        Navigator.pop(context);
        break;
    }
  }

  Widget _buildWidgetMenuButton(Playlist playlist, BuildContext context) {
    return PopupMenuButton<List>(
      onSelected: (List params) => _handleClick(params, context),
      icon: Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        return {'Delete Playlist'}.map((String choice) {
          return PopupMenuItem<List>(
            value: [choice, playlist],
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Not implemented yet")));
          },
          icon: Icon(Icons.sort),
          color: kThirdColor,
        ),
        _buildWidgetMenuButton(playlist, context),
      ],
    );
  }
}

class _buildWidgetPlaylistDescription extends StatelessWidget {
  final Playlist playlist;
  final MediaItem? playingItem;
  final List<Song> playlistSongs;
  const _buildWidgetPlaylistDescription(
      this.playlist, this.playingItem, this.playlistSongs,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16.0),
      height: 150,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios),
          ),
          Image.asset(
            'cover.jpeg',
            width: 150,
            height: 150,
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      playlist.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "${playlist.creationDate.year.toString()}-${playlist.creationDate.month.toString().padLeft(2, '0')}-${playlist.creationDate.day.toString().padLeft(2, '0')}",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 16.0),
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: kSecondaryBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          if (playingItem?.album != playlist.id) {
                            loadQueue(playlist, playlistSongs,
                                songPath: playlistSongs[0].path);
                          }
                          await AudioService.skipToQueueItem(
                                  playlistSongs[0].path)
                              .then((value) async => await AudioService.play());
                        },
                        child: Icon(
                          Icons.play_arrow,
                          size: 24.0,
                          color: kThirdColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: kSecondaryBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectSongList(
                                  playlist: playlist,
                                  playlistSongs: playlistSongs),
                            ),
                          ).then((value) {
                            if (value != null &&
                                playingItem?.album == playlist.id) {
                              AudioService.addQueueItems(value);
                            }
                          });
                        },
                        child: Icon(
                          Icons.add,
                          size: 24.0,
                          color: kThirdColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _buildWidgetShuffleButton extends StatelessWidget {
  final Playlist playlist;
  final MediaItem? playingItem;
  final List<Song> playlistSongs;
  const _buildWidgetShuffleButton(
      this.playlist, this.playingItem, this.playlistSongs,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        Divider(
          thickness: 1.0,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 83, 81),
                  Color.fromARGB(255, 231, 38, 113)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // stops: [0.1, 0.9],
              ),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.all(16.0),
              ),
              child: Icon(Icons.shuffle),
              onPressed: () {
                if (playingItem?.album != '${playlist.id}') {
                  loadQueue(playlist, playlistSongs).then((value) async =>
                      await AudioService.customAction('shufflePlay'));
                } else {
                  if (playlistSongs.isNotEmpty) {
                    AudioService.customAction('shufflePlay');
                  }
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            heightFactor: 2.5,
            alignment: Alignment.bottomLeft,
            child: Text(
              "${playlistSongs.length} SONGS ${playlist.id}, ${_getPlaylistLength(playlistSongs)}",
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        )
      ],
    );
  }
}

String _getPlaylistLength(List<Song> playlistSongs) {
  Duration playlistDuration = Duration.zero;
  playlistSongs.forEach((element) => playlistDuration += element.duration!);
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(playlistDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(playlistDuration.inSeconds.remainder(60));
  return "${twoDigits(playlistDuration.inHours)}:$twoDigitMinutes:$twoDigitSeconds HOURS";
}
