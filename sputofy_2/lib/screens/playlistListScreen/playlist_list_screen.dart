import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/theme/palette.dart';

class PlaylistListScreen extends StatefulWidget {
  const PlaylistListScreen({Key? key}) : super(key: key);

  @override
  _PlaylistListScreenState createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends State<PlaylistListScreen> {
  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<DBProvider>().playlists;

    return Scaffold(
      body: Column(
        children: [
          MaterialButton(
            onPressed: () => Provider.of<DBProvider>(context, listen: false)
                .savePlaylist(Playlist(
                    null,
                    "namaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaae",
                    "cover",
                    DateTime.now())),
            child: Text(
              "Create Playlist",
              style: TextStyle(color: kAccentColor),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                Playlist playlist = playlists[index];
                Future<List<Song>> playlistSongs =
                    context.watch<DBProvider>().getPlaylistSongs(playlist.id!);
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  elevation: 4.0,
                  color: kBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => print("object"),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0)),
                              child: Image.asset(
                                'cover.jpeg',
                                width: 70.0,
                                height: 70.0,
                              ),
                            ),
                            IconButton(
                                splashColor: Colors.transparent,
                                iconSize: 48.0,
                                onPressed: () => print("bottone"),
                                icon: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  // size: 48.0,
                                )),
                          ],
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                playlist.name,
                                style: Theme.of(context).textTheme.subtitle1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              FutureBuilder<List<Song>>(
                                  future: playlistSongs,
                                  builder: (context, snapshot) {
                                    List<Song> songs = snapshot.data ?? [];

                                    return Text("${songs.length}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2);
                                  }),
                            ],
                          ),
                        ),
                        // SizedBox(width: 8.0),
                        _buildWidgetMenuButton(playlist),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetMenuButton(Playlist playlist) {
    return PopupMenuButton<List>(
      onSelected: _handleClick,
      icon: Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        return {'Delete Playlist'}.map((String choice) {
          return PopupMenuItem<List>(
            value: [choice, playlist],
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  void _handleClick(List params) {
    //* params = [choice, playlist]
    switch (params[0]) {
      case 'Delete Playlist':
        Provider.of<DBProvider>(context, listen: false)
            .deletePlaylist(params[1].id);
        break;
    }
  }
}
