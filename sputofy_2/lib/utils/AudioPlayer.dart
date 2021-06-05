import 'dart:async';

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
  DBHelper _database = DBHelper();

  ConcatenatingAudioSource _playlist;

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

  _loadMediaItemsIntoQueue(final songs) {
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
    _loadQueue();
    onPlay();
  }

  _addSongToQueue(final songs) {
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
    AudioServiceBackground.setQueue(_queue);

    for (var mediaItem in newSongs) {
      _playlist
          .add(AudioSource.uri(Uri.parse(mediaItem.id), tag: mediaItem.id));
    }
    print("ho aggiunto una canzone $_playlist");
    print("ho aggiunto una queue $_queue");
    print("dovresti essre 0? $previousQueueLength");
    if (previousQueueLength == 0) _loadQueue();
  }

  _removeSongFromQueue(final songPath) {
    final lista = _playlist.sequence;

    int indexToRemove = lista.indexWhere((element) => element.tag == songPath);
    _playlist.removeAt(indexToRemove);
    _queue.removeWhere((element) => element.id == songPath);

    print(index);
    if (_playlist.length == 0) {
      _audioPlayer.pause();
      AudioServiceBackground.setQueue(_queue);
    } else {
      print("non dovrei stare qui");
      AudioServiceBackground.setQueue(_queue);
      // AudioServiceBackground.setMediaItem(_queue[index]);
      //TODO forse l'index non si aggiorna quando togli la canzone dalla _playlist
    }

    print("la queue aggiornata è $_queue");
    print("la _playlist aggiornata è $_playlist");
    print("la _playlist lunga è ${_playlist.children}");
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
          if (_playlist.length == 0) return;
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
      onStop();
    }

    AudioServiceBackground.setMediaItem(_queue[index]);
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
    final lista = _playlist.sequence;
    final newIndex = lista.indexWhere((song) => song.tag == mediaId);

    if (newIndex == -1 || index == null || newIndex == index) return;
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;

    await _audioPlayer.seek(Duration.zero, index: newIndex);
    // if (!_audioPlayer.playing) await _audioPlayer.play();
    await _audioPlayer.play();
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
        AudioServiceBackground.sendCustomEvent(playlistID);
        break;
      case 'loadPlaylist':
        _loadMediaItemsIntoQueue(arguments);
        break;
      case 'addSong':
        _addSongToQueue(arguments);
        break;
      case 'removeSong':
        print("remove Song $arguments");
        _removeSongFromQueue(arguments);
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
