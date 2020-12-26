import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:sputofy/music_block.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MusicBloc>(
      create: (context) => MusicBloc(),
      child: MaterialApp(
        title: 'Sputofy',
        theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AudioPlayer _player;
  AudioCache cache;

  Duration position = new Duration();
  Duration musicLength = new Duration();

  List<Music> listMusic = [
    Music('song3', 'Taylor Swift', 9, 'song3.mp3'),
    Music('song2', 'Taylor Swift', 264, 'song2.mp3'),
    Music('song1', 'Taylor Swift', 239, 'song1.mp3'),
  ];

  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  int indexMusicSelected = -1;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    cache = AudioCache(fixedPlayer: _player);

    _player.onPlayerCompletion.listen((event) {
      skipToNext();
    });
  }

  void skipToNext() {
    int lastSong = listMusic.length;
    if (indexMusicSelected != lastSong) {
      indexMusicSelected++;
      cache.play(listMusic[indexMusicSelected].path);
      // _player.play(songList[songIndex]);//FILEPICKING
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void skitToPrevious() {
    if (indexMusicSelected != 0) {
      indexMusicSelected--;
      cache.play(listMusic[indexMusicSelected].path);
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heigthScreen = mediaQueryData.size.height;
    double paddingBottom = mediaQueryData.padding.bottom;
    return Scaffold(
      body: Container(
        width: widthScreen,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                _buildWidgetBackgroundCoverAlbum(widthScreen, context),
                _buildWidgetListMusic(
                  context,
                  paddingBottom,
                  widthScreen,
                  heigthScreen,
                ),
              ],
            ),
            _buildWidgetButtonPlayAll(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetBackgroundCoverAlbum(
      double widthScreen, BuildContext context) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("cover.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.0),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.1),
                ],
                stops: [
                  0.0,
                  0.7,
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: widthScreen / 2.5,
              height: widthScreen / 2.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("cover.jpeg"), fit: BoxFit.cover),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 15.0,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: widthScreen / 1.45,
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  "Red (Deluxe Edition)",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .merge(TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  "22 songs 1 hr 30 min",
                  style: Theme.of(context).textTheme.subtitle2.merge(
                        TextStyle(color: Colors.grey),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetListMusic(BuildContext context, double paddingBottom,
      double widthScreen, double heigthScreen) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: paddingBottom > 0 ? paddingBottom : 16.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Colors.blueGrey.withOpacity(0.7),
              Colors.white70.withOpacity(0.7),
            ],
            stops: [
              0.1,
              0.9,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 48.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Playlist",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                _buildWidgetShuffle(),
                SizedBox(width: 24.0),
                _buildWidgetRepeat(),
              ],
            ),
            SizedBox(height: 8.0),
            _buildWidgetPlaylistMusic(listMusic, widthScreen, heigthScreen,
                paddingBottom, _player, cache),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetShuffle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isShuffle = !_isShuffle;
        });
      },
      child: Icon(
        Icons.shuffle,
        color: Color(_isShuffle ? 0xFFAE1947 : 0xFF000000),
      ),
    );
  }

  Widget _buildWidgetRepeat() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRepeat = !_isRepeat;
        });
      },
      child: Icon(
        Icons.repeat,
        color: Color(_isRepeat ? 0xFFAE1947 : 0xFF000000),
      ),
    );
  }

  Widget _buildWidgetPlaylistMusic(
      listMusic, widthScreen, heigthScreen, paddingBottom, _player, cache) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          Music music = listMusic[index];
          int durationMinute =
              music.durationSecond >= 60 ? music.durationSecond ~/ 60 : 0;
          int durationSecond = music.durationSecond >= 60
              ? music.durationSecond % 60
              : music.durationSecond;
          String strDuration = "$durationMinute:" +
              (durationSecond < 10 ? "0$durationSecond" : "$durationSecond");
          return GestureDetector(
            onTap: () {
              // _showMiniPlayer(music, widthScreen, heigthScreen, paddingBottom);
              setState(() {
                if (index != indexMusicSelected) {
                  // _player.stop();
                  // _isPlaying = false;
                  indexMusicSelected = index;
                  cache.play(listMusic[index].path);
                  _isPlaying = true;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          music.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(indexMusicSelected == index
                                ? 0xFFAE1947
                                : 0xFF000000),
                          ),
                        ),
                        Text(
                          '${music.artist} • $strDuration',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert),
                ],
              ),
            ),
          );
        },
        itemCount: listMusic.length,
      ),
    );
  }

  void _showMiniPlayer(music, widthScreen, heigthScreen, paddingBottom) {
    showBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        builder: (context) {
          return WidgetMiniPlayer(
              music, widthScreen, heigthScreen, paddingBottom, _player, cache);
        });
  }

  Widget _buildWidgetButtonPlayAll() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 92.0,
        decoration: BoxDecoration(
          color: Color(0xFFAE1947),
          borderRadius: BorderRadius.all(Radius.circular(48.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              color: Color(0xFFAE1947),
            )
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            if (_isPlaying) {
              _player.stop();
              setState(() {
                _isPlaying = false;
              });
            }
            cache.play(listMusic[0].path);
            setState(() {
              _isPlaying = true;
              indexMusicSelected = 0;
            });
          },
        ),
      ),
    );
  }
}

class WidgetMiniPlayer extends StatefulWidget {
  final Music music;
  final double widthScreen;
  final double heigthScreen;
  final double paddingBottom;
  final AudioPlayer _player;
  final AudioCache cache;

  WidgetMiniPlayer(this.music, this.widthScreen, this.heigthScreen,
      this.paddingBottom, this._player, this.cache);
  @override
  _WidgetMiniPlayerState createState() => _WidgetMiniPlayerState();
}

class _WidgetMiniPlayerState extends State<WidgetMiniPlayer> {
  Duration position = new Duration();
  Duration songLength = new Duration();

  @override
  void initState() {
    widget._player.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        position = p;
      });
    });
    widget._player.onDurationChanged.listen((Duration d) {
      setState(() {
        songLength = d;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            // return WidgetDetailMusicPlayer();
            return; //
          },
          isScrollControlled: true,
          isDismissible: false,
        );
      },
      // child: BlocProvider(
      child: Container(
        width: widget.widthScreen,
        padding: EdgeInsets.only(
            left: 16.0,
            top: 4.0,
            right: 16.0,
            bottom: widget.paddingBottom > 0 ? widget.paddingBottom : 16.0),
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
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .merge(TextStyle(color: Colors.grey)),
                      ),
                      Text(
                        '${widget.music.title}',
                        style: Theme.of(context).textTheme.headline6,
                      )
                    ],
                  ),
                ),
                Stack(
                  children: <Widget>[
                    SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: SleekCircularSlider(
                        appearance: CircularSliderAppearance(
                          customWidths: CustomSliderWidths(
                              progressBarWidth: 2.0,
                              trackWidth: 1.0,
                              handlerSize: 1.0,
                              shadowWidth: 1.0),
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
                        max: songLength.inSeconds.toDouble(),
                        initialValue: position.inSeconds.toDouble(),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 32.0,
                  height: 32.0,
                  // child: Icon(
                  //   isPlaying ? Icons.pause : Icons.play_arrow,
                  //   size: 20.0,
                  // ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Music {
  String title;
  String artist;
  int durationSecond;
  String path;
  Music(this.title, this.artist, this.durationSecond, this.path);
}
