import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/DatabaseProvider.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;
  StreamSubscription<SequenceState> _sequenceStateSubscription;
  StreamSubscription<List<Song>> _listSongs;

  List<MediaItem> _queue = [];
  int get index => _audioPlayer.currentIndex;
  MediaItem get mediaItem => index == null ? null : _queue[index];
  int playlistID;
  Stream test;
  DBHelper _database = DBHelper();

  //*  Qui overridi le varie funzioni

  //* START-------------------------------------------------

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    //* params sarà la playlist
    print("onStart");
    // _loadMediaItemsIntoQueue(params);
    await _setAudioSession();
    _broadcaseMediaItemChanges();
    _propogateEventsFromAudioPlayerToAudioServiceClients();
    _performSpecialProcessingForStateTransitions();
    // _loadQueue();
  }

  // _loadMediaItemsIntoQueue(Map<String, dynamic> params) {
  //   _queue.clear();
  //   final List mediaItems = params['data'];
  //   for (var item in mediaItems) {
  //     final mediaItem = MediaItem.fromJson(item);
  //     final newItem = mediaItem.copyWith(rating: Rating.newHeartRating(true));
  //     // _queue.add(mediaItem);
  //     _queue.add(newItem);
  //   }
  // }
  _loadMediaItemsIntoQueue(final mediaItems) async {
    if (mediaItems != playlistID) {
      _queue.clear();
      DBHelper _database = DBHelper();
      List<Song> songs = await _database.getPlaylistSongs(mediaItems);
      print(songs);

      for (var song in songs) {
        MediaItem item = MediaItem(
            id: song.path,
            album: "album",
            title: song.title,
            duration: song.duration);
        _queue.add(item);
      }
      playlistID = mediaItems;
      _loadQueue();
      onPlay();
      print(_queue);
    } else
      print("non faccio niente");

    // for (var item in songs) {
    //   MediaItem mediaItem = MediaItem.fromJson(item);
    //   //   // MediaItem mediaItem = MediaItem(
    //   //   //   id: item.path,
    //   //   //   album: "album",
    //   //   //   title: item.title,
    //   //   //   duration: item.duration,
    //   //   // );
    //   //   // final newItem = mediaItem.copyWith(rating: Rating.newHeartRating(true));
    //   _queue.add(mediaItem);
    //   // print(mediaItem);
    // }
    // print(_queue);
    // print(mediaItems);
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

  ///* Legge quale evento sta facendo e fa aggiornare il badge delle notifiche
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
    _listSongs.cancel();
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
      case 'openPlaylist':
        await _loadMediaItemsIntoQueue(arguments);

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
