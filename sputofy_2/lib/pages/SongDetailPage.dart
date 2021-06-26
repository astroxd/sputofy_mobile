import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sputofy_2/main.dart';
import 'package:sputofy_2/provider/provider.dart';
import 'package:sputofy_2/utils/CustomSlider.dart';
import 'package:sputofy_2/utils/palette.dart';

class DetailMusicPlayer extends StatelessWidget {
  Stream get _playingMediaItemStream =>
      Rx.combineLatest3<MediaItem?, Duration, PlaybackState, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          AudioService.playbackStateStream,
          (mediaItem, position, playbackState) =>
              PlayingMediaItem(mediaItem, position, playbackState));

  @override
  Widget build(BuildContext context) {
    void _showPopupMenu(MediaItem playingMediaItem) {
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(16.0, 0.0, 0.0,
            0.0), //position where you want to show the menu on screen
        color: secondaryColor,
        items: [
          PopupMenuItem(
            child: const Text("Share Song[WIP]"),
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
      ).then<void>((String? itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          return;
        } else if (itemSelected == "2") {
          Provider.of<DBProvider>(context, listen: false).deletePlaylistSong(
              int.parse(playingMediaItem.album),
              playingMediaItem.extras!['id']);
          AudioService.customAction(
            'removeSong',
            playingMediaItem.id,
          );
          AudioService.removeQueueItem(playingMediaItem);
        } else {
          //code here
        }
      });
    }

    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: StreamBuilder<PlayingMediaItem>(
          stream: _playingMediaItemStream as Stream<PlayingMediaItem>?,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              PlayingMediaItem playingMediaItemStream = snapshot.data!;
              MediaItem playingMediaItem = playingMediaItemStream.mediaItem!;
              Duration position = playingMediaItemStream.position;
              Duration duration = playingMediaItem.duration!;
              PlaybackState playbackState =
                  playingMediaItemStream.playbackState;

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
                            value: position.inSeconds.toDouble(),
                            max: duration.inSeconds.toDouble(),
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
    String? cover = playingMediaItem.artUri?.toString() ?? "";
    String? title = playingMediaItem.title;
    String? artist = playingMediaItem.album;
    return Column(
      children: <Widget>[
        ClipRRect(
          child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300.0),
              child:
                  // Image.asset('cover.jpeg')
                  cover.isNotEmpty
                      ? Image.network(cover)
                      : Image.asset("cover.jpeg")), //TODO maybe crash
        ),
        SizedBox(
          height: 16.0,
        ),
        SizedBox(
          height: 75.0,
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
    Duration duration = playingMediaItem.duration!;
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
    Icon icon = Icon(Icons.error, size: 32);
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        icon = Icon(Icons.repeat, size: 32);
        break;
      case AudioServiceRepeatMode.one:
        icon = Icon(Icons.repeat_one, size: 32, color: accentColor);
        break;
      case AudioServiceRepeatMode.all:
        icon = Icon(Icons.repeat, size: 32, color: accentColor);
        break;
      case AudioServiceRepeatMode.group:
        break;
    }
    return icon;
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
