import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sputofy_2/theme/palette.dart';

Widget bottomActions(
  BuildContext context,
  AudioServiceRepeatMode repeatMode,
  AudioServiceShuffleMode shuffleMode,
  Duration position,
  Duration duration,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      IconButton(
        onPressed: () {
          switch (repeatMode) {
            case AudioServiceRepeatMode.none:
              AudioService.setRepeatMode(AudioServiceRepeatMode.one);
              break;
            case AudioServiceRepeatMode.one:
              AudioService.setRepeatMode(AudioServiceRepeatMode.all);
              break;
            case AudioServiceRepeatMode.all:
              AudioService.setRepeatMode(AudioServiceRepeatMode.none);
              break;
            case AudioServiceRepeatMode.group:
              break;
          }
        },
        icon: _getRepeatIcon(repeatMode),
      ),
      RichText(
        text: TextSpan(children: <TextSpan>[
          TextSpan(
              text: getStrPosition(position),
              style: Theme.of(context).textTheme.subtitle1),
          TextSpan(
            text: '|',
            style:
                Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 16.0),
          ),
          TextSpan(
            text: getStrPosition(duration),
            style:
                Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 16.0),
          ),
        ]),
      ),
      IconButton(
        onPressed: () {
          shuffleMode == AudioServiceShuffleMode.all
              ? AudioService.setShuffleMode(AudioServiceShuffleMode.none)
              : AudioService.setShuffleMode(AudioServiceShuffleMode.all);
        },
        icon: Icon(
          Icons.shuffle,
          color:
              shuffleMode == AudioServiceShuffleMode.all ? kAccentColor : null,
          size: 32,
        ),
      ),
    ],
  );
}

Icon _getRepeatIcon(AudioServiceRepeatMode repeatMode) {
  Icon icon = Icon(Icons.error, size: 32);
  switch (repeatMode) {
    case AudioServiceRepeatMode.none:
      icon = Icon(Icons.repeat, size: 32);
      break;
    case AudioServiceRepeatMode.one:
      icon = Icon(Icons.repeat_one, size: 32, color: kAccentColor);
      break;
    case AudioServiceRepeatMode.all:
      icon = Icon(Icons.repeat, size: 32, color: kAccentColor);
      break;
    case AudioServiceRepeatMode.group:
      break;
  }
  return icon;
}

String getStrPosition(Duration position) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  String twoDigitSeconds = twoDigits(position.inSeconds.remainder(60));
  return "${position.inMinutes}:$twoDigitSeconds";
}
