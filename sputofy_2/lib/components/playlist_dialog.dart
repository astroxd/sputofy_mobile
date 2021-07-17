import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/theme/palette.dart';

void showNewPlaylistDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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
            'Create Playlist',
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
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MaterialButton(
                color: kPrimaryColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                ),
                textColor: kThirdColor,
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
                child: Text('Save'),
                color: kAccentColor,
                textColor: kThirdColor,
              ),
            ],
          )
        ],
      ),
    );
  }
}

_savePlaylist(String playlistName, BuildContext context) {
  Playlist playlist = Playlist(
      null,
      playlistName,
      null,
      // File('/storage/emulated/0/download/album.jpg').readAsBytesSync(),
      DateTime.now());
  Provider.of<DBProvider>(context, listen: false).savePlaylist(playlist);
  Navigator.pop(context);
}
