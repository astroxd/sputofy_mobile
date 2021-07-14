import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sputofy_2/screens/MiniPlayerScreen/mini_player.dart';
import 'package:sputofy_2/screens/SongDetailScreen/components/top_bar.dart';

import 'components/bottom_actions.dart';
import 'components/media_actions.dart';
import 'components/seek_bar.dart';
import 'components/song_info.dart';

class SongDetailScreen extends StatelessWidget {
  const SongDetailScreen({Key? key}) : super(key: key);

  Stream<CurrentPlayingMediaItem> get _playingMediaItemStream =>
      Rx.combineLatest3<MediaItem?, Duration, PlaybackState,
              CurrentPlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          AudioService.playbackStateStream,
          (mediaItem, position, playbackState) =>
              CurrentPlayingMediaItem(mediaItem, position, playbackState));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<CurrentPlayingMediaItem>(
        stream: _playingMediaItemStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final playingMediaItem = snapshot.data;
          MediaItem playingItem = playingMediaItem!.playingItem!;
          Duration? position =
              playingMediaItem.position ?? Duration(seconds: 1);
          PlaybackState? playbackState = playingMediaItem.playbackState;
          Duration duration = playingItem.duration ?? Duration(seconds: 1);

          AudioServiceShuffleMode shuffleMode =
              playbackState?.shuffleMode ?? AudioServiceShuffleMode.none;
          AudioServiceRepeatMode repeatMode =
              playbackState?.repeatMode ?? AudioServiceRepeatMode.none;

          Uri? cover = playingItem.artUri;

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              int senstivity = 24;
              if (details.delta.dx > senstivity) {
                AudioService.skipToPrevious();
              } else if (details.delta.dx < -senstivity) {
                AudioService.skipToNext();
              }
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: <Widget>[
                    topBar(
                      context,
                      playingItem,
                    ),
                    SizedBox(height: 32.0),
                    songDescription(
                      context,
                      cover,
                      playingItem,
                    ),
                    Spacer(),
                    mediaActions(playbackState),
                    SizedBox(height: 32.0),
                    SeekBar(
                      duration: duration,
                      position: position,
                      onChangeEnd: (newPosition) {
                        AudioService.seekTo(newPosition);
                      },
                    ),
                    SizedBox(height: 32.0),
                    bottomActions(
                      context,
                      repeatMode,
                      shuffleMode,
                      position,
                      duration,
                    ),
                    SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
