import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sputofy_2/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audio_session/audio_session.dart';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<PlaybackState>(
                stream: AudioService.playbackStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  final processingState = snapshot.data?.processingState ??
                      AudioProcessingState.stopped;
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
              MaterialButton(
                  child: Text("ADD"),
                  color: Colors.blue,
                  onPressed: () => add(
                      MediaItem(id: "cacca", album: "cacca", title: "cacca"))),
              StreamBuilder(
                stream: _queueStateStream,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    final queueStateStream = snapshot.data;
                    return Container(
                      width: double.infinity,
                      height: 300,
                      child: ListView.builder(
                        itemCount: queueStateStream.queue.length,
                        itemBuilder: (context, index) {
                          final mediaItem = queueStateStream.queue[index];
                          final currentMediaItem = queueStateStream.mediaItem;
                          return MaterialButton(
                            onPressed: () => seek(mediaItem.id),
                            child: mediaItem == currentMediaItem
                                ? Text(
                                    currentMediaItem.title,
                                    style: TextStyle(color: Colors.blue),
                                  )
                                : Text(mediaItem.title),
                          );
                        },
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //* AudioService lo usi per parlare con la background task

  List<Song> playlist = [
    Song(
        id: '/storage/emulated/0/Download/oregairu.mp3',
        title: 'oregairu',
        album: 'cacca'),
    Song(
        id: '/storage/emulated/0/Download/BLESS YoUr NAME - ChouCho (Highschool DXD BorN OP Full).mp3',
        title: 'BLESS YoUr NAME - ChouCho (Highschool DXD BorN OP Full)',
        album: 'cacca'),
  ];

  start() {
    final mediaList = [];
    for (var song in playlist) {
      print(song);
      final mediaItem =
          MediaItem(id: song.id, album: song.album, title: song.title);
      print(mediaItem);
      mediaList.add(mediaItem.toJson());
    }
    if (mediaList.isEmpty) return;
    final params = {'data': mediaList};
    print(params);
    AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntryPoint, params: params);
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

  add(MediaItem mediaItem) {
    AudioService.addQueueItem(mediaItem);
  }

  seek(String mediaId) {
    AudioService.skipToQueueItem(mediaId);
  }

  Stream<QueueState> get _queueStateStream =>
      Rx.combineLatest2<List<MediaItem>, MediaItem, QueueState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          (queue, mediaItem) => QueueState(queue, mediaItem));
}

class Song {
  final String id;
  final String title;
  final String album;

  Song({@required this.id, @required this.title, @required this.album});
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> _queue = [];
  int get index => _audioPlayer.currentIndex;
  MediaItem get mediaItem => index == null ? null : _queue[index];

  //*  Qui overridi le varie funzioni

  //* START-------------------------------------------------

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    //* params sarà la playlist
    print("onStart");
    _loadMediaItemsIntoQueue(params);
    await _setAudioSession();
    _broadcaseMediaItemChanges();
    _propogateEventsFromAudioPlayerToAudioServiceClients();
    _performSpecialProcessingForStateTransitions();
    _loadQueue();
  }

  _loadMediaItemsIntoQueue(Map<String, dynamic> params) {
    _queue.clear();
    final List mediaItems = params['data'];
    for (var item in mediaItems) {
      final mediaItem = MediaItem.fromJson(item);
      _queue.add(mediaItem);
    }
    print("ok");
    print(_queue);
  }

  Future<void> _setAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  //* Cambia il current item
  void _broadcaseMediaItemChanges() {
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(_queue[index]);
    });
  }

  //* Legge quale evento sta facendo e fa aggiornae il badge delle notifiche
  void _propogateEventsFromAudioPlayerToAudioServiceClients() {
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      _broadcastState();
    });
  }

  //* Cambia canzone appena finisce la precedente
  void _performSpecialProcessingForStateTransitions() {
    _audioPlayer.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          _audioPlayer.pause();
          _audioPlayer.seek(Duration.zero,
              index: _audioPlayer.effectiveIndices.first);
          break;
        case ProcessingState.ready:
          _skipState = null;
          break;
        default:
          break;
      }
    });
  }

  ///* Crea la lista di AudioSource
  Future<void> _loadQueue() async {
    AudioServiceBackground.setQueue(_queue);

    try {
      await _audioPlayer.setAudioSource(ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: _queue.map((item) {
          final uri = Uri.parse(item.id);
          return AudioSource.uri(uri);
        }).toList(),
      ));
      _audioPlayer.durationStream.listen((duration) {
        _updateQueueWithCurrentDuration(duration);
      });
    } catch (e) {
      print('Error: $e');
      onStop();
    }
  }

  ///* Mette la duration al current MediaItem appena lo sta per suonare
  void _updateQueueWithCurrentDuration(Duration duration) {
    final songIndex = _audioPlayer.currentIndex;
    if (duration == null || mediaItem == null) {
      return;
    }
    final modifiedMediaItem = mediaItem.copyWith(duration: duration);
    _queue[songIndex] = modifiedMediaItem;
    AudioServiceBackground.setQueue(_queue);
    AudioServiceBackground.setMediaItem(_queue[songIndex]);
  }
//* ---------------------------------------------------------------------------

  @override
  Future<void> onStop() async {
    print("onStop");
    await _audioPlayer.dispose();
    _eventSubscription.cancel();
    await _broadcastState();
    await super.onStop();
  }

  @override
  Future<void> onPlay() async {
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

  @override
  Future<void> onAddQueueItem(MediaItem mediaItem) async {
    _queue.forEach((element) {
      print("${element.id}------${element.duration}");
    });
    // _queue.add(mediaItem);
    // AudioServiceBackground.setQueue(_queue);
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final newIndex = _queue.indexWhere((song) => song.id == mediaId);

    if (newIndex == -1 || index == null) return;
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;

    await _audioPlayer.seek(Duration.zero, index: newIndex);
  }

  ///* Cambia il badge delle notifiche
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      androidCompactActions: [0, 1, 2],
      processingState: _getProcessingState(),
      playing: _audioPlayer.playing,
      position: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
    );
  }

  ///* Prende il processo che sta facendo
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_audioPlayer.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_audioPlayer.processingState}");
    }
  }
}

//* FILES
//* path : /data/user/0/com.example.sputofy_2/cache/file_picker/oregairu.mp3
//* URI : content://com.android.externalstorage.documents/document/primary%3ADownload%2Foregairu.mp3

// void main() => runApp(new MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Test",
//       home: AudioServiceWidget(
//         child: PlayerScreen(),
//       ),
//     );
//   }
// }

// class PlayerScreen extends StatefulWidget {
//   @override
//   _PlayerScreenState createState() => _PlayerScreenState();
// }

// class _PlayerScreenState extends State<PlayerScreen> {
//   final player = AudioPlayer();
//   // ProgressiveAudioSource canzone = ProgressiveAudioSource(
//   //     Uri.parse("/storage/emulated/0/Downloads/oregairu.mp3"));
//   ProgressiveAudioSource canzone = ProgressiveAudioSource(Uri.parse(
//       "/storage/emulated/0/Downloads/BLESS YoUr NAME - ChouCho (Highschool DXD BorN OP Full).mp3"));

//   String nome = "";

//   // @override
//   // void initState() {
//   //   player.setAudioSource(ConcatenatingAudioSource(children: [canzone]));
//   //   player.play();
//   //   super.initState();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           MaterialButton(
//             child: Text("add"),
//             onPressed: add,
//           ),
//           MaterialButton(
//             child: Text("play"),
//             onPressed: player.play,
//           ),
//           Text(nome)
//         ],
//       ),
//     ));
//   }

//   add() async {
//     FilePickerResult result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       File file = File(result.files.single.path);
//       setState(() {
//         nome = file.path;
//         player.setAudioSource(ConcatenatingAudioSource(
//           children: [
//             ProgressiveAudioSource(
//               Uri.parse(nome),
//             )
//           ],
//         ));
//         print(nome);
//       });
//     } else {
//       // User canceled the picker
//     }
//   }
// }
