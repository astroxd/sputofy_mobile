import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "player",
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: AudioServiceWidget(
        child: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Example")),
      body: Center(
        child: StreamBuilder<PlaybackState>(
            stream: AudioService.playbackStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              final processingState = snapshot.data?.processingState ??
                  AudioProcessingState.stopped;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (playing)
                    ElevatedButton(child: Text("Pause"), onPressed: pause)
                  else
                    ElevatedButton(child: Text("Play"), onPressed: play),
                  if (processingState != AudioProcessingState.stopped)
                    ElevatedButton(child: Text("Stop"), onPressed: stop),
                  // SizedBox(height: 10),
                  // Row(
                  //   children: <Widget>[
                  //     ElevatedButton(child: Text("prev"), onPressed: goback),
                  //     ElevatedButton(child: Text("skip"), onPressed: skip),
                  //   ],
                  // )
                ],
              );
            }),
      ),
    );
  }

  stop() => AudioService.stop();
  play() {
    if (AudioService.running) {
      AudioService.play();
    } else {
      AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);
    }
  }

  goback() => AudioService.skipToPrevious();
  skip() => AudioService.skipToNext();
  pause() => AudioService.pause();
}

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  final _completer = Completer();

  List songs = ["assets/song1.mp3", "assets/song2.mp3", "assets/song3.mp3"];
  int index = -1;

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    super.onStart(params);
    print("cacca");
    AudioServiceBackground.setState(
        processingState: AudioProcessingState.connecting,
        controls: [MediaControl.pause, MediaControl.stop],
        playing: false);
    //await _audioPlayer.setFilePath()
    // await _audioPlayer.setAsset('assets/song1.mp3');
    // _audioPlayer.play();
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.stop();
    await super.onStop();
    await AudioServiceBackground.setState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.stopped);
  }

  @override
  Future<void> onPlay() async {
    index = 0;
    await _audioPlayer.setAsset(songs[index]);
    print("Duration ${_audioPlayer.load()}");
    await _audioPlayer.play();
    await AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: true,
        processingState: AudioProcessingState.ready);
  }

  @override
  Future<void> onSkipToPrevious() async {
    index--;
    await _audioPlayer.setAsset(songs[index]);
    return super.onSkipToPrevious();
  }

  @override
  Future<void> onSkipToNext() async {
    index++;
    await _audioPlayer.setAsset(songs[index]);
    return super.onSkipToNext();
  }

  @override
  Future<void> onPause() {
    _audioPlayer.pause();
    AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.ready);
    return super.onPause();
  }
}
