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
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:sputofy_2/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audio_session/audio_session.dart';
import 'package:sputofy_2/palette.dart';
import 'package:sqflite/utils/utils.dart';

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
      backgroundColor: mainColor,
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
                          onPressed: () {
                            _showDialogWindow(context);
                            play();
                          },
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
                                    "${currentMediaItem.title}---${currentMediaItem.duration.toString()}",
                                    style: TextStyle(color: Colors.blue),
                                  )
                                : Text(
                                    "${mediaItem.title}----${mediaItem.duration.toString()}"),
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

  _showDialogWindow(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (context) => MiniPlayer(_playingMediaItemStream),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      // backgroundColor: Colors.red,
      elevation: 1.0,
    );
  }

  //* AudioService lo usi per parlare con la background task
  List<Song> playlist = [
    Song(
      id: '/storage/emulated/0/Download/oregairu.mp3',
      title: 'oregairu',
      album: 'cacca',
      duration: Duration(milliseconds: 273057),
    ),
    Song(
      id: '/storage/emulated/0/Download/BLESS YoUr NAME - ChouCho (Highschool DXD BorN OP Full).mp3',
      title: 'BLESS YoUr NAME - ChouCho (Highschool DXD BorN OP Full)',
      album: 'cacca',
      duration: Duration(milliseconds: 282096),
    ),
  ];

  start() async {
    final mediaList = [];
    for (var song in playlist) {
      print(song);
      final mediaItem = MediaItem(
          id: song.id,
          album: song.album,
          title: song.title,
          duration: song.duration);
      mediaList.add(mediaItem.toJson());
    }
    if (mediaList.isEmpty) return;
    final params = {'data': mediaList};
    AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntryPoint,
        params: params,
        androidEnableQueue: true,
        androidNotificationColor: 16762880);
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
    // AudioService.setRating(Rating.newHeartRating(true));
  }

  seek(String mediaId) {
    AudioService.skipToQueueItem(mediaId);
  }

  Stream<QueueState> get _queueStateStream =>
      Rx.combineLatest2<List<MediaItem>, MediaItem, QueueState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          (queue, mediaItem) => QueueState(queue, mediaItem));
  Stream get _playingMediaItemStream =>
      Rx.combineLatest2<MediaItem, Duration, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          (mediaItem, position) => PlayingMediaItem(mediaItem, position));
}

class Song {
  final String id;
  final String title;
  final String album;
  final Duration duration;

  Song({
    @required this.id,
    @required this.title,
    @required this.album,
    @required this.duration,
  });
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class PlayingMediaItem {
  final MediaItem mediaItem;
  final Duration position;

  PlayingMediaItem(this.mediaItem, this.position);
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
  }

  Future<void> _setAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  ///* Cambia il current item
  void _broadcaseMediaItemChanges() {
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(_queue[index]);
    });
  }

  ///* Legge quale evento sta facendo e fa aggiornae il badge delle notifiche
  void _propogateEventsFromAudioPlayerToAudioServiceClients() {
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      _broadcastState();
    });
  }

  ///* Cambia canzone appena finisce la precedente
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

      // _audioPlayer.durationStream.listen((duration) {
      //   _updateQueueWithCurrentDuration(duration);
      // });
    } catch (e) {
      print('Error: $e');
      onStop();
    }

    AudioServiceBackground.setMediaItem(_queue[index]);
  }

  ///* Mette la duration al current MediaItem appena lo sta per suonare
  // void _updateQueueWithCurrentDuration(Duration duration) {
  //   final songIndex = _audioPlayer.currentIndex;
  //   if (duration == null || mediaItem == null) {
  //     return;
  //   }
  //   final modifiedMediaItem = mediaItem.copyWith(
  //     duration: duration,
  //     rating: Rating.newHeartRating(false),
  //     artUri:
  //         "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
  //   );
  //   _queue[songIndex] = modifiedMediaItem;
  //   AudioServiceBackground.setQueue(_queue);
  //   AudioServiceBackground.setMediaItem(_queue[songIndex]);
  // }
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
    await _audioPlayer.play();
  }

  @override
  Future<void> onPause() async {
    await _audioPlayer.pause();
    print(_audioPlayer.effectiveIndices.first);
    print(_audioPlayer.duration.inMilliseconds);
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    await _audioPlayer.seek(position);
    // AudioServiceBackground.setState(position: position);
  }

  @override
  Future<void> onAddQueueItem(MediaItem mediaItem) async {
    _queue.add(mediaItem);
    _loadQueue();
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final newIndex = _queue.indexWhere((song) => song.id == mediaId);

    if (newIndex == -1 || index == null) return;
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;

    await _audioPlayer.seek(Duration.zero, index: newIndex);
    if (!_audioPlayer.playing) await _audioPlayer.play();
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
      systemActions: [MediaAction.setRating, MediaAction.seekTo],
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

class MiniPlayer extends StatelessWidget {
  MiniPlayer(this._playingMediaItemStream);
  final Stream _playingMediaItemStream;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            // return DetailMusicPlayer();
            return Container(
              color: Colors.blue,
            );
          },
          isDismissible: false,
          isScrollControlled: true,
        );
      },
      child: StreamBuilder(
          stream: _playingMediaItemStream,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              final playingMediaItemStream = snapshot.data;
              final mediaItem = playingMediaItemStream.mediaItem;
              final position = playingMediaItemStream.position;
              return Container(
                width: double.infinity,
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
                      max: mediaItem?.duration?.inSeconds?.toDouble() ?? 0.0,
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
                            mediaItem?.title ?? "cacca",
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.skip_previous_rounded,
                          size: 36,
                        ),
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 36,
                        ),
                        Icon(
                          Icons.skip_next_rounded,
                          size: 36,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

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
