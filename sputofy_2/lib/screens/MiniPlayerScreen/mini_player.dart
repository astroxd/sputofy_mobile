import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sputofy_2/screens/SongDetailScreen/song_detail_screen.dart';
import 'package:sputofy_2/theme/palette.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);
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
    return StreamBuilder<CurrentPlayingMediaItem>(
      stream: _playingMediaItemStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container(height: 0.0);

        final playingMediaItem = snapshot.data;
        MediaItem? playingItem = playingMediaItem?.playingItem;
        Duration? position = playingMediaItem?.position ?? Duration(seconds: 1);
        PlaybackState? playbackState = playingMediaItem?.playbackState;
        Duration duration = playingItem?.duration ?? Duration(seconds: 1);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongDetailScreen(),
              ),
            );
          },
          child: Container(
            color: kBackgroundColor.withOpacity(0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
                  minHeight: 3.0,
                  backgroundColor: Colors.transparent,
                  value: position.inSeconds / duration.inSeconds,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: kSecondaryBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            playbackState?.playing ?? false
                                ? await AudioService.pause()
                                : await AudioService.play();
                          },
                          child: Icon(
                            playbackState?.playing ?? false
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 24.0,
                            color: kThirdColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              playingItem?.title ?? 'Unknown Title',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(fontSize: 14.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              playingItem?.artist ?? 'Unkwon Artist',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurrentPlayingMediaItem {
  MediaItem? playingItem;
  Duration? position;
  PlaybackState? playbackState;
  CurrentPlayingMediaItem(this.playingItem, this.position, this.playbackState);
}