import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/EditSongScreen/edit_song_screen.dart';

Widget songMenuButton(Song song, BuildContext context,
    {Playlist? playlist, IconData? icon, bool? shouldPop}) {
  return PopupMenuButton<List>(
    onSelected: (List params) => songMenuHandleClick(params, context,
        playlist: playlist, shouldPop: shouldPop),
    icon: icon == null ? Icon(Icons.more_horiz) : Icon(icon),
    padding: EdgeInsets.zero,
    itemBuilder: (context) {
      return {'Delete Song', 'Edit Song', 'Share Song'}.map((String choice) {
        return PopupMenuItem<List>(
          value: [choice, song],
          child: Text(choice),
        );
      }).toList();
    },
  );
}

songMenuHandleClick(List params, BuildContext context,
    {Playlist? playlist, bool? shouldPop}) {
  //* params = [choice, song]
  String choice = params[0];
  Song song = params[1];

  switch (choice) {
    case 'Delete Song':
      _deleteSong(song, context, playlist: playlist, shouldPop: shouldPop);
      break;
    case 'Edit Song':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditSongScreen(song, playlist: playlist),
        ),
      );
      break;
    case 'Share Song':
      Share.shareFiles([song.path]);
      break;
  }
}

void _deleteSong(Song song, BuildContext context,
    {Playlist? playlist, bool? shouldPop}) {
  if (playlist != null) {
    if (playlist.id == 0) {
      AudioService.updateMediaItem(
          song.copyWith(isFavorite: false).toMediaItem());
      Provider.of<DBProvider>(context, listen: false)
          .updateSong(song.copyWith(isFavorite: false));
    } else {
      if (AudioService.currentMediaItem?.album == '${playlist.id}') {
        AudioService.removeQueueItem(song.toMediaItem());
      }
    }
    Provider.of<DBProvider>(context, listen: false)
        .deletePlaylistSong(playlist.id!, song.id!);
  } else {
    if (AudioService.currentMediaItem?.album == '-2') {
      AudioService.removeQueueItem(song.toMediaItem());
    }
    Provider.of<DBProvider>(context, listen: false).deleteSong(song.id!);
  }
  if (shouldPop != null && shouldPop) {
    Navigator.pop(context);
  }
}
