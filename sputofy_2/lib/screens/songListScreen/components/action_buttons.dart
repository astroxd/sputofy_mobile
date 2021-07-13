import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/theme/palette.dart';

import '../../../main.dart';
import '../song_list_screen.dart';

class ActionButtons extends StatelessWidget {
  final BuildContext context;
  final List<Song> songs;
  final MediaItem? playingItem;
  final PlaybackState playbackState;
  ActionButtons(this.context, this.songs, this.playingItem, this.playbackState);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () async {
              if (playingItem?.album != "-2") {
                loadQueue(-2, songs);
              }
              AudioService.customAction('shufflePlay');
            },
            icon: Icon(
              Icons.shuffle,
            ),
            iconSize: 32.0,
          ),
          IconButton(
            color: playbackState.repeatMode == AudioServiceRepeatMode.all
                ? kAccentColor
                : null,
            onPressed: () async {
              if (songs.isEmpty) return;
              if (playingItem?.album != "-2") {
                loadQueue(-2, songs, songPath: songs[0].path);
              }
              if (playbackState.repeatMode == AudioServiceRepeatMode.none) {
                AudioService.setRepeatMode(AudioServiceRepeatMode.all);
                if (!playbackState.playing) await AudioService.play();
              } else {
                AudioService.setRepeatMode(AudioServiceRepeatMode.none);
                if (!playbackState.playing) await AudioService.play();
              }
            },
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
