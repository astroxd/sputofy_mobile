import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:sputofy_2/services/database.dart';
import 'package:sputofy_2/models/song_model.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioProcessingState? _skipState;
  late StreamSubscription<PlaybackEvent> _eventSubscription;
  late StreamSubscription<SequenceState?> _sequenceStateSubscription;
  Future<SharedPreferences>? _prefs;

  List<MediaItem> _queue = [];
  int get index => _audioPlayer.currentIndex ?? -1;
  MediaItem? get mediaItem => _queue[index];
  int? _playlistID;
  int? get playlistID => _playlistID == null ? null : _playlistID;

  late ConcatenatingAudioSource _playlist;

  //*  Qui overridi le varie funzioni

  //* START-------------------------------------------------

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    //* params sarà la playlist
    print("onStart");
    // _loadMediaItemsIntoQueue(params);
    // SharedPreferences.setMockInitialValues(<String, dynamic>{'playlist': 5});
    _prefs = SharedPreferences.getInstance();
    await _setAudioSession();
    await _firstLoad();

    _broadcasteMediaItemChanges();
    _propogateEventsFromAudioPlayerToAudioServiceClients();
    _performSpecialProcessingForStateTransitions();
    // _loadQueue();
  }

  Future<void> _loadMediaItemsIntoQueue(final songs) async {
    _queue.clear();

    for (var song in songs) {
      MediaItem item = MediaItem(
        id: song['path'],
        album: '${playlistID ?? -3}',
        title: song['title'],
        duration: Duration(milliseconds: song['duration']),
        extras: <String, dynamic>{
          'id': song['id'],
        },
      );
      _queue.add(item);
    }
    await _loadQueue();
    // await onPlay();
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> songs) async {
    List<MediaItem> newSongs = [];
    int previousQueueLength = _queue.length;

    for (var song in songs) {
      _queue.add(song);
      newSongs.add(song);
    }
    await AudioServiceBackground.setQueue(_queue);

    for (var mediaItem in newSongs) {
      await _playlist
          .add(AudioSource.uri(Uri.parse(mediaItem.id), tag: mediaItem.id));
    }

    if (previousQueueLength == 0) {
      await AudioServiceBackground.setMediaItem(_queue[index]);
      await _audioPlayer.load();
    }
  }

  @override
  Future<void> onRemoveQueueItem(MediaItem song) async {
    final lista = _playlist.sequence;

    int indexToRemove = lista.indexWhere((element) => element.tag == song.id);
    await _playlist.removeAt(indexToRemove);
    _queue.removeWhere((element) => element.id == song.id);

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
  void _broadcasteMediaItemChanges() async {
    final pref = await _prefs!;
    _audioPlayer.currentIndexStream.listen((index) async {
      if (index != null) {
        await AudioServiceBackground.setMediaItem(_queue[index]);

        pref.setString('song_path', _queue[index].id);
        // pref.setString('song_title', _queue[index].title);
        // pref.setInt('song_duration', _queue[index].duration.inMilliseconds);
      }
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
    final pref = await _prefs!;
    DBHelper _database = DBHelper();
    List<Song> songs = await _database.getSongs();
    List<Map> mapSongs = [];
    for (final song in songs) {
      mapSongs.add(song.toMap());
    }

    await _loadMediaItemsIntoQueue(mapSongs).then((value) async =>
        AudioService.skipToQueueItem(pref.getString('song_path')!));
  }

//* ---------------------------------------------------------------------------

  @override
  Future<void> onTaskRemoved() async {
    if (!AudioServiceBackground.state.playing) {
      print("sto chiudendo #############");
      await onStop();
    }
    print("sto chiudendo #############");
    return super.onTaskRemoved();
  }

  @override
  Future<void> onStop() async {
    print("onStop");
    await _audioPlayer.dispose();
    _eventSubscription.cancel();
    _sequenceStateSubscription.cancel();
    await _broadcastState();
    print("Ultimo onStop");
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
  Future<void> onSkipToNext() async {
    if (_audioPlayer.loopMode == LoopMode.one) {
      //* If has next
      if (_audioPlayer.effectiveIndices!.reversed.first != index) {
        _audioPlayer.seek(Duration.zero, index: index + 1);
      }
    } else {
      await _audioPlayer.seekToNext();
    }
    if (!_audioPlayer.playing) await AudioService.play();
  }

  @override
  Future<void> onSkipToPrevious() async {
    if (_audioPlayer.loopMode == LoopMode.one) {
      //* If has next
      if (_audioPlayer.effectiveIndices!.first != index) {
        _audioPlayer.seek(Duration.zero, index: index - 1);
      }
    } else {
      await _audioPlayer.seekToPrevious();
    }
    if (!_audioPlayer.playing) await AudioService.play();
  }

  @override
  Future<void> onSetRating(Rating rating, Map? extras) {
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

    if (newIndex == -1 || index == newIndex) return;
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;

    await _audioPlayer.seek(Duration.zero, index: newIndex);
  }

  @override
  Future<void> onCustomAction(String funcName, dynamic arguments) async {
    switch (funcName) {
      case 'setVolume': //TODO remove
        await _audioPlayer.setVolume(arguments);
        AudioServiceBackground.sendCustomEvent(_audioPlayer.volume);
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
        await _loadMediaItemsIntoQueue(arguments);
        break;
      case 'shufflePlay':
        await _shufflePlay();
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
  }

  _shufflePlay() async {
    if (_queue.length > 1)
      await onSkipToQueueItem(_queue[Random().nextInt(_queue.length)].id);
    await _audioPlayer.shuffle();
    await _audioPlayer.setShuffleModeEnabled(true);
    if (!_audioPlayer.playing) await AudioService.play();
    //* If is alreay playing create a new list of shuffledIndexes but the first index is always
    //* the one it is playing
    //* e.g [0,2,1], shuffle() -> [0,1,2]
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
    // _audioPlayer.setShuffleModeEnabled(false);
  }

  _getRepeatMode() {
    switch (_audioPlayer.loopMode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
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

  ///* Prende il processo che sta facendo
  AudioProcessingState? _getProcessingState() {
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
