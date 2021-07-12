import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sputofy_2/providers/provider.dart';
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
    void _handleClick(List params) async {
      //* params = [choice, mediaItem]
      MediaItem mediaItem = params[1];
      switch (params[0]) {
        case 'Delete Song':
          if (mediaItem.album == '-2') {
            Provider.of<DBProvider>(context, listen: false)
                .deleteSong(mediaItem.extras?['id']);
          } else {
            Provider.of<DBProvider>(context, listen: false).deletePlaylistSong(
                int.parse(mediaItem.album), mediaItem.extras?['id']);
            await AudioService.removeQueueItem(mediaItem);
          }
          Navigator.pop(context);
          break;
      }
    }

    Widget _buildWidgetMenuButton(MediaItem? mediaItem) {
      return PopupMenuButton<List>(
        onSelected: _handleClick,
        icon: Icon(Icons.more_vert),
        padding: EdgeInsets.zero,
        itemBuilder: (context) {
          return {'Delete Song'}.map((String choice) {
            return PopupMenuItem<List>(
              value: [choice, mediaItem],
              child: Text(choice),
            );
          }).toList();
        },
      );
    }

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

          AudioServiceShuffleMode shuffleMode =
              playbackState?.shuffleMode ?? AudioServiceShuffleMode.none;
          AudioServiceRepeatMode repeatMode =
              playbackState?.repeatMode ?? AudioServiceRepeatMode.none;

          Uri? cover = playingItem?.artUri;

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
                        _buildWidgetMenuButton(playingItem),
                      ],
                    ),
                    SizedBox(height: 32.0),
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
                          icon: Icon(Icons.fast_forward),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.0),
                    SeekBar(
                      duration: duration,
                      position: position,
                      onChangeEnd: (newPosition) {
                        AudioService.seekTo(newPosition);
                      },
                    ),
                    SizedBox(height: 32.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            switch (repeatMode) {
                              case AudioServiceRepeatMode.none:
                                AudioService.setRepeatMode(
                                    AudioServiceRepeatMode.one);
                                break;
                              case AudioServiceRepeatMode.one:
                                AudioService.setRepeatMode(
                                    AudioServiceRepeatMode.all);
                                break;
                              case AudioServiceRepeatMode.all:
                                AudioService.setRepeatMode(
                                    AudioServiceRepeatMode.none);
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
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontSize: 16.0),
                            ),
                            TextSpan(
                              text: getStrPosition(duration),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontSize: 16.0),
                            ),
                          ]),
                        ),
                        IconButton(
                          onPressed: () {
                            shuffleMode == AudioServiceShuffleMode.all
                                ? AudioService.setShuffleMode(
                                    AudioServiceShuffleMode.none)
                                : AudioService.setShuffleMode(
                                    AudioServiceShuffleMode.all);
                          },
                          icon: Icon(
                            Icons.shuffle,
                            color: shuffleMode == AudioServiceShuffleMode.all
                                ? kAccentColor
                                : null,
                            size: 32,
                          ),
                        ),
                      ],
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
    // String strPosition = '00:00';
    // int positionMinute = position.inSeconds ~/ 60;
    // int positionSecond =
    //     positionMinute > 0 ? position.inSeconds % 60 : position.inSeconds;
    // return strPosition =
    //     (positionMinute < 10 ? '$positionMinute' : '$positionMinute') +
    //         ':' +
    //         (positionSecond < 10 ? '0$positionSecond' : '$positionSecond');
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitSeconds = twoDigits(position.inSeconds.remainder(60));
    return "${position.inMinutes}:$twoDigitSeconds";
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final value = min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
        widget.duration.inMilliseconds.toDouble());
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        Slider(
          activeColor: kAccentColor,
          inactiveColor: kPrimaryColor,
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: value,
          onChanged: (value) {
            if (!_dragging) {
              _dragging = true;
            }
            setState(() {
              _dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd!(Duration(milliseconds: value.round()));
            }
            _dragging = false;
          },
        ),
      ],
    );
  }
}
