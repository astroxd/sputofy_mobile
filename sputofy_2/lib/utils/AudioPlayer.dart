import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;
  StreamSubscription<SequenceState> _sequenceStateSubscription;

  List<MediaItem> _queue = [];
  int get index => _audioPlayer.currentIndex;
  MediaItem get mediaItem => index == null ? null : _queue[index];
  int _playlistID;
  int get playlistID => _playlistID == null ? null : _playlistID;

  ConcatenatingAudioSource _playlist;

  //*  Qui overridi le varie funzioni

  //* START-------------------------------------------------

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    //* params sarà la playlist
    print("onStart");
    // _loadMediaItemsIntoQueue(params);
    await _setAudioSession();
    _broadcasteMediaItemChanges();
    _propogateEventsFromAudioPlayerToAudioServiceClients();
    _performSpecialProcessingForStateTransitions();
    _firstLoad();
    // _loadQueue();
  }

  Future<void> _loadMediaItemsIntoQueue(final songs) async {
    _queue.clear();

    for (var song in songs) {
      MediaItem item = MediaItem(
        id: song['path'],
        album: "album",
        title: song['title'],
        duration: Duration(milliseconds: song['duration']),
      );
      _queue.add(item);
    }
    await _loadQueue();
    await onPlay();
  }

  Future<void> _addSongToQueue(final songs) async {
    List<MediaItem> newSongs = [];
    int previousQueueLength = _queue.length;

    for (var song in songs) {
      MediaItem item = MediaItem(
        id: song['path'],
        album: "album",
        title: song['title'],
        duration: Duration(milliseconds: song['duration']),
      );
      _queue.add(item);
      newSongs.add(item);
    }
    await AudioServiceBackground.setQueue(_queue);

    for (var mediaItem in newSongs) {
      await _playlist
          .add(AudioSource.uri(Uri.parse(mediaItem.id), tag: mediaItem.id));
    }
    // print("ho aggiunto una canzone $_playlist");
    // print("ho aggiunto una queue $_queue");
    // print("dovresti essre 0? $previousQueueLength");

    if (previousQueueLength == 0) {
      await AudioServiceBackground.setMediaItem(_queue[index]);
      await _audioPlayer.load();
    }
  }

  Future<void> _removeSongFromQueue(final songPath) async {
    final lista = _playlist.sequence;

    int indexToRemove = lista.indexWhere((element) => element.tag == songPath);
    await _playlist.removeAt(indexToRemove);
    _queue.removeWhere((element) => element.id == songPath);

    if (_playlist.length == 0) {
      _audioPlayer.pause();
      await AudioServiceBackground.setQueue(_queue);
    } else {
      await AudioServiceBackground.setQueue(_queue);
      bool hasNext = index < _playlist.length - 1;
      if (hasNext) {
        await AudioServiceBackground.setMediaItem(_queue[index]);
      } else {
        await AudioServiceBackground.setMediaItem(_queue[0]);
      }
    }
  }

  Future<void> _setAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  ///* Cambia il current item
  void _broadcasteMediaItemChanges() {
    _audioPlayer.currentIndexStream.listen((index) async {
      if (index != null)
        await AudioServiceBackground.setMediaItem(_queue[index]);
    });
  }

  ///* Legge quale evento sta facendo e fa aggiornare il badge delle notifiche
  void _propogateEventsFromAudioPlayerToAudioServiceClients() {
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) async {
      await _broadcastState();
    });
    _sequenceStateSubscription =
        _audioPlayer.sequenceStateStream.listen((event) async {
      await _broadcastState();
    });
  }

  ///* Appena finisce la playlist rimette il player alla prima canzone
  void _performSpecialProcessingForStateTransitions() {
    _audioPlayer.processingStateStream.listen((state) async {
      switch (state) {
        case ProcessingState.completed:
          if (_playlist.length == 0) return;
          await _audioPlayer.pause();
          await _audioPlayer.seek(Duration.zero,
              index: 0); //TODO dovrebbe tornare alla prima canzone
          break;
        case ProcessingState.ready:
          _skipState = null;
          break;
        default:
          print("sono del default ");
          break;
      }
    });
  }

  ///* Crea la lista di AudioSource
  Future<void> _loadQueue() async {
    await AudioServiceBackground.setQueue(_queue);
    _playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: _queue.map((item) {
          final uri = Uri.parse(item.id);
          return AudioSource.uri(uri, tag: item.id);
        }).toList());
    try {
      await _audioPlayer.setAudioSource(_playlist);
    } catch (e) {
      print('Error: $e');

      await onStop();
    }

    await AudioServiceBackground.setMediaItem(_queue[index]);
  }

  Future<void> _firstLoad() async {
    await AudioService.setShuffleMode(AudioServiceShuffleMode.none);
    await AudioService.setRepeatMode(AudioServiceRepeatMode.none);
  }

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
    if (_playlist.length == 0) return;
    // await _audioPlayer.seek(Duration.zero);
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
  Future<void> onSkipToNext() async {
    await _audioPlayer.seekToNext();
  }

  @override
  Future<void> onSkipToPrevious() async {
    await _audioPlayer.seekToPrevious();
  }

  @override
  Future<void> onSetRating(Rating rating, Map extras) {
    // TODO: implement onSetRating
    // MediaItem item =
    //     _queue[index].copyWith(rating: Rating.newHeartRating(true));
    // print(item);
    print("rating");
    return super.onSetRating(rating, extras);
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final lista = _playlist.sequence;
    final newIndex = lista.indexWhere((song) => song.tag == mediaId);

    if (newIndex == -1 || index == null || index == newIndex) return;
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;

    await _audioPlayer.seek(Duration.zero, index: newIndex);
    if (!_audioPlayer.playing) await _audioPlayer.play();
    // await _audioPlayer.play();
  }

  @override
  Future<void> onCustomAction(String funcName, dynamic arguments) async {
    switch (funcName) {
      case 'setVolume':
        await _audioPlayer.setVolume(arguments);
        AudioServiceBackground.sendCustomEvent(_audioPlayer.volume);
        break;
      case 'openPlaylist':
        await _loadMediaItemsIntoQueue(arguments); //TODO remove
        break;
      case 'getPlaylistID':
        if (playlistID != null) {
          AudioServiceBackground.sendCustomEvent(playlistID);
        }
        break;
      case 'setPlaylistID':
        _playlistID = arguments;
        await onSetShuffleMode(AudioServiceShuffleMode.none);
        AudioServiceBackground.sendCustomEvent(playlistID);
        break;
      case 'loadPlaylist':
        await _loadMediaItemsIntoQueue(arguments);
        break;
      case 'addSong':
        await _addSongToQueue(arguments);
        break;
      case 'removeSong':
        await _removeSongFromQueue(arguments);
        break;
    }
  }

  @override
  Future<void> onSetShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    switch (shuffleMode) {
      case AudioServiceShuffleMode.all:
        if (_audioPlayer.playing) {
          onSkipToQueueItem(_queue[Random().nextInt(_queue.length)].id);
        }
        await _audioPlayer.setShuffleModeEnabled(true);
        await _audioPlayer.shuffle();
        //* If is alreay playing create a new list of shuffledIndexes but the first index is always
        //* the one it is playing
        //* e.g [0,2,1], shuffle() -> [0,1,2]

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
        MediaControl(
            androidIcon: "drawable/audio_service_fast_rewind",
            label: "test",
            action: MediaAction.setRating),
      ],
      androidCompactActions: [0, 1, 2],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
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
        print("player in idle");
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        print("player in loading");
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        print("player in buffering");
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        print("player in ready");
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        print("player in completed");
        print("queue ${_playlist.children}");
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_audioPlayer.processingState}");
    }
  }
}
