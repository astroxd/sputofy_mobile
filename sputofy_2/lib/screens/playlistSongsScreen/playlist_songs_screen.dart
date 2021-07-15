import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                      context,
                      widget.playlist,
                      playlistSongs,
                      playingItem,
                    ),
                    SizedBox(height: 16.0),
                    buildWidgetPlaylistList(
                      context,
                      widget.playlist,
                      playlistSongs,
                      playingItem,
                    ),
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
