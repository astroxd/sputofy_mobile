import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sputofy_2/main.dart';

// void main() => runApp(new MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "player",
//       theme: ThemeData(primarySwatch: Colors.deepOrange),
//       home: AudioServiceWidget(
//         child: MainScreen(),
//       ),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Example")),
//       body: Center(
//         child: StreamBuilder<PlaybackState>(
//             stream: AudioService.playbackStateStream,
//             builder: (context, snapshot) {
//               final playing = snapshot.data?.playing ?? false;
//               final processingState = snapshot.data?.processingState ??
//                   AudioProcessingState.stopped;
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (playing)
//                     ElevatedButton(child: Text("Pause"), onPressed: pause)
//                   else
//                     ElevatedButton(child: Text("Play"), onPressed: play),
//                   if (processingState != AudioProcessingState.stopped)
//                     ElevatedButton(child: Text("Stop"), onPressed: stop),
//                   // SizedBox(height: 10),
//                   // Row(
//                   //   children: <Widget>[
//                   //     ElevatedButton(child: Text("prev"), onPressed: goback),
//                   //     ElevatedButton(child: Text("skip"), onPressed: skip),
//                   //   ],
//                   // )
//                 ],
//               );
//             }),
//       ),
//     );
//   }

//   stop() => AudioService.stop();
//   play() {
//     if (AudioService.running) {
//       AudioService.play();
//     } else {
//       AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);
//     }
//   }

//   goback() => AudioService.skipToPrevious();
//   skip() => AudioService.skipToNext();
//   pause() => AudioService.pause();
// }

// _backgroundTaskEntrypoint() {
//   AudioServiceBackground.run(() => AudioPlayerTask());
// }

// class AudioPlayerTask extends BackgroundAudioTask {
//   AudioPlayer _audioPlayer = AudioPlayer();
//   final _completer = Completer();

//   List songs = ["assets/song1.mp3", "assets/song2.mp3", "assets/song3.mp3"];
//   int index = -1;

//   @override
//   Future<void> onStart(Map<String, dynamic> params) async {
//     super.onStart(params);
//     print("cacca");
//     AudioServiceBackground.setState(
//         processingState: AudioProcessingState.connecting,
//         controls: [MediaControl.pause, MediaControl.stop],
//         playing: false);
//     //await _audioPlayer.setFilePath()
//     // await _audioPlayer.setAsset('assets/song1.mp3');
//     // _audioPlayer.play();
//   }

//   @override
//   Future<void> onStop() async {
//     await _audioPlayer.stop();
//     await super.onStop();
//     await AudioServiceBackground.setState(
//         controls: [],
//         playing: false,
//         processingState: AudioProcessingState.stopped);
//   }

//   @override
//   Future<void> onPlay() async {
//     index = 0;
//     await _audioPlayer.setAsset(songs[index]);
//     print("Duration ${_audioPlayer.load()}");
//     await _audioPlayer.play();
//     await AudioServiceBackground.setState(
//         controls: [MediaControl.pause, MediaControl.stop],
//         playing: true,
//         processingState: AudioProcessingState.ready);
//   }

//   @override
//   Future<void> onSkipToPrevious() async {
//     index--;
//     await _audioPlayer.setAsset(songs[index]);
//     return super.onSkipToPrevious();
//   }

//   @override
//   Future<void> onSkipToNext() async {
//     index++;
//     await _audioPlayer.setAsset(songs[index]);
//     return super.onSkipToNext();
//   }

//   @override
//   Future<void> onPause() {
//     _audioPlayer.pause();
//     AudioServiceBackground.setState(
//         controls: [MediaControl.play, MediaControl.stop],
//         playing: false,
//         processingState: AudioProcessingState.ready);
//     return super.onPause();
//   }
// }
//
//

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      home: AudioServiceWidget(
        child: MainScreen(),
      ),
    );
  }
}

_backgroundTaskEntryPoint() {
  print("entrypoint");
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<PlaybackState>(
          stream: AudioService.playbackStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            final processingState =
                snapshot.data?.processingState ?? AudioProcessingState.stopped;
            print("playing var = $playing");
            print("processingstate var = $processingState");
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (playing)
                  MaterialButton(
                    child: Text("Pause"),
                    onPressed: pause,
                    color: Colors.green,
                  )
                else
                  MaterialButton(
                    child: Text("Play"),
                    onPressed: play,
                    color: Colors.green,
                  ),
                if (processingState != AudioProcessingState.stopped &&
                    processingState != AudioProcessingState.none)
                  MaterialButton(
                    child: Text("Stop"),
                    onPressed: stop,
                    color: Colors.red,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  //* AudioService lo usi per parlare con la background task
  start() {
    print("start");
    AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntryPoint);
  }

  stop() {
    print("stop");
    AudioService.stop();
  }

  play() async {
    if (AudioService.running) {
      AudioService.play();
    } else {
      start();
    }
  }

  pause() {
    print("Pause");
    AudioService.pause();
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer();
  //*  Qui overridi le varie funzioni
  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    print("onStart");

    AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.connecting);

    // await _audioPlayer.setFilePath();
    await _audioPlayer.setAsset("assets/song2.mp3");
  }

  @override
  Future<void> onStop() async {
    print("onStop");
    AudioServiceBackground.setState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.stopped);
    await _audioPlayer.stop();
    await super.onStop();
  }

  @override
  Future<void> onPlay() async {
    var song = MediaItem(
      id: "assets/song2.mp3",
      album: 'Album',
      title: 'title',
      duration: _audioPlayer.duration,
      rating: Rating.newHeartRating(true),
    );
    print("position var = ${_audioPlayer.position}");
    AudioServiceBackground.setMediaItem(song);
    AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: true,
        systemActions: [MediaAction.seekTo, MediaAction.setRating],
        processingState: AudioProcessingState.ready);
    await _audioPlayer.play();
  }

  @override
  Future<void> onPause() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.ready);
    await _audioPlayer.pause();
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    await _audioPlayer.seek(position);
    AudioServiceBackground.setState(position: position);
  }

  // @override
  // Future<void> onSetRating(Rating rating, Map<dynamic, dynamic> params) async {
  //   // AudioService.setRating();

  // }
}
