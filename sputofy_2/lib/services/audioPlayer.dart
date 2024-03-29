import 'dart:async';
import 'dart:math';
import 'dart:io';

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
  late Future<SharedPreferences> _prefs;

  List<MediaItem> _queue = [];
  int? get index => _audioPlayer.currentIndex;
  MediaItem? get mediaItem => index == null ? null : _queue[index!];

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

//* START --------------------------------------------------------------------

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    _prefs = SharedPreferences.getInstance();
    await _setAudioSession();
    _propogateEventsFromAudioPlayerToAudioServiceClients();
    _performSpecialProcessingForStateTransitions();

    await _firstLoad();

    _broadcasteMediaItemChanges();
  }

  Future<void> _setAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    session.becomingNoisyEventStream.listen((_) {
      if (_audioPlayer.playing) onPause();
    });
    //TODO REVIEW

    // session.interruptionEventStream.listen((event) {
    // });
  }

  ///* change current item
  void _broadcasteMediaItemChanges() async {
    final pref = await _prefs;
    _audioPlayer.currentIndexStream.listen((index) async {
      if (index != null) {
        if (!File(_queue[index].id).existsSync()) {
          if (_audioPlayer.hasNext) {
            //* [prev,curr,next]
            onSkipToNext();
          } else if (_audioPlayer.hasPrevious) {
            //* [prev,curr]
            _audioPlayer.seek(Duration.zero, index: 0);
          } else {
            //* [curr] pause because there are no songs
            onPause();
          }
        } else {
          await AudioServiceBackground.setMediaItem(_queue[index]);

          pref.setString('song_path', _queue[index].id);
        }
      }
    });
  }

  ///* update notification badge
  void _propogateEventsFromAudioPlayerToAudioServiceClients() {
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) async {
      if (_audioPlayer.sequence != null) {
        await _broadcastState();
      }
    });
    _sequenceStateSubscription =
        _audioPlayer.sequenceStateStream.listen((event) async {
      if (_audioPlayer.sequence != null) {
        await _broadcastState();
      }
    });
  }

  ///* if playlist end skip to first song
  void _performSpecialProcessingForStateTransitions() {
    _audioPlayer.processingStateStream.listen((state) async {
      switch (state) {
        case ProcessingState.completed:
          if (_playlist.length == 0) break;
          await _audioPlayer.pause();
          await _audioPlayer.seek(Duration.zero, index: 0);
          break;
        case ProcessingState.ready:
          _skipState = null;
          break;
        default:
          // print("sono del default ");
          break;
      }
    });
  }

  Future<void> _firstLoad() async {
    final pref = await _prefs;
    DBHelper _database = DBHelper();
    List<Song> songs = await _database.getSongs();
    if (songs.isEmpty) return;

    List<MediaItem> mediaItems = [];
    for (final song in songs) {
      if (File(song.path).existsSync()) {
        mediaItems.add(song.toMediaItem());
      } else {
        await _database.deleteSong(song.id!);
      }
    }
    await onUpdateQueue(mediaItems).then((value) async {
      String? lastPlayedSong = pref.getString('song_path');
      if (lastPlayedSong != null) {
        onSkipToQueueItem(lastPlayedSong);
      }
    });
  }

//* ---------------------------------------------------------------------------

//* SERVICE FUNCTIONS ---------------------------------------------------------

  @override
  Future<void> onTaskRemoved() {
    //TODO review
    if (!AudioServiceBackground.state.playing) {
      onStop();
    }
    return super.onTaskRemoved();
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.dispose();
    _eventSubscription.cancel();
    _sequenceStateSubscription.cancel();
    await _broadcastState();
    await super.onStop();
  }

//* ---------------------------------------------------------------------------

//* SIMPLE ACTIONS ------------------------------------------------------------

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
  }

//* ---------------------------------------------------------------------------

//* QUEUE MANIPULATION --------------------------------------------------------
  @override
  Future<void> onUpdateQueue(List<MediaItem> songs) async {
    _queue = songs;

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
      // print('Error: $e');

      await onStop();
    }
    await AudioServiceBackground.setMediaItem(_queue[index!]);
  }

  @override
  Future<void> onRemoveQueueItem(MediaItem song) async {
    final playlistSongs = _playlist.sequence;

    int indexToRemove =
        playlistSongs.indexWhere((element) => element.tag == song.id);
    if (indexToRemove == -1) return;
    await _playlist.removeAt(indexToRemove);
    _queue.removeWhere((element) => element.id == song.id);

    if (_playlist.length == 0) {
      await _audioPlayer.pause();
      await AudioServiceBackground.setQueue(_queue);
    } else {
      await AudioServiceBackground.setQueue(_queue);
      bool hasNext = index! < _playlist.length;
      if (hasNext) {
        await AudioServiceBackground.setMediaItem(_queue[index!]);
      } else {
        await AudioServiceBackground.setMediaItem(_queue[0]);
      }
    }
  }

  @override
  Future<void> onAddQueueItem(MediaItem mediaItem) async {
    _queue.add(mediaItem);
    await AudioServiceBackground.setQueue(_queue);

    _playlist.add(AudioSource.uri(Uri.parse(mediaItem.id), tag: mediaItem.id));
  }

  @override
  Future<void> onUpdateMediaItem(MediaItem _mediaItem) async {
    int _index = _queue.indexWhere((element) => element.id == _mediaItem.id);

    if (_index == -1) return;
    _queue[_index] = _mediaItem;

    AudioServiceBackground.setMediaItem(mediaItem!);
    AudioServiceBackground.setQueue(_queue);
    await _broadcastState();
  }

//* ---------------------------------------------------------------------------

//* SKIP ACTIONS --------------------------------------------------------------

  @override
  Future<void> onSkipToNext() async {
    if (_audioPlayer.loopMode == LoopMode.one) {
      //* If has next
      if (_audioPlayer.effectiveIndices!.reversed.first != index) {
        _audioPlayer.seek(Duration.zero, index: index! + 1);
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
        _audioPlayer.seek(Duration.zero, index: index! - 1);
      }
    } else {
      await _audioPlayer.seekToPrevious();
    }
    if (!_audioPlayer.playing) await AudioService.play();
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final playlistSongs = _playlist.sequence;
    final newIndex = playlistSongs.indexWhere((song) => song.tag == mediaId);

    if (newIndex == -1 || index == newIndex) return;
    _skipState = newIndex > index!
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;

    await _audioPlayer.seek(Duration.zero, index: newIndex);
  }

//* ---------------------------------------------------------------------------

  @override
  Future<void> onSetRating(Rating rating, Map? extras) async {
    //TODO review
    print('Rate');

    return super.onSetRating(rating, extras);
  }

//* PLAYBACK MODE -------------------------------------------------------------
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

//* ---------------------------------------------------------------------------

//* CUSTOM ACTIONS ------------------------------------------------------------

  @override
  Future<void> onCustomAction(String funcName, dynamic arguments) async {
    switch (funcName) {
      case 'shufflePlay':
        await _shufflePlay();
        break;
    }
  }

  _shufflePlay() async {
    if (_queue.length > 1) {
      await onSkipToQueueItem(_queue[Random().nextInt(_queue.length)].id);
    }
    await _audioPlayer.shuffle();
    await _audioPlayer.setShuffleModeEnabled(true);
    if (!_audioPlayer.playing) await AudioService.play();
    //* If is alreay playing create a new list of shuffledIndexes but the first index is always
    //* the one it is playing
    //* e.g [0,2,1], shuffle() -> [0,1,2]
  }

//* ---------------------------------------------------------------------------

//* SYSTEM ACTIONS ------------------------------------------------------------

  ///* change notification badge
  Future<void> _broadcastState() async {
    bool isFavorite = false;
    _queue.isEmpty
        ? isFavorite = false
        : isFavorite = mediaItem?.rating?.hasHeart() ?? false;
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl(
          androidIcon: isFavorite
              ? "mipmap/ic_favorite_remove"
              : "mipmap/ic_favorite_add",
          label: "Rating",
          action: MediaAction.setRating,
        ),
      ],
      androidCompactActions: [0, 1, 2],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.setRating,
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

  ///* map audioPlayer processes to audioSerivce processes
  AudioProcessingState? _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_audioPlayer.processingState) {
      case ProcessingState.idle:
        // print("player in idle");
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        // print("player in loading");
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        // print("player in buffering");
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        // print("player in ready");
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        // print("player in completed");
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_audioPlayer.processingState}");
    }
  }

//* ---------------------------------------------------------------------------

}

class PlayingMediaItem {
  MediaItem? playingItem;
  Duration? position;
  PlaybackState? playbackState;
  PlayingMediaItem(this.playingItem, this.position, this.playbackState);
}
