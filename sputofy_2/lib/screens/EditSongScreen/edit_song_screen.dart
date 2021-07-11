import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';

class EditSongScreen extends StatefulWidget {
  final Song song;
  const EditSongScreen(this.song, {Key? key}) : super(key: key);

  @override
  _EditSongScreenState createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  TextEditingController controller = TextEditingController();
  Uint8List? selectedImage;
  Song get song => widget.song;
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
    Uint8List? songImage = song.cover;

    if (selectedImage != null) {
      songImage = selectedImage;
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
                onPressed: () {
                  Song updatedSong = song.copyWith(
                    cover: selectedImage,
                    title: controller.text,
                  );
                  Provider.of<DBProvider>(context, listen: false)
                      .updateSong(updatedSong);
                  AudioService.updateMediaItem(updatedSong.toMediaItem());
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.check),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          if (songImage != null) ...[
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
                songImage,
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
                'cover.jpeg',
                width: 230.0,
                height: 230.0,
              ),
            ),
          ],
          SizedBox(height: 16.0),
          TextField(
            controller: controller..text = song.title,
          )
        ],
      ),
    );
  }
}
