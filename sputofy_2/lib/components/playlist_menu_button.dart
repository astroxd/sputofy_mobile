import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'package:sputofy_2/models/playlist_model.dart';

import 'package:sputofy_2/screens/EditPlaylistScreen/edit_playlist_screen.dart';

Widget playlistMenuButton(
    Playlist playlist, BuildContext context, bool shouldPop) {
  return PopupMenuButton<List>(
    onSelected: (List params) =>
        playlistMenuHandleClick(params, context, shouldPop),
    icon: Icon(Icons.more_vert),
    padding: EdgeInsets.zero,
    itemBuilder: (context) {
      return {'Delete Playlist', 'Edit Playlist', 'Hide Playlist'}
          .map((String choice) {
        return PopupMenuItem<List>(
          value: [choice, playlist],
          child: Text(choice),
        );
      }).toList();
    },
  );
}

playlistMenuHandleClick(List params, BuildContext context, bool shouldPop) {
  //* params = [choice, playlist]
  String choice = params[0];
  Playlist playlist = params[1];
  switch (choice) {
    case 'Delete Playlist':
      if (playlist.id == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Favorite playlist can't be deleted"),
            action: SnackBarAction(
              label: 'HIDE',
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      } else {
        Provider.of<DBProvider>(context, listen: false)
            .deletePlaylist(playlist.id!);
        if (shouldPop) Navigator.pop(context);
      }
      break;
    case 'Edit Playlist':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPlaylistScreen(playlist),
        ),
      );
      break;
    case 'Hide Playlist':
      Provider.of<DBProvider>(context, listen: false)
          .updatePlaylist(playlist.copyWith(isHidden: true));
      break;
  }
}
