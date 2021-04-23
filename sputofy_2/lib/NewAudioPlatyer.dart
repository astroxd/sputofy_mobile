import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audio_session/audio_session.dart';
import 'package:sputofy_2/utils/palette.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';

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
      body: SafeArea(
        child: Center(
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
                              showDialogWindow(context);
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
                    onPressed: () => add(MediaItem(
                        id: "cacca", album: "cacca", title: "cacca"))),
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
      ),
    );
  }

  //* AudioService lo usi per parlare con la background task
  List<Song> playlist = [
    Song(
      id: '/storage/emulated/0/Download/BLESS YoUr NAME - ChouCho (Highschool DXD BorN OP Full).mp3',
      title: 'BLESS YoUr NAME - ChouCho (Highschool DXD BorN OP Full)',
      album: 'album',
      duration: Duration(milliseconds: 282096),
      artUri:
          "https://www.vhv.rs/dpng/d/262-2628798_transparent-overlord-anime-png-wings-of-freedom-logo.png",
    ),
    Song(
      id: '/storage/emulated/0/Download/snafu.mp3',
      title: 'oregairu',
      album: 'album',
      duration: Duration(milliseconds: 273057),
      artUri:
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
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
        duration: song.duration,
        artUri: song.artUri,
      );
      mediaList.add(mediaItem.toJson());
    }
    if (mediaList.isEmpty) return;
    final params = {'data': mediaList};
    AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntryPoint,
        params: params,
        androidEnableQueue: true,
        androidNotificationColor: 0x0000ff);
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
}

class Song {
  final String id;
  final String title;
  final String album;
  final Duration duration;
  final String artUri;

  Song({
    @required this.artUri,
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
  final PlaybackState playbackState;

  PlayingMediaItem(this.mediaItem, this.position, this.playbackState);
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;
  StreamSubscription<SequenceState> _sequenceStateSubscription;

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
    // _propogateCustomAudioServiceFunctionToAudioServiceClients();
    _loadQueue();
  }

  _loadMediaItemsIntoQueue(Map<String, dynamic> params) {
    _queue.clear();
    final List mediaItems = params['data'];
    for (var item in mediaItems) {
      final mediaItem = MediaItem.fromJson(item);
      final newItem = mediaItem.copyWith(rating: Rating.newHeartRating(true));
      // _queue.add(mediaItem);
      _queue.add(newItem);
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
    _sequenceStateSubscription =
        _audioPlayer.sequenceStateStream.listen((event) {
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
      //   print(duration.inMilliseconds);
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
    _sequenceStateSubscription.cancel();
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

  @override
  Future<void> onCustomAction(String funcName, dynamic arguments) async {
    switch (funcName) {
      case 'setVolume':
        await _audioPlayer.setVolume(arguments);
        AudioServiceBackground.sendCustomEvent(_audioPlayer.volume);

        break;
    }
  }

  @override
  Future<void> onSetShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    switch (shuffleMode) {
      case AudioServiceShuffleMode.all:
        await _audioPlayer.setShuffleModeEnabled(true);
        break;
      case AudioServiceShuffleMode.none:
        await _audioPlayer.setShuffleModeEnabled(false);
        break;
      case AudioServiceShuffleMode.group:
        break;
    }
    _audioPlayer.setLoopMode(LoopMode.off);
  }

  @override
  Future<void> onSetRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        await _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.group:
        break;
    }
    _audioPlayer.setShuffleModeEnabled(false);
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
      systemActions: [
        MediaAction.seekTo,
        MediaAction.setShuffleMode,
        MediaAction.setRating
      ],
      processingState: _getProcessingState(),
      playing: _audioPlayer.playing,
      position: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      shuffleMode: _audioPlayer.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: _getRepeatMode(),
    );
  }

  _getRepeatMode() {
    switch (_audioPlayer.loopMode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
        break;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
        break;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
        break;
    }
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



// class DetailMusicPlayer extends StatelessWidget {
//   Stream get _playingMediaItemStream =>
//       Rx.combineLatest3<MediaItem, Duration, PlaybackState, PlayingMediaItem>(
//           AudioService.currentMediaItemStream,
//           AudioService.positionStream,
//           AudioService.playbackStateStream,
//           (mediaItem, position, playbackState) =>
//               PlayingMediaItem(mediaItem, position, playbackState));

//   @override
//   Widget build(BuildContext context) {
//     _showPopupMenu() {
//       showMenu<String>(
//         context: context,
//         position: RelativeRect.fromLTRB(16.0, 0.0, 0.0,
//             0.0), //position where you want to show the menu on screen
//         color: secondaryColor,
//         items: [
//           PopupMenuItem(
//             child: const Text("Share Song"),
//             value: '1',
//             textStyle: TextStyle(color: accentColor, fontSize: 18),
//           ),
//           PopupMenuItem(
//             child: const Text("Cancel Song"),
//             value: '2',
//             textStyle: TextStyle(color: Colors.red, fontSize: 18),
//           ),
//         ],
//         elevation: 8.0,
//       ).then<void>((String itemSelected) {
//         if (itemSelected == null) return;

//         if (itemSelected == "1") {
//           print("1");
//         } else if (itemSelected == "2") {
//           print("2");
//         } else {
//           //code here
//         }
//       });
//     }

//     return Scaffold(
//       backgroundColor: mainColor,
//       body: SafeArea(
//         child: StreamBuilder<PlayingMediaItem>(
//           stream: _playingMediaItemStream,
//           builder: (context, snapshot) {
//             if (snapshot.data != null) {
//               final playingMediaItemStream = snapshot.data;
//               final playingMediaItem = playingMediaItemStream.mediaItem;
//               final position = playingMediaItemStream.position;
//               final duration = playingMediaItem.duration;
//               final cover = playingMediaItem.artUri;
//               final playbackState = playingMediaItemStream.playbackState;
//               final shuffleMode = playbackState.shuffleMode;
//               final repeatMode = playbackState.repeatMode;

//               return Container(
//                 padding: const EdgeInsets.only(
//                     left: 16.0, right: 16.0, top: 64.0, bottom: 48.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     Column(
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             GestureDetector(
//                               onTap: Navigator.of(context).pop,
//                               child: Icon(
//                                 Icons.arrow_back,
//                                 size: 32.0,
//                                 color: accentColor,
//                               ),
//                             ),
//                             Row(
//                               children: <Widget>[
//                                 Icon(
//                                   Icons.volume_down,
//                                   size: 32.0,
//                                 ),
//                                 StreamBuilder(
//                                   stream: AudioService.customEventStream,
//                                   initialData: 1.0,
//                                   builder: (context, snapshot) {
//                                     return SliderTheme(
//                                       data: CustomTheme,
//                                       child: Slider(
//                                         value: snapshot.data,
//                                         max: 2.0,
//                                         min: 0.0,
//                                         onChanged: (double value) {
//                                           AudioService.customAction(
//                                               "setVolume", value);
//                                         },
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 Icon(
//                                   Icons.volume_up,
//                                   size: 32.0,
//                                 ),
//                               ],
//                             ),
//                             GestureDetector(
//                               onTap: _showPopupMenu,
//                               child: Icon(
//                                 Icons.more_vert,
//                                 size: 32.0,
//                                 color: accentColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 32.0,
//                         ),
//                         ClipRRect(
//                           child: ConstrainedBox(
//                             constraints: BoxConstraints(maxHeight: 300.0),
//                             child: cover != null
//                                 ? Image.network(cover)
//                                 : Image.asset("cover.jpeg"),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 16.0,
//                         ),
//                         SizedBox(
//                           height: 62.0,
//                           child: Text(
//                             playingMediaItem?.title ?? "Unknown title",
//                             // "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
//                             style: TextStyle(color: accentColor, fontSize: 18),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 3,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 16.0,
//                         ),
//                         Text(
//                           playingMediaItem?.artist ?? "Unknown artist",
//                           style: TextStyle(color: secondaryColor, fontSize: 20),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             GestureDetector(
//                               onTap: AudioService.skipToPrevious,
//                               child: Icon(
//                                 Icons.skip_previous,
//                                 size: 64,
//                               ),
//                             ),
//                             SizedBox(
//                               width: 24.0,
//                             ),
//                             GestureDetector(
//                               onTap: playbackState.playing
//                                   ? AudioService.pause
//                                   : AudioService.play,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: secondaryColor,
//                                   borderRadius: BorderRadius.circular(32.0),
//                                 ),
//                                 child: Icon(
//                                   playbackState.playing
//                                       ? Icons.pause
//                                       : Icons.play_arrow,
//                                   size: 64,
//                                   color: accentColor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 24.0,
//                             ),
//                             GestureDetector(
//                               onTap: AudioService.skipToNext,
//                               child: Icon(
//                                 Icons.skip_next,
//                                 size: 64,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 24.0,
//                         ),
//                         SliderTheme(
//                           data: CustomTheme,
//                           child: Slider(
//                             value: position.inSeconds.toDouble(),
//                             max: duration.inSeconds.toDouble(),
//                             min: 0.0,
//                             onChanged: (double value) {
//                               AudioService.seekTo(
//                                   Duration(seconds: value.toInt()));
//                             },
//                           ),
//                         ),
//                         SizedBox(
//                           height: 24.0,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             GestureDetector(
//                               onTap: () {
//                                 switch (repeatMode) {
//                                   case AudioServiceRepeatMode.none:
//                                     AudioService.setRepeatMode(
//                                         AudioServiceRepeatMode.one);
//                                     break;
//                                   case AudioServiceRepeatMode.one:
//                                     AudioService.setRepeatMode(
//                                         AudioServiceRepeatMode.all);
//                                     break;
//                                   case AudioServiceRepeatMode.all:
//                                     AudioService.setRepeatMode(
//                                         AudioServiceRepeatMode.none);
//                                     break;
//                                   case AudioServiceRepeatMode.group:
//                                     break;
//                                 }
//                               },
//                               child: _getRepeatIcon(repeatMode),
//                             ),
//                             Row(
//                               children: <Widget>[
//                                 Text(
//                                   getStrPosition(position),
//                                   style: TextStyle(
//                                       color: accentColor, fontSize: 32),
//                                 ),
//                                 SizedBox(
//                                   width: 3.0,
//                                 ),
//                                 Text(
//                                   "|",
//                                   style: TextStyle(
//                                       color: secondaryColor, fontSize: 32),
//                                 ),
//                                 SizedBox(
//                                   width: 3.0,
//                                 ),
//                                 Text(
//                                   getStrPosition(duration),
//                                   style: TextStyle(
//                                       color: secondaryColor, fontSize: 32),
//                                 ),
//                               ],
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 print(shuffleMode);
//                                 shuffleMode == AudioServiceShuffleMode.all
//                                     ? AudioService.setShuffleMode(
//                                         AudioServiceShuffleMode.none)
//                                     : AudioService.setShuffleMode(
//                                         AudioServiceShuffleMode.all);
//                               },
//                               child: Icon(
//                                 Icons.shuffle,
//                                 color:
//                                     shuffleMode == AudioServiceShuffleMode.all
//                                         ? accentColor
//                                         : Colors.black,
//                                 size: 32,
//                               ),
//                             ),
//                           ],
//                         ),
//                         // SizedBox(
//                         //   height: 32.0,
//                         // )
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return CircularProgressIndicator();
//           },
//         ),
//       ),
//     );
//   }

//   Icon _getRepeatIcon(AudioServiceRepeatMode repeatMode) {
//     switch (repeatMode) {
//       case AudioServiceRepeatMode.none:
//         return Icon(Icons.repeat, size: 32);
//         break;
//       case AudioServiceRepeatMode.one:
//         return Icon(Icons.repeat_one, size: 32, color: accentColor);
//         break;
//       case AudioServiceRepeatMode.all:
//         return Icon(Icons.repeat, size: 32, color: accentColor);
//         break;
//       case AudioServiceRepeatMode.group:
//         break;
//     }
//   }
// }

// String getStrPosition(Duration position) {
//   String strPosition = '00:00';
//   int positionMinute = position.inSeconds ~/ 60;
//   int positionSecond =
//       positionMinute > 0 ? position.inSeconds % 60 : position.inSeconds;
//   return strPosition =
//       (positionMinute < 10 ? '$positionMinute' : '$positionMinute') +
//           ':' +
//           (positionSecond < 10 ? '0$positionSecond' : '$positionSecond');
// }

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
//         print(nome);
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
