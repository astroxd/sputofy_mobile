import 'package:flutter/material.dart';
import 'package:sputofy_2/theme/palette.dart';
import 'package:audio_service/audio_service.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
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
      body: FutureBuilder<List<Song>>(
        future: Provider.of<DBProvider>(context).songs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          List<Song> songs = snapshot.data ?? [];
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
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ActionButtons(context, songs, playingItem, playbackState),
                    SizedBox(height: 16.0),
                    ListSongs(context, songs, playingItem),
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

class PlayingMediaItem {
  MediaItem? playingItem;
  PlaybackState playbackState;

  PlayingMediaItem(this.playingItem, this.playbackState);
}

Future<void> loadQueue(List<Song> songs, {String? songPath}) async {
  if (songs.isEmpty) return;
  List<MediaItem> mediaItems = [];
  for (Song song in songs) {
    mediaItems.add(song.toMediaItem());
    // mediaItems.add(song.toMediaItem().copyWith(album: '${-2}'));
  }
  await AudioService.customAction('setPlaylistID', -2); //TODO maybe useless
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
