import 'dart:io';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'package:sputofy_2/models/playlist_model.dart';

import 'package:path/path.dart' as path;

import 'package:sputofy_2/routes/folders.dart' as routes;

import 'package:sputofy_2/screens/EditSongScreen/components/move_image.dart';
import 'package:sputofy_2/screens/EditSongScreen/components/pick_image.dart';

class EditPlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  const EditPlaylistScreen(this.playlist, {Key? key}) : super(key: key);

  @override
  _EditPlaylistScreenState createState() => _EditPlaylistScreenState();
}

class _EditPlaylistScreenState extends State<EditPlaylistScreen> {
  TextEditingController controller = TextEditingController();
  File? selectedImage;
  Playlist get playlist => widget.playlist;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: widgetEdit(playlist),
      ),
    );
  }

  Widget widgetEdit(Playlist playlist) {
    Uri? playlistImage = playlist.cover;

    if (selectedImage != null) {
      playlistImage = selectedImage?.uri;
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
                'Edit Playlist',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              IconButton(
                onPressed: () async {
                  Playlist updatedPlaylist;
                  if (selectedImage != null) {
                    String playlistPath = path.join(
                        await routes.playlistPath(), '${playlist.id}.jpg');

                    File newFile =
                        await moveImage(selectedImage!, playlistPath);

                    updatedPlaylist = playlist.copyWith(
                      cover: newFile.uri,
                      name: controller.text,
                    );
                  } else {
                    updatedPlaylist = playlist.copyWith(name: controller.text);
                  }

                  Provider.of<DBProvider>(context, listen: false)
                      .updatePlaylist(updatedPlaylist);
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
            child: playlistImage != null
                ? Image.file(
                    File.fromUri(playlistImage),
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
          Tooltip(
            message: 'Favorite playlist title can\'t be changed',
            child: TextField(
              enabled: playlist.id == 0 ? false : true,
              controller: controller..text = playlist.name,
            ),
          ),
        ],
      ),
    );
  }
}
