import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/components/playlist_dialog.dart';
import 'package:sputofy_2/components/show_hidden_playlists.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/theme/palette.dart';

import 'components/playlist_tile.dart';

class PlaylistListScreen extends StatefulWidget {
  const PlaylistListScreen({Key? key}) : super(key: key);

  @override
  _PlaylistListScreenState createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends State<PlaylistListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DBProvider>(
        builder: (context, database, child) {
          List<Playlist> playlists = database.playlists;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              PlaylistList(context, playlists),
              SizedBox(height: 32.0),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNewPlaylistDialog(context),
        child: Icon(Icons.add),
        elevation: 4.0,
      ),
    );
  }
}

class PlaylistList extends StatelessWidget {
  final BuildContext context;
  final List<Playlist> playlists;

  const PlaylistList(this.context, this.playlists, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!playlists
        .map((playlist) => playlist.isHidden)
        .toList()
        .contains(false)) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () => showNewPlaylistDialog(context),
                child: Text(
                  'Create Playlist...',
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: kSecondaryColor,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showHiddenPlaylist(context, importedPlaylists: playlists);
                },
                child: Text(
                  'Show Hidden Playlists...',
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: kSecondaryColor,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            Playlist playlist = playlists[index];
            if (!playlist.isHidden)
              return PlaylistTile(playlist);
            else
              return Container(height: 0.0);
          },
        ),
      );
    }
  }
}
