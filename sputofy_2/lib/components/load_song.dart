import 'dart:io';
import 'package:path/path.dart';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/services/database.dart';

void loadSongs(BuildContext context) async {
  bool canAccesStorage = await Permission.storage.request().isGranted;
  if (canAccesStorage) {
    FilePicker.platform.getDirectoryPath().then((String? folder) {
      if (folder != null) {
        print(folder);
        _loadFolderItems(folder, context);
      }
    });
  }
}

void _loadFolderItems(String folder_path, BuildContext context) async {
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

    if (currentSongs.map((song) => song.path).toList().contains(file.path)) {
      contentToRemove.add(file);
    }
  }

  folderContent.removeWhere((element) => contentToRemove.contains(element));
  folderContent.forEach((element) {
    print("ADD $element");
  });
  contentToRemove.forEach((element) {
    print("DELETE $element");
  });

  for (FileSystemEntity file in folderContent) {
    try {
      Duration? songDuration = await _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(file.path)));
      String baseFileName = basename(file.path);
      String fileName =
          baseFileName.substring(0, baseFileName.lastIndexOf('.'));

      newSongs.add(Song(null, file.path, fileName, '', '', songDuration));
    } catch (e) {
      print("Error on loading Song from folder $e");
    }
  }

  for (Song song in newSongs) {
    Provider.of<DBProvider>(context, listen: false).saveSong(song);
  }
  AudioService.addQueueItems(newSongs.map((e) => e.toMediaItem()).toList());
}