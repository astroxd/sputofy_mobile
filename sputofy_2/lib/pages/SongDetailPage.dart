import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sputofy_2/main.dart';
import 'package:sputofy_2/provider/provider.dart';
import 'package:sputofy_2/utils/CustomSlider.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/palette.dart';

class DetailMusicPlayer extends StatelessWidget {
  Stream get _playingMediaItemStream =>
      Rx.combineLatest3<MediaItem, Duration, PlaybackState, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          AudioService.playbackStateStream,
          (mediaItem, position, playbackState) =>
              PlayingMediaItem(mediaItem, position, playbackState));

  @override
  Widget build(BuildContext context) {
    //TODO implement functions
    void _showPopupMenu(MediaItem playingMediaItem) {
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(16.0, 0.0, 0.0,
            0.0), //position where you want to show the menu on screen
        color: secondaryColor,
        items: [
          PopupMenuItem(
            child: const Text("Share Song"),
            value: '1',
            textStyle: TextStyle(color: accentColor, fontSize: 18),
          ),
          PopupMenuItem(
            child: const Text("Cancel Song"),
            value: '2',
            textStyle: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ],
        elevation: 8.0,
      ).then<void>((String itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          print("1");
        } else if (itemSelected == "2") {
          print(playingMediaItem.extras['id']);
          Provider.of<DBProvider>(context, listen: false).deletePlaylistSong(
              int.parse(playingMediaItem.album), playingMediaItem.extras['id']);
          AudioService.customAction(
            'removeSong',
            playingMediaItem.id,
          );
          AudioService.removeQueueItem(playingMediaItem);

          print("2");
        } else {
          //code here
        }
      });
    }

    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: StreamBuilder<PlayingMediaItem>(
          stream: _playingMediaItemStream,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              final PlayingMediaItem playingMediaItemStream = snapshot.data;
              final MediaItem playingMediaItem =
                  playingMediaItemStream?.mediaItem;
              final Duration position = playingMediaItemStream?.position;
              final Duration duration = playingMediaItem?.duration;
              final PlaybackState playbackState =
                  playingMediaItemStream?.playbackState;

              return Container(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 16.0, bottom: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        _buildWidgetTopBar(
                            context, _showPopupMenu, playingMediaItem),
                        SizedBox(
                          height: 32.0,
                        ),
                        _buildWidgetMediaItemInfo(playingMediaItem),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        _buildWidgetMediaControl(playbackState),
                        SizedBox(
                          height: 24.0,
                        ),
                        SliderTheme(
                          data: CustomTheme,
                          child: Slider(
                            value: position?.inSeconds?.toDouble(),
                            max: duration?.inSeconds?.toDouble(),
                            min: 0.0,
                            onChanged: (double value) {
                              AudioService.seekTo(
                                  Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                        _buildWidgetSpecialMediaControl(
                            playingMediaItem, position, playbackState),
                      ],
                    ),
                  ],
                ),
              );
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildWidgetTopBar(BuildContext context,
      Function(MediaItem) _showPopupMenu, MediaItem playingMediaItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          onTap: Navigator.of(context).pop,
          child: Icon(
            Icons.arrow_back,
            size: 32.0,
            color: accentColor,
          ),
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.volume_down,
              size: 32.0,
            ),
            SizedBox(
              width: 8.0,
            ),
            StreamBuilder(
              stream: AudioService.customEventStream,
              initialData: 1.0,
              builder: (context, snapshot) {
                return SliderTheme(
                  data: CustomTheme,
                  child: Slider(
                    value: snapshot.data,
                    max: 2.0,
                    min: 0.0,
                    onChanged: (double value) {
                      AudioService.customAction("setVolume", value);
                    },
                  ),
                );
              },
            ),
            SizedBox(
              width: 8.0,
            ),
            Icon(
              Icons.volume_up,
              size: 32.0,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            _showPopupMenu(playingMediaItem);
          },
          child: Icon(
            Icons.more_vert,
            size: 32.0,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetMediaItemInfo(MediaItem playingMediaItem) {
    String cover = playingMediaItem?.artUri;
    String title = playingMediaItem?.title ?? "Unknown Title";
    String artist = playingMediaItem?.album ?? "Unknown Artist";
    return Column(
      children: <Widget>[
        ClipRRect(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300.0),
            child: cover != null
                ? Image.network(cover)
                : Image.asset("cover.jpeg"),
          ),
        ),
        SizedBox(
          height: 16.0,
        ),
        SizedBox(
          height: 62.0,
          child: Text(
            title,
            // "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
            style: TextStyle(color: accentColor, fontSize: 18),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
        SizedBox(
          height: 16.0,
        ),
        Text(
          artist,
          style: TextStyle(color: secondaryColor, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildWidgetMediaControl(PlaybackState playbackState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: AudioService.skipToPrevious,
          child: Icon(
            Icons.skip_previous,
            size: 64,
          ),
        ),
        SizedBox(
          width: 24.0,
        ),
        GestureDetector(
          onTap: playbackState.playing ? AudioService.pause : AudioService.play,
          child: Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: Icon(
              playbackState.playing ? Icons.pause : Icons.play_arrow,
              size: 64,
              color: accentColor,
            ),
          ),
        ),
        SizedBox(
          width: 24.0,
        ),
        GestureDetector(
          onTap: AudioService.skipToNext,
          child: Icon(
            Icons.skip_next,
            size: 64,
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetSpecialMediaControl(MediaItem playingMediaItem,
      Duration position, PlaybackState playbackState) {
    Duration duration = playingMediaItem.duration;
    AudioServiceShuffleMode shuffleMode = playbackState.shuffleMode;
    AudioServiceRepeatMode repeatMode = playbackState.repeatMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          onTap: () {
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
          child: _getRepeatIcon(repeatMode),
        ),
        Row(
          children: <Widget>[
            Text(
              getStrPosition(position),
              style: TextStyle(color: accentColor, fontSize: 32),
            ),
            SizedBox(
              width: 3.0,
            ),
            Text(
              "|",
              style: TextStyle(color: secondaryColor, fontSize: 32),
            ),
            SizedBox(
              width: 3.0,
            ),
            Text(
              getStrPosition(duration),
              style: TextStyle(color: secondaryColor, fontSize: 32),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            print(shuffleMode);
            shuffleMode == AudioServiceShuffleMode.all
                ? AudioService.setShuffleMode(AudioServiceShuffleMode.none)
                : AudioService.setShuffleMode(AudioServiceShuffleMode.all);
          },
          child: Icon(
            Icons.shuffle,
            color: shuffleMode == AudioServiceShuffleMode.all
                ? accentColor
                : Colors.black,
            size: 32,
          ),
        ),
      ],
    );
  }

  // ignore: missing_return
  Icon _getRepeatIcon(AudioServiceRepeatMode repeatMode) {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        return Icon(Icons.repeat, size: 32);
        break;
      case AudioServiceRepeatMode.one:
        return Icon(Icons.repeat_one, size: 32, color: accentColor);
        break;
      case AudioServiceRepeatMode.all:
        return Icon(Icons.repeat, size: 32, color: accentColor);
        break;
      case AudioServiceRepeatMode.group:
        break;
    }
  }
}

//TODO magari ti sposto nel file del player
String getStrPosition(Duration position) {
  String strPosition = '00:00';
  int positionMinute = position.inSeconds ~/ 60;
  int positionSecond =
      positionMinute > 0 ? position.inSeconds % 60 : position.inSeconds;
  return strPosition =
      (positionMinute < 10 ? '$positionMinute' : '$positionMinute') +
          ':' +
          (positionSecond < 10 ? '0$positionSecond' : '$positionSecond');
}
