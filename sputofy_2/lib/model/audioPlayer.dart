import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sputofy_2/model/playlistSongsModel.dart';

class MyAudio extends ChangeNotifier {
  Duration songLength;
  Duration position;

  int indexSongSelected = -1;

  bool isPlaying = false;

  bool isShuffle = false;
  bool isLoop = false;
  bool isRepeatOne = false;

  List<PlaylistSongs> songList = [];
  AudioPlayer _player = AudioPlayer();
  AudioCache cache;
  List<Duration> songDuration = [];

  MyAudio() {
    // print("init");
    initAudio();
    // loadSongs();
  }

  initAudio() {
    // cache = AudioCache(fixedPlayer: _player);
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

  loadSongs() async {
    // songList.forEach((song) => _player.play(song.songPath, isLocal: true));
    // playSong(0);
    for (int i = 0; i < songList.length; i++) {
      playSong(i);
      int durata = await _player.getDuration();
      print(durata);
      // songDuration.add(_player.getDuration());
      debugPrint(songList[i].songPath);
    }
  }

  // playSong(int index) {
  //   indexSongSelected = index;
  //   cache.play(songList[indexSongSelected].path);
  // }

  playSong(int index) {
    indexSongSelected = index;
    _player.play(songList[index].songPath, isLocal: true);
    // cache.play(songList[index].songPath);
  }

//TODO
  pathPlay(String path) {
    _player.play(path, isLocal: true);
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

  // getStrDuration() {
  //   String strDuration = '00:00';
  //   int durationMinute = songList[indexSongSelected].durationSecond >= 60
  //       ? songList[indexSongSelected].durationSecond ~/ 60
  //       : 0;
  //   int durationSecond = songList[indexSongSelected].durationSecond >= 60
  //       ? songList[indexSongSelected].durationSecond % 60
  //       : songList[indexSongSelected].durationSecond;
  //   return strDuration =
  //       (durationMinute < 10 ? '0$durationMinute' : '$durationMinute') +
  //           ':' +
  //           (durationSecond < 10 ? "0$durationSecond" : "$durationSecond");
  // }

  // getPlaylistLength() {
  //   int totalTimeSeconds = 0;
  //   String totalTime = '0 hours';
  //   for (var i = 0; i < songList.length; i++) {
  //     totalTimeSeconds += songList[i].durationSecond;
  //   }
  //   if (totalTimeSeconds < 3600) {
  //     return totalTime =
  //         ("${(totalTimeSeconds / 60).toStringAsFixed(1)} minutes");
  //   } else {
  //     return totalTime =
  //         ("${(totalTimeSeconds / 3600).toStringAsFixed(1)} hours");
  //   }
  // }
}

class Music {
  String title;
  String artist;
  int durationSecond;
  String path;
  Music(this.title, this.artist, this.durationSecond, this.path);
}
