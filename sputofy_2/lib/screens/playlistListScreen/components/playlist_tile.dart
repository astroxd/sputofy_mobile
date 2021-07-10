import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/providers/provider.dart';

import 'package:sputofy_2/screens/playlistSongsScreen/playlist_songs_screen.dart';
import 'package:sputofy_2/theme/palette.dart';

import '../playlist_list_screen.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  const PlaylistTile(this.playlist, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List? playlistCover = playlist.cover;
    return Tooltip(
      message: playlist.name,
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4.0,
        color: kSecondaryBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: InkWell(
          onTap: () {
            Provider.of<DBProvider>(context, listen: false)
                .getPlaylist(playlist.id!);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistSongsScreen(playlist),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                    child: playlistCover != null
                        ? Image.memory(
                            playlistCover,
                            width: 70.0,
                            height: 70.0,
                          )
                        : Image.asset(
                            'cover.jpeg',
                            width: 70.0,
                            height: 70.0,
                          ),
                  ),
                  // TODO add
                  // IconButton(
                  //     splashColor: Colors.transparent,
                  //     iconSize: 48.0,
                  //     onPressed: () => print("bottone"),
                  //     icon: Icon(
                  //       Icons.play_arrow,
                  //       color: Colors.white,
                  //       // size: 48.0,
                  //     )),
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
                        future: Provider.of<DBProvider>(context, listen: false)
                            .testGetPlaylistSongs(playlist.id!),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data?.length.toString() ?? '0',
                            style: Theme.of(context).textTheme.subtitle2,
                          );
                        })
                  ],
                ),
              ),
              PlaylistbuildWidgetMenuButton(playlist, context),
            ],
          ),
        ),
      ),
    );
  }
}
