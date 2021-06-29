import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/services/audioPlayer.dart';
import 'package:sputofy_2/theme/palette.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({Key? key}) : super(key: key);

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  Stream<PlayingMediaItem> get _playingMediaItemStream =>
      Rx.combineLatest2<MediaItem?, PlaybackState, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (playingItem, playbackState) =>
              PlayingMediaItem(playingItem, playbackState));

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<DBProvider>().songs;
    print(songs);

    return Scaffold(
      body: StreamBuilder<PlayingMediaItem>(
          stream: _playingMediaItemStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            PlayingMediaItem? playingMediaItem = snapshot.data;
            MediaItem? playingItem = playingMediaItem?.playingItem;
            PlaybackState playbackState = playingMediaItem!.playbackState;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _buildActionButtons(context),
                  SizedBox(height: 16.0),
                  _buildListSongs(context, songs, playingItem),
                ],
              ),
            );
          }),
    );
  }
}

class _buildListSongs extends StatelessWidget {
  final BuildContext context;
  final List<Song> songs;
  final MediaItem? playingItem;
  _buildListSongs(this.context, this.songs, this.playingItem);

  // final List<Song> songss = List.generate(
  //     10,
  //     (index) => Song(index, "path", "titleaaa", "author", "cover",
  //         Duration(milliseconds: 300000)));

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          Song song = songs[index];

          return Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: kPrimaryColor))),
            margin: const EdgeInsets.only(left: 16.0),
            child: InkWell(
              onTap: () async {
                if (playingItem?.album != (-2).toString()) {
                  await _loadQueue(songPath: song.path);
                } else {
                  await AudioService.skipToQueueItem(song.path);
                  await AudioService.play();
                }
              },
              child: Column(
                children: <Widget>[
                  SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("${index + 1}",
                              style: Theme.of(context).textTheme.subtitle2),
                          SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                song.title,
                                style: Theme.of(context).textTheme.subtitle1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(_getSongDuration(song.duration),
                                  style: Theme.of(context).textTheme.subtitle2),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () => Provider.of<DBProvider>(context,
                                      listen: false)
                                  .saveSong(Song(null, "path212222", "title",
                                      "author", "cover", Duration.zero)),
                              icon: Icon(Icons.favorite_border),
                            ),
                            GestureDetector(
                              onTapDown: (TapDownDetails details) =>
                                  Provider.of<DBProvider>(context,
                                          listen: false)
                                      .deleteSong(song.id!),
                              child: Icon(Icons.more_horiz),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 12.0),
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

  Future<void> _loadQueue({String? songPath}) async {
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

class _buildActionButtons extends StatelessWidget {
  final BuildContext context;
  _buildActionButtons(this.context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () => print("object"),
            icon: Icon(
              Icons.shuffle,
            ),
            iconSize: 32.0,
          ),
          IconButton(
            onPressed: () => print("object"),
            icon: Icon(
              Icons.repeat,
            ),
            iconSize: 32.0,
          ),
        ],
      ),
    );
  }
}

class PlayingMediaItem {
  MediaItem? playingItem;
  PlaybackState playbackState;

  PlayingMediaItem(this.playingItem, this.playbackState);
}
