import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:audio_service/audio_service.dart';

import 'package:provider/provider.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';

import 'package:sputofy_2/routes/folders.dart' as routes;

import 'components/move_image.dart';
import 'components/pick_image.dart';

class EditSongScreen extends StatefulWidget {
  final Song song;
  final Playlist? playlist;
  const EditSongScreen(this.song, {Key? key, this.playlist}) : super(key: key);

  @override
  _EditSongScreenState createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  File? selectedImage;
  TextEditingController controller = TextEditingController();
  Song get song => widget.song;
  Playlist? get playlist => widget.playlist == null
      ? null
      : widget.playlist; //* Used for update song in playlist songs list
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: widgetEdit(song),
      ),
    );
  }

  Widget widgetEdit(Song song) {
    Uri? songImage = song.cover;

    if (selectedImage != null) {
      songImage = selectedImage?.uri;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios),
              ),
              Text(
                'Edit Song',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              IconButton(
                onPressed: () async {
                  Song updatedSong;

                  if (selectedImage != null) {
                    String songPath =
                        path.join(await routes.songPath(), '${song.id}.jpg');

                    File newFile = await moveImage(selectedImage!, songPath);

                    updatedSong = song.copyWith(
                      cover: newFile.uri,
                      title: controller.text,
                    );
                  } else {
                    updatedSong = song.copyWith(
                      title: controller.text,
                    );
                  }

                  Provider.of<DBProvider>(context, listen: false).updateSong(
                    updatedSong,
                    playlist: playlist,
                  );
                  AudioService.updateMediaItem(updatedSong.toMediaItem());
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.check),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          GestureDetector(
            onTap: () async {
              pickImage().then((pickedImage) {
                if (pickedImage != null) {
                  setState(() {
                    imageCache?.clear();
                    imageCache?.clearLiveImages();
                    selectedImage = pickedImage;
                  });
                }
              });
            },
            child: songImage != null
                ? Image.file(
                    File.fromUri(songImage),
                    width: 230.0,
                    height: 230.0,
                  )
                : Image.asset(
                    'missing_image.png',
                    width: 230.0,
                    height: 230.0,
                  ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: controller..text = song.title,
          ),
        ],
      ),
    );
  }
}
