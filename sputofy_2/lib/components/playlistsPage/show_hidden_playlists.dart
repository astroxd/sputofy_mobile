import 'package:flutter/material.dart';

import 'package:sputofy_2/providers/provider.dart';
import 'package:provider/provider.dart';

import 'package:sputofy_2/models/playlist_model.dart';

void showHiddenPlaylist(BuildContext context,
    {List<Playlist>? importedPlaylists}) {
  List<Playlist> playlists = [];

  if (importedPlaylists == null) {
    playlists = Provider.of<DBProvider>(context, listen: false).playlists;
  } else {
    playlists = importedPlaylists;
  }

  playlists.forEach((playlist) {
    Provider.of<DBProvider>(context, listen: false)
        .updatePlaylist(playlist.copyWith(isHidden: false));
  });
}
