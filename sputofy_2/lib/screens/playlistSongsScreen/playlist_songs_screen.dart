import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/MiniPlayerScreen/mini_player.dart';
import 'package:sputofy_2/screens/songListScreen/song_list_screen.dart';
import 'package:rxdart/rxdart.dart';

import 'components/playlist_info.dart';
import 'components/playlist_songs_list.dart';

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

            return StreamBuilder<PlayingMediaItem>(
              stream: _playingMediaItemStream,
              builder: (context, snapshot) {
                PlayingMediaItem? playingMediaItem = snapshot.data;
                MediaItem? playingItem = playingMediaItem?.playingItem;
                return Column(
                  children: <Widget>[
                    buildWidgetPlaylistInfo(
                        context, widget.playlist, playlistSongs, playingItem),
                    SizedBox(height: 16.0),
                    buildWidgetPlaylistList(
                        context, widget.playlist, playlistSongs, playingItem),
                    SizedBox(height: 48.0),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomSheet: MiniPlayer(),
    );
  }
}

Future<void> loadQueue(Playlist playlist, List<Song> playlistSongs,
    {String? songPath}) async {
  if (playlistSongs.isEmpty) return;
  List<MediaItem> mediaItems = [];
  print("playlist ID = ${playlist.id}");
  for (Song song in playlistSongs) {
    mediaItems.add(song.toMediaItem().copyWith(album: '${playlist.id}'));
  }

  mediaItems.forEach((element) {
    print(element.album);
  });
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

String getSongDuration(Duration? songDuration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  String twoDigitSeconds = twoDigits(songDuration!.inSeconds.remainder(60));
  return "${songDuration.inMinutes}:$twoDigitSeconds";
}

Widget buildWidgetMenuButton(Playlist playlist, Song song,
    MediaItem? playingItem, BuildContext context) {
  return PopupMenuButton<List>(
    onSelected: (List params) =>
        handleClick(params, playlist, playingItem, context),
    icon: Icon(Icons.more_vert),
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

void handleClick(List params, Playlist playlist, MediaItem? playingItem,
    BuildContext context) {
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
      if (playlist.id! == 0) {
        Provider.of<DBProvider>(context, listen: false)
            .updateSong(params[1].copyWith(isFavorite: false));
      }
      break;
    case 'Share Song':
      Share.shareFiles([params[1].path]);
      break;
  }
}
