import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/providers/provider.dart';

class EditPlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  const EditPlaylistScreen(this.playlist, {Key? key}) : super(key: key);

  @override
  _EditPlaylistScreenState createState() => _EditPlaylistScreenState();
}

class _EditPlaylistScreenState extends State<EditPlaylistScreen> {
  TextEditingController controller = TextEditingController();
  Uint8List? selectedImage;
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
    Uint8List? playlistImage = playlist.cover;

    if (selectedImage != null) {
      playlistImage = selectedImage;
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
                onPressed: () {
                  Playlist updatedPlaylist = playlist.copyWith(
                    cover: selectedImage,
                    name: controller.text,
                  );
                  Provider.of<DBProvider>(context, listen: false)
                      .updatePlaylist(updatedPlaylist);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.check),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          if (playlistImage != null) ...[
            GestureDetector(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  withData: true,
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'jpeg', 'png'],
                );
                if (result != null) {
                  Uint8List? imageBytes = result.files.single.bytes;
                  setState(() {
                    selectedImage = imageBytes;
                  });
                }
              },
              child: Image.memory(
                playlistImage,
                width: 230.0,
                height: 230.0,
              ),
            )
          ] else ...[
            GestureDetector(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  withData: true,
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'jpeg', 'png'],
                );
                if (result != null) {
                  Uint8List? imageBytes = result.files.single.bytes;
                  setState(() {
                    selectedImage = imageBytes;
                  });
                }
              },
              child: Image.asset(
                'missing_image.png',
                width: 230.0,
                height: 230.0,
              ),
            ),
          ],
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
