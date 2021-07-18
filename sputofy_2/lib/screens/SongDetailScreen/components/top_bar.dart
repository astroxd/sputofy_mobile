import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import 'package:sputofy_2/components/song_menu_button.dart';

import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';

import 'package:sputofy_2/theme/palette.dart';

Widget topBar(BuildContext context, MediaItem playingItem) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: kSecondaryBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Column(
            children: <Widget>[
              RotatedBox(
                quarterTurns: 3,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 24.0,
                  color: kThirdColor,
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
      songMenuButton(
        Song.fromMediaItem(playingItem),
        context,
        playlist: Playlist(
          (int.parse(playingItem.album)),
          '',
          null,
          DateTime.now(),
          false,
        ),
        icon: Icons.more_vert,
        shouldPop: true,
      ),
    ],
  );
}
