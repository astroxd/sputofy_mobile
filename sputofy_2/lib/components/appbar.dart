import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/services/database.dart';
import 'package:sputofy_2/theme/palette.dart';

AppBar appBar(int tabIndex, BuildContext context) {
  return AppBar(
    title: Text("Sputofy"),
    actions: <Widget>[
      IconButton(onPressed: () => print(""), icon: Icon(Icons.search)),
      tabIndex == 0
          ? PopupMenuButton<String>(
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
            )
          : IconButton(
              onPressed: () => _showNewPlaylistDialog(context),
              icon: Icon(Icons.add),
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
      //TODO basename(file.path) => song.mp3
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

void _showNewPlaylistDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return NewPlaylistDialog();
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
    ),
  );
}

class NewPlaylistDialog extends StatefulWidget {
  const NewPlaylistDialog({Key? key}) : super(key: key);

  @override
  _NewPlaylistDialogState createState() => _NewPlaylistDialogState();
}

class _NewPlaylistDialogState extends State<NewPlaylistDialog> {
  var textController = TextEditingController(text: '');
  bool isValid = true;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Create Playlist",
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: EdgeInsets.only(bottom: 0.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'my beautiful playlist',
                hintStyle: TextStyle(color: kPrimaryColor),
                errorText: isValid ? null : 'Playlist name can\'t be empty',
              ),
              autofocus: true,
              controller: textController,
            ),
          ),
          SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MaterialButton(
                color: kSecondaryColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("cancel"),
              ),
              MaterialButton(
                onPressed: () {
                  if (textController.text.isEmpty) {
                    setState(() {
                      isValid = false;
                    });
                  } else {
                    setState(() {
                      isValid = true;
                    });
                    _savePlaylist(textController.text, context);
                  }
                },
                child: Text("Save"),
                color: kAccentColor,
              ),
            ],
          )
        ],
      ),
    );
  }
}

_savePlaylist(String playlistName, BuildContext context) {
  Playlist playlist = Playlist(null, playlistName, '', DateTime.now());
  Provider.of<DBProvider>(context, listen: false).savePlaylist(playlist);
  Navigator.pop(context);
}
