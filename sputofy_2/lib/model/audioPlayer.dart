import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MyAudio extends ChangeNotifier {
  Duration songLength;
  Duration position;

  int indexSongSelected = -1;

  bool isPlaying = false;

  bool isShuffle = false;
  bool isLoop = false;
  bool isRepeatOne = false;

  List<Music> songList = [
    Music('song3', 'Taylor Swift', 9, 'song3.mp3'),
    Music('song2', 'Taylor Swift', 264, 'song2.mp3'),
    Music('song1', 'Taylor Swift', 239, 'song1.mp3'),
  ];
  AudioPlayer _player = AudioPlayer();
  AudioCache cache;

  MyAudio() {
    initAudio();
  }

  initAudio() {
    cache = AudioCache(fixedPlayer: _player);
    _player.onDurationChanged.listen((Duration d) {
      songLength = d;
      notifyListeners();
    });
    _player.onAudioPositionChanged.listen((Duration p) {
      position = p;
      notifyListeners();
    });
    _player.onPlayerCompletion.listen((event) {
      skipToNext();
    });

    _player.onPlayerStateChanged.listen((playerState) {
      if (playerState == AudioPlayerState.PAUSED) {
        isPlaying = false;
      }
      if (playerState == AudioPlayerState.PLAYING) {
        isPlaying = true;
      }
      notifyListeners();
    });
  }

  playSong(int index) {
    indexSongSelected = index;
    cache.play(songList[indexSongSelected].path);
  }

  pauseSong() {
    _player.pause();
  }

  resumeSong() {
    _player.resume();
  }

  skipToNext() {
    int lastSong = songList.length;

    if (indexSongSelected + 1 < lastSong) {
      indexSongSelected++;
      playSong(indexSongSelected);
      isPlaying = true;
    } else {
      isPlaying = false;
      //far fermare il player
    }
  }

  skitToPrevious() {
    if (indexSongSelected != 0) {
      indexSongSelected--;
      playSong(indexSongSelected);
      isPlaying = true;
    } else {
      isPlaying = false;
      //far fermare il player
    }
  }

  seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    _player.seek(newPos);
  }

  getStrPosition() {
    String strPosition = '00:00';
    int positionMinute = position.inSeconds ~/ 60;
    int positionSecond =
        positionMinute > 0 ? position.inSeconds % 60 : position.inSeconds;
    return strPosition =
        (positionMinute < 10 ? '0$positionMinute' : '$positionMinute') +
            ':' +
            (positionSecond < 10 ? '0$positionSecond' : '$positionSecond');
  }

  getStrDuration() {
    String strDuration = '00:00';
    int durationMinute = songList[indexSongSelected].durationSecond >= 60
        ? songList[indexSongSelected].durationSecond ~/ 60
        : 0;
    int durationSecond = songList[indexSongSelected].durationSecond >= 60
        ? songList[indexSongSelected].durationSecond % 60
        : songList[indexSongSelected].durationSecond;
    return strDuration =
        (durationMinute < 10 ? '0$durationMinute' : '$durationMinute') +
            ':' +
            (durationSecond < 10 ? "0$durationSecond" : "$durationSecond");
  }
}

class Music {
  String title;
  String artist;
  int durationSecond;
  String path;
  Music(this.title, this.artist, this.durationSecond, this.path);
}
