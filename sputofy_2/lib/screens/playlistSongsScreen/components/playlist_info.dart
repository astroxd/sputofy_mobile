import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'package:sputofy_2/components/load_queue.dart';
import 'package:sputofy_2/components/playlist_menu_button.dart';

import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';

import 'package:sputofy_2/screens/selectSongsScreen/select_songs_screen.dart';

import 'package:sputofy_2/theme/palette.dart';

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
        _buildWidgetPlaylistDescription(playingItem, playlistSongs),
        _buildWidgetShuffleButton(playlist, playingItem, playlistSongs),
      ],
    );
  }
}

class _buildWidgetTopBar extends StatelessWidget {
  final Playlist playlist;
  const _buildWidgetTopBar(this.playlist, {Key? key}) : super(key: key);

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
        playlistMenuButton(playlist, context, true),
      ],
    );
  }
}

class _buildWidgetPlaylistDescription extends StatelessWidget {
  final MediaItem? playingItem;
  final List<Song> playlistSongs;
  const _buildWidgetPlaylistDescription(this.playingItem, this.playlistSongs,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DBProvider>(
      builder: (context, database, child) {
        Playlist playlist = database.watchingPlaylist!;
        Uint8List? playlistCover = playlist.cover;
        return Container(
          padding: const EdgeInsets.only(right: 16.0),
          height: 150,
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios),
              ),
              if (playlistCover != null) ...[
                Image.memory(
                  playlistCover,
                  width: 150,
                  height: 150,
                ),
              ] else ...[
                Image.asset(
                  'missing_image.png',
                  width: 150,
                  height: 150,
                ),
              ],
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
                              if (playlistSongs.isEmpty) return;

                              if (playingItem?.album != '${playlist.id}') {
                                loadQueue(playlist.id!, playlistSongs,
                                    songPath: playlistSongs[0].path,
                                    playlistTitle: playlist.name);
                              }
                              await AudioService.skipToQueueItem(
                                      playlistSongs[0].path)
                                  .then((value) async =>
                                      await AudioService.play());
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
                                    playingItem?.album == '${playlist.id}') {
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
      },
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
                  loadQueue(playlist.id!, playlistSongs,
                          playlistTitle: playlist.name)
                      .then((value) async =>
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
              "${playlistSongs.length} SONGS, ${_getPlaylistLength(playlistSongs)}",
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
