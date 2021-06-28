import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
      }
    });
  }
}
