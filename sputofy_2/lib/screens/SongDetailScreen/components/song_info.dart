import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

Widget songDescription(
    BuildContext context, Uri? cover, MediaItem playingItem) {
  return Column(
    children: <Widget>[
      if (cover != null) ...[
        Image.network(
          cover.toString(),
          width: 250,
          height: 250,
        ),
      ] else ...[
        Image.asset(
          'cover.jpeg',
          width: 250,
          height: 250,
        ),
      ],
      SizedBox(height: 24.0),
      Text(
        playingItem.title,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 8.0),
      Text(
        playingItem.artist ?? 'Unknown Artist',
        style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 16.0),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
