import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:sputofy_2/NewAudioPlatyer.dart';
import 'package:sputofy_2/main.dart';
import 'package:sputofy_2/pages/SongDetailPage.dart';
import 'package:sputofy_2/utils/palette.dart';

// void showDialogWindow(BuildContext context) {
//   showBottomSheet(
//     context: context,
//     builder: (context) => MiniPlayer(),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(24.0),
//         topRight: Radius.circular(24.0),
//       ),
//     ),
//     elevation: 1.0,
//   );
// }

class MiniPlayer extends StatefulWidget {
  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Stream get _playingMediaItemStream =>
      Rx.combineLatest3<MediaItem, Duration, PlaybackState, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          AudioService.playbackStateStream,
          (mediaItem, position, playbackState) =>
              PlayingMediaItem(mediaItem, position, playbackState));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayingMediaItem>(
        stream: _playingMediaItemStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final playingMediaItemStream = snapshot.data;
            final mediaItem = playingMediaItemStream.mediaItem;
            final position = playingMediaItemStream.position;
            final playbackState = playingMediaItemStream.playbackState;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DetailMusicPlayer();
                    },
                  ),
                );
              },
              child: Container(
                // height: 80.0,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: testColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SleekCircularSlider(
                      appearance: CircularSliderAppearance(
                        customWidths: CustomSliderWidths(
                          progressBarWidth: 2.5,
                          trackWidth: 2.5,
                          handlerSize: 1.0,
                          shadowWidth: 1.0,
                        ),
                        infoProperties: InfoProperties(modifier: (value) => ''),
                        customColors: CustomSliderColors(
                            trackColor: Color.fromRGBO(229, 229, 229, 1.0),
                            progressBarColor: Colors.black),
                        size: 36.0,
                        angleRange: 360,
                        startAngle: -90.0,
                      ),
                      min: 0.0,
                      max: mediaItem?.duration?.inSeconds?.toDouble() ?? 100.0,
                      initialValue: position?.inSeconds?.toDouble() ?? 0.0,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Now Playing",
                            style: Theme.of(context).textTheme.subtitle2.merge(
                                  TextStyle(color: Colors.black),
                                ),
                          ),
                          Text(
                            mediaItem?.title ?? "Unknown Title",
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    _buildWidgetMediaControl(playbackState),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              height: 0,
            );
          }
        });
  }

  Widget _buildWidgetMediaControl(PlaybackState playbackState) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: AudioService.skipToPrevious,
          child: Icon(
            Icons.skip_previous_rounded,
            size: 36,
          ),
        ),
        GestureDetector(
          onTap: playbackState.playing ? AudioService.pause : AudioService.play,
          child: Icon(
            playbackState.playing
                ? Icons.pause_outlined
                : Icons.play_arrow_rounded,
            size: 36,
          ),
        ),
        GestureDetector(
          onTap: AudioService.skipToNext,
          child: Icon(
            Icons.skip_next_rounded,
            size: 36,
          ),
        ),
      ],
    );
  }
}
