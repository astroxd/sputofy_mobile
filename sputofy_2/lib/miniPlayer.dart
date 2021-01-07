import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:sputofy_2/model/audioPlayer.dart';

bool isDismissed = true;

void showMiniPlayer(BuildContext context) {
  if (isDismissed) {
    var controller = showBottomSheet(
      context: context,
      builder: (context) {
        return WidgetMiniPlayer();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
    );
    controller.closed.then(
      (value) {
        // Provider.of<MyAudio>(context, listen: false).pauseSong();
        isDismissed = true;
      },
    );
    isDismissed = false;
  }
}

class WidgetMiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return WidgetDetailMusicPlayer();
          },
          isDismissible: false,
          isScrollControlled: true,
        );
      },
      child: Container(
        width: 400.0,
        padding: EdgeInsets.only(
          left: 16.0,
          top: 4.0,
          right: 16.0,
          bottom: 16.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 28.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(99)),
              ),
            ),
            SizedBox(height: 12.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Now Playing",
                        style: Theme.of(context).textTheme.subtitle2.merge(
                              TextStyle(color: Colors.grey),
                            ),
                      ),
                      Consumer<MyAudio>(
                        builder: (context, audioPlayer, child) => Text(
                          '${audioPlayer.songList[audioPlayer.indexSongSelected].title}',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: <Widget>[
                    SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: Consumer<MyAudio>(
                        builder: (context, audioPlayer, child) =>
                            SleekCircularSlider(
                          appearance: CircularSliderAppearance(
                            customWidths: CustomSliderWidths(
                              progressBarWidth: 2.0,
                              trackWidth: 1.0,
                              handlerSize: 1.0,
                              shadowWidth: 1.0,
                            ),
                            infoProperties: InfoProperties(
                              modifier: (value) => '',
                            ),
                            customColors: CustomSliderColors(
                              trackColor: Colors.grey,
                              progressBarColor: Colors.black,
                            ),
                            size: 4.0,
                            angleRange: 360,
                            startAngle: -90.0,
                          ),
                          min: 0.0,
                          max: audioPlayer.songLength.inSeconds.toDouble(),
                          initialValue:
                              audioPlayer.position.inSeconds.toDouble(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: Consumer<MyAudio>(
                        builder: (context, audioPlayer, child) => Icon(
                          audioPlayer.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 20.0,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetDetailMusicPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;
    double paddingBottom = mediaQueryData.padding.bottom;

    return Container(
      width: widthScreen,
      height: heightScreen,
      child: Stack(
        children: <Widget>[
          _buildWidgetBackgroundCoverAlbum(widthScreen, heightScreen),
          _buildWidgetContainerContent(widthScreen, heightScreen),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            width: widthScreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 128.0 + 16.0),
                      Container(
                        width: 72.0,
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        child: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                      ),
                      SizedBox(height: 24.0),
                      ClipRRect(
                        child: Image.asset(
                          'cover.jpeg',
                          width: widthScreen / 1.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(48.0)),
                      ),
                    ],
                  ),
                ),
                WidgetDetailTitleMusic(),
                SizedBox(height: 16.0),
                WidgetProgressMusic(),
                SizedBox(height: 16.0),
                _buildWidgetPlayerController(),
                SizedBox(height: 16.0),
                SizedBox(height: paddingBottom > 0 ? paddingBottom : 16.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetBackgroundCoverAlbum(
      double widthScreen, double heightScreen) {
    return Container(
      width: widthScreen,
      height: heightScreen / 2,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('cover.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0,
        ),
        child: Container(
          color: Colors.white.withOpacity(0.0),
        ),
      ),
    );
  }

  Widget _buildWidgetContainerContent(double widthScreen, double heightScreen) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: widthScreen,
        height: heightScreen / 1.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(48.0), topRight: Radius.circular(48.0)),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Colors.blueGrey[300],
              Colors.white,
            ],
            stops: [0.1, 0.9],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetPlayerController() {
    return Consumer<MyAudio>(
      builder: (context, audioPlayer, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              audioPlayer.skitToPrevious();
            },
            child: Icon(Icons.skip_previous_rounded,
                color: Colors.white, size: 32.0),
          ),
          SizedBox(width: 36.0),
          GestureDetector(
            onTap: () {
              audioPlayer.isPlaying
                  ? audioPlayer.pauseSong()
                  : audioPlayer.resumeSong();
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey[800],
              ),
              padding: EdgeInsets.all(16.0),
              child: Icon(
                  audioPlayer.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32.0),
            ),
          ),
          SizedBox(width: 36.0),
          GestureDetector(
            onTap: () {
              audioPlayer.skipToNext();
            },
            child:
                Icon(Icons.skip_next_rounded, color: Colors.white, size: 32.0),
          )
        ],
      ),
    );
  }
}

class WidgetDetailTitleMusic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Consumer<MyAudio>(
                builder: (context, audioPlayer, child) => Text(
                    audioPlayer.songList[audioPlayer.indexSongSelected].title,
                    style: Theme.of(context).textTheme.headline6),
              ),
              Consumer<MyAudio>(
                builder: (context, audioPlayer, child) => Text(
                    audioPlayer.songList[audioPlayer.indexSongSelected].artist,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .merge(TextStyle(color: Colors.blueGrey))),
              ),
            ],
          ),
        ),
        Consumer<MyAudio>(
          builder: (context, audioPlayer, child) => GestureDetector(
            onTap: () {
              audioPlayer.isRepeatOne = !audioPlayer.isRepeatOne;
            },
            child: Icon(
              Icons.repeat_one,
              color: audioPlayer.isRepeatOne
                  ? Color(0xFFAE1947)
                  : Color(0xFF000000),
            ),
          ),
        ),
      ],
    );
  }
}

class WidgetProgressMusic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildWidgetSlider(),
        Row(
          //TODO
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Consumer<MyAudio>(
              builder: (context, audioPlayer, child) =>
                  Text(audioPlayer.getStrPosition()),
            ),
            Consumer<MyAudio>(
              builder: (context, audioPlayer, child) =>
                  Text(audioPlayer.getStrDuration()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWidgetSlider() {
    return Consumer<MyAudio>(
      builder: (context, audioPlayer, child) => Padding(
        padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFAE1947),
            inactiveTrackColor: Colors.red[100],
            trackShape: RectangularSliderTrackShape(),
            trackHeight: 4.0,
            thumbColor: Color(0xFFAE1947),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayColor: Colors.red.withAlpha(32),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 6.0),
          ),
          child: Slider.adaptive(
            // activeColor: Colors.blue[800],
            // inactiveColor: Colors.grey,
            value: audioPlayer.position.inSeconds.toDouble(),
            max: audioPlayer.songLength.inSeconds.toDouble(),
            onChanged: (value) {
              audioPlayer.seekToSec(value.toInt());
            },
          ),
        ),
      ),
    );
  }
}
