import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';

import 'package:audio_service/audio_service.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'components/action_buttons.dart';
import 'components/list_songs.dart';

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
    return Scaffold(
      body: Consumer<DBProvider>(
        builder: (context, database, child) {
          List<Song> songs = database.songs;

          return StreamBuilder<PlayingMediaItem>(
            stream: _playingMediaItemStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              PlayingMediaItem? playingMediaItem = snapshot.data;
              MediaItem? playingItem = playingMediaItem?.playingItem;
              PlaybackState playbackState = playingMediaItem!.playbackState;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: <Widget>[
                    ActionButtons(context, songs, playingItem, playbackState),
                    SizedBox(height: 16.0),
                    ListSongs(context, songs, playingItem),
                    SizedBox(height: 48.0),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

//TODO move to audioPlayer class
class PlayingMediaItem {
  MediaItem? playingItem;
  PlaybackState playbackState;

  PlayingMediaItem(this.playingItem, this.playbackState);
}
