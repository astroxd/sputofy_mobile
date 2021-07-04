import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/selectSongsScreen/select_songs_screen.dart';
import 'package:sputofy_2/screens/songListScreen/song_list_screen.dart';
import 'package:sputofy_2/theme/palette.dart';
import 'package:rxdart/rxdart.dart';

class PlaylistSongsScreen extends StatefulWidget {
  final Playlist playlist;
  const PlaylistSongsScreen(this.playlist, {Key? key}) : super(key: key);

  @override
  _PlaylistSongsScreenState createState() => _PlaylistSongsScreenState();
}

class _PlaylistSongsScreenState extends State<PlaylistSongsScreen> {
  Stream<PlayingMediaItem> get _playingMediaItemStream =>
      Rx.combineLatest2<MediaItem?, PlaybackState, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (playingItem, playbackState) =>
              PlayingMediaItem(playingItem, playbackState));
  @override
  void initState() {
    Provider.of<DBProvider>(context, listen: false)
        .getPlaylistSongs(widget.playlist.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DBProvider>(
          builder: (context, database, child) {
            List<Song> playlistSongs = database.playlistSongs;
            print("playlistSongs $playlistSongs");
            return StreamBuilder<PlayingMediaItem>(
                stream: _playingMediaItemStream,
                builder: (context, snapshot) {
                  PlayingMediaItem? playingMediaItem = snapshot.data;
                  MediaItem? playingItem = playingMediaItem?.playingItem;
                  // PlaybackState playbackState = playingMediaItem!.playbackState;
                  return Column(
                    children: <Widget>[
                      _buildWidgetPlaylistInfo(
                          context, widget.playlist, playlistSongs, playingItem),
                      _buildWidgetPlaylistList(
                          context, widget.playlist, playlistSongs, playingItem),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}

class _buildWidgetPlaylistInfo extends StatelessWidget {
  final BuildContext context;
  final Playlist playlist;
  final List<Song> playlistSongs;
  final MediaItem? playingItem;
  const _buildWidgetPlaylistInfo(
      this.context, this.playlist, this.playlistSongs, this.playingItem,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildWidgetTopBar(context),
        SizedBox(height: 16.0),
        _buildWidgetPlaylistDescription(context, playlist, playingItem),
        Stack(
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
                    if (playingItem?.album != playlist.id) {
                      loadQueue(playlist, playlistSongs);
                    }
                    if (playlistSongs.isNotEmpty) {
                      AudioService.customAction('shufflePlay');
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
        )
      ],
    );
  }

  String _getPlaylistLength(List<Song> playlistSongs) {
    Duration playlistDuration = Duration.zero;
    playlistSongs.forEach((element) => playlistDuration += element.duration!);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes =
        twoDigits(playlistDuration.inMinutes.remainder(60));
    String twoDigitSeconds =
        twoDigits(playlistDuration.inSeconds.remainder(60));
    return "${twoDigits(playlistDuration.inHours)}:$twoDigitMinutes:$twoDigitSeconds HOURS";
  }

  Widget _buildWidgetTopBar(BuildContext context) {
    void _handleClick(List params) {
      //* params = [choice, song]
      switch (params[0]) {
        case 'Delete Playlist':
          Provider.of<DBProvider>(context, listen: false)
              .deletePlaylist(playlist.id!);
          Navigator.pop(context);
          break;
      }
    }

    Widget _buildWidgetMenuButton(Playlist playlist) {
      return PopupMenuButton<List>(
        onSelected: _handleClick,
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
        _buildWidgetMenuButton(playlist),
      ],
    );
  }

  Widget _buildWidgetPlaylistDescription(
      BuildContext context, Playlist playlist, MediaItem? playingItem) {
    return Container(
      padding: const EdgeInsets.only(right: 16.0),
      height: 150,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios),
            //Icon(Icons.chevron_left),
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
                                  playlistID: playlist.id!,
                                  playlistSongs: playlistSongs),
                            ),
                          ).then((value) {
                            if (value.isNotEmpty &&
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

class _buildWidgetPlaylistList extends StatelessWidget {
  final BuildContext context;
  final Playlist playlist;
  final List<Song> songs;
  final MediaItem? playingItem;

  const _buildWidgetPlaylistList(
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
          return InkWell(
            onTap: () async {
              if (playingItem?.album != playlist.id) {
                await loadQueue(playlist, songs, songPath: song.path);
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
                            color: playingItem?.id == song.path
                                ? kAccentColor
                                : null,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    _getSongDuration(song.duration),
                    style: Theme.of(context).textTheme.subtitle2,
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
      icon: Icon(Icons.more_vert),
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
        if (playingItem?.album == '${playlist.id}') {
          AudioService.removeQueueItem(params[1].toMediaItem());
          Provider.of<DBProvider>(context, listen: false)
              .deletePlaylistSong(playlist.id!, params[1].id!);
        } else {
          Provider.of<DBProvider>(context, listen: false)
              .deletePlaylistSong(playlist.id!, params[1].id!);
        }
        break;
    }
  }
}

Future<void> loadQueue(Playlist playlist, List<Song> playlistSongs,
    {String? songPath}) async {
  if (playlistSongs.isEmpty) return;
  List<MediaItem> mediaItems = [];
  for (Song song in playlistSongs) {
    mediaItems.add(song.toMediaItem().copyWith(album: '${playlist.id}'));
  }
  await AudioService.updateQueue(mediaItems).then(
    (value) => {
      if (songPath != null)
        {
          AudioService.skipToQueueItem(songPath)
              .then((value) async => await AudioService.play())
        }
    },
  );
}
