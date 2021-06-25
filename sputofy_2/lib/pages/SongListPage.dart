import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';
import 'package:sputofy_2/provider/provider.dart';
import 'package:sputofy_2/utils/palette.dart';
import 'package:rxdart/rxdart.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  Stream<PlayingMediaItem> get _playingMediaItemStream =>
      Rx.combineLatest2<MediaItem, PlaybackState, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (mediaItem, playbackState) =>
              PlayingMediaItem(mediaItem, playbackState));
  @override
  Widget build(BuildContext context) {
    Provider.of<DBProvider>(context, listen: false).getSongs();

    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        children: <Widget>[
          _buildWidgetButtonController(context),
          SizedBox(height: 8.0),
          _buildWidgetSongList(),
          SizedBox(height: 50.0)
        ],
      ),
      bottomSheet: MiniPlayer(),
    );
  }

  Widget _buildWidgetButtonController(BuildContext context) {
    return StreamBuilder<PlayingMediaItem>(
      stream: _playingMediaItemStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isPlaying = snapshot?.data?.playbackState?.playing;
          final playingItem = snapshot?.data?.playingItem;
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        if (playingItem.album != (-2).toString()) {
                          List<Song> songs = await Provider.of<DBProvider>(
                                  context,
                                  listen: false)
                              .songs;

                          _loadQueue(songs);
                        }

                        AudioService.customAction('shufflePlay');
                        if (!isPlaying) await AudioService.play();
                      },
                      child: Icon(
                        AppIcon.shuffle,
                        color: accentColor,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Icons.repeat,
                      size: 28,
                      color: accentColor,
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.arrow_downward,
                      size: 28,
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Icons.thumbs_up_down_sharp,
                      size: 28,
                    ),
                    SizedBox(width: 8.0),
                    GestureDetector(
                      child: Icon(
                        Icons.create_new_folder_outlined,
                        size: 28,
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildWidgetSongList() {
    return Expanded(
      child: FutureBuilder(
        future: Provider.of<DBProvider>(context).songs,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Song> songs = snapshot.data;
            return StreamBuilder<MediaItem>(
                stream: AudioService.currentMediaItemStream,
                builder: (context, snapshot) {
                  MediaItem playingSong = snapshot?.data;
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.black,
                    ),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      Song song = songs[index];
                      return GestureDetector(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () async {
                                if (playingSong?.album != (-2).toString()) {
                                  await _loadQueue(songs, songPath: song.path);
                                } else {
                                  await AudioService.skipToQueueItem(song.path);
                                  await AudioService.play();
                                }
                              },
                              title: Text(
                                "${song.title}",
                                style: TextStyle(
                                    color: song.path == playingSong?.id ?? ''
                                        ? accentColor
                                        : Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                "${_getSongDuration(song.duration)}",
                                style: TextStyle(color: secondaryColor),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.favorite_border,
                                    size: 30.0,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 12.0),
                                  Icon(
                                    Icons.more_vert,
                                    size: 30.0,
                                    color: accentColor,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  String _getSongDuration(Duration songDuration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitSeconds = twoDigits(songDuration.inSeconds.remainder(60));
    return "${songDuration.inMinutes}:$twoDigitSeconds";
  }

  Future<void> _loadQueue(List<Song> songs, {String songPath}) async {
    if (songs.isEmpty) return;
    List<Map> mapSongs = [];
    for (Song song in songs) {
      mapSongs.add(song.toMap());
    }

    await AudioService.customAction('setPlaylistID', -2);
    await AudioService.customAction('loadPlaylist', mapSongs).then((value) => {
          if (songPath != null)
            {
              AudioService.skipToQueueItem(songPath)
                  .then((value) async => await AudioService.play())
            }
        });
  }
}

class PlayingMediaItem {
  MediaItem playingItem;
  PlaybackState playbackState;
  PlayingMediaItem(this.playingItem, this.playbackState);
}
