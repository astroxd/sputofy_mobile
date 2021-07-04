import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sputofy_2/screens/MiniPlayerScreen/mini_player.dart';
import 'package:sputofy_2/theme/palette.dart';

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
          MediaItem? playingItem = playingMediaItem?.playingItem;
          Duration? position =
              playingMediaItem?.position ?? Duration(seconds: 1);
          PlaybackState? playbackState = playingMediaItem?.playbackState;
          Duration duration = playingItem?.duration ?? Duration(seconds: 1);
          return SafeArea(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: kSecondaryBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 24.0,
                            color: kThirdColor,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert),
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                Image.asset(
                  'cover.jpeg',
                  width: 250,
                  height: 250,
                ),
                SizedBox(height: 24.0),
                Column(
                  children: <Widget>[
                    Text(
                      playingItem?.title ?? 'Unkwown Title',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      playingItem?.artist ?? 'Unknown Artist',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Spacer(),
                // SizedBox(height: 48.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      color: kThirdColor,
                      iconSize: 36,
                      onPressed: () {
                        AudioService.skipToPrevious();
                      },
                      icon: Icon(Icons.skip_previous_sharp),
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
                          playbackState?.playing ?? false
                              ? Icons.pause
                              : Icons.play_arrow,
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
                      icon: Icon(Icons.skip_next_sharp),
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                //TODO copy example
                Slider.adaptive(
                  activeColor: kAccentColor,
                  inactiveColor: kPrimaryColor,
                  value: position.inSeconds.toDouble(),
                  onChanged: (double value) {
                    AudioService.seekTo(Duration(seconds: value.round()));
                  },
                  max: duration.inSeconds.toDouble(),
                  min: 0,
                ),
                SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.repeat),
                    ),
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: "${position.inSeconds}",
                            style: Theme.of(context).textTheme.subtitle1),
                        TextSpan(
                          text: '|',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontSize: 16.0),
                        ),
                        TextSpan(
                          text: "${duration.inSeconds}",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontSize: 16.0),
                        ),
                      ]),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.shuffle),
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
              ],
            ),
          );
        },
      ),
    );
  }
}
