import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/playlistSongsScreen/playlist_songs_screen.dart';
import 'package:sputofy_2/theme/palette.dart';

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
              PlaylistList(context, playlists),
            ],
          );
        },
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
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          Playlist playlist = playlists[index];
          return Card(
            // margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            elevation: 4.0,
            color: kSecondaryBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistSongsScreen(playlist),
                ),
              ),
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
                            future:
                                Provider.of<DBProvider>(context, listen: false)
                                    .testGetPlaylistSongs(playlist.id!),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return CircularProgressIndicator();
                              return Text(
                                snapshot.data?.length.toString() ?? '0',
                                style: Theme.of(context).textTheme.subtitle2,
                              );
                            })
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
