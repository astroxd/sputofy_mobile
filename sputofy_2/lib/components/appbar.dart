import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/services/database.dart';

AppBar appBar() {
  return AppBar(
    title: Text(
      "Sputofy",
    ),
    actions: <Widget>[
      IconButton(onPressed: () => print(""), icon: Icon(Icons.search)),
      PopupMenuButton<String>(
        onSelected: _handleClick,
        itemBuilder: (BuildContext context) {
          return {'Download Song', 'Load Songs'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(
                choice,
              ),
            );
          }).toList();
        },
      ),
    ],
    bottom: TabBar(
      tabs: [
        Tab(
          text: "Songs",
        ),
        Tab(
          text: "Playlist",
        )
      ],
    ),
  );
}

void _handleClick(String choice) {
  switch (choice) {
    case 'Download Song':
      break;
    case 'Load Songs':
      _loadSongs();
      break;
  }
}

void _loadSongs() async {
  bool canAccesStorage = await Permission.storage.request().isGranted;
  if (canAccesStorage) {
    FilePicker.platform.getDirectoryPath().then((String? folder) {
      if (folder != null) {
        print(folder);
        _loadFolderItems(folder);
      }
    });
  }
}

void _loadFolderItems(String folder_path) async {
  DBHelper _database = DBHelper();
  List<Song> newSongs = [];
  List<Song> currentSongs = await _database.getSongs();
  AudioPlayer _audioPlayer = AudioPlayer();
  Directory folder = Directory(folder_path);

  List<FileSystemEntity> folderContent = folder.listSync();

  var contentToRemove = [];

  for (FileSystemEntity file in folderContent) {
    if (file is Directory) {
      contentToRemove.add(file);
    }

    if (!file.path.endsWith('mp3') && !file.path.endsWith('ogg')) {
      contentToRemove.add(file);
    }

    if (currentSongs.where((song) => song.path == file.path) == true) {
      contentToRemove.add(file);
    }
  }

  folderContent.removeWhere((element) => contentToRemove.contains(element));

  for (FileSystemEntity file in folderContent) {
    try {
      Duration? songDuration = await _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(file.path)));
      newSongs.add(
          Song(null, file.path, basename(file.path), '', '', songDuration));
    } catch (e) {
      print("Error on loading Song from folder $e");
    }
  }

  for (Song song in newSongs) {
    _database.saveSong(song);
  }
}
