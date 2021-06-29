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
    print(playlists);

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
                return Container(
                  // padding: const EdgeInsets.only(
                  //     top: 8.0, bottom: 8.0, right: 8.0, left: 16.0),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        )
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0)),
                        child: Image.asset(
                          'cover.jpeg',
                          width: 50.0,
                          height: 50.0,
                        ),
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
                      GestureDetector(
                          onTap: null, child: Icon(Icons.more_vert)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
