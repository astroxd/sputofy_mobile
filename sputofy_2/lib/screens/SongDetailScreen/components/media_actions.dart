import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sputofy_2/theme/palette.dart';

Widget mediaActions(PlaybackState? playbackState) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      IconButton(
        color: kThirdColor,
        iconSize: 36,
        onPressed: () {
          AudioService.skipToPrevious();
        },
        icon: Icon(Icons.fast_rewind),
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 83, 81),
              Color.fromARGB(255, 231, 38, 113)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: kAccentColor.withOpacity(0.2),
              spreadRadius: 8.0,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            primary: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.all(16.0),
          ),
          child: Icon(
            playbackState?.playing ?? false ? Icons.pause : Icons.play_arrow,
            size: 32.0,
          ),
          onPressed: () async {
            playbackState?.playing ?? false
                ? await AudioService.pause()
                : await AudioService.play();
          },
        ),
      ),
      IconButton(
        iconSize: 36,
        color: kThirdColor,
        onPressed: () {
          AudioService.skipToNext();
        },
        icon: Icon(Icons.fast_forward),
      ),
    ],
  );
}
