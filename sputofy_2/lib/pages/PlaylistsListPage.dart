import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/main.dart';
import 'package:sputofy_2/model/PlaylistModel.dart';
import 'package:sputofy_2/model/PlaylistSongModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';
import 'package:sputofy_2/pages/PlaylistScreenPage.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/palette.dart';
import 'package:rxdart/rxdart.dart';

class PlaylistsList extends StatefulWidget {
  @override
  _PlaylistsListState createState() => _PlaylistsListState();
}

class _PlaylistsListState extends State<PlaylistsList> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    DBHelper _database = DBHelper();

    return Container(
      color: mainColor,
      width: widthScreen,
      child: Column(
        children: <Widget>[
          MaterialButton(
            color: Colors.red,
            onPressed: () {
              _database.savePlaylist(
                Playlist(
                  null,
                  'playlsit',
                  'cover',
                  DateTime.now(),
                  Duration.zero,
                ),
              );
              setState(() {});
            },
            child: Text("data"),
          ),
          _buildWidgetButtonController(widthScreen),
          _buildWidgetPlaylistList(context, _database),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildWidgetButtonController(double widthScreen) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 10.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                child: Icon(
                  AppIcon.shuffle,
                  size: 24.0,
                ),
              ),
              SizedBox(
                width: 12.0,
              ),
              GestureDetector(
                child: Icon(
                  Icons.repeat,
                  size: 28.0,
                ),
              ),
            ],
          ),
          GestureDetector(
            child: Icon(
              AppIcon.arrow_up_down,
              size: 22.0,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetPlaylistList(BuildContext context, DBHelper _database) {
    return Expanded(
      child: FutureBuilder(
        future: _database.getPlaylists(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return playlistList(context, snapshot.data, _database);
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget playlistList(
      BuildContext context, List<Playlist> playlists, DBHelper _database) {
    Stream _playingMediaItemStream =
        Rx.combineLatest2<MediaItem, PlaybackState, PlayingMediaItem>(
            AudioService.currentMediaItemStream,
            AudioService.playbackStateStream,
            (mediaItem, playbackState) =>
                PlayingMediaItem(mediaItem, playbackState));

    return StreamBuilder<PlayingMediaItem>(
        stream: _playingMediaItemStream,
        builder: (context, snapshot) {
          return GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            crossAxisCount: 2,
            childAspectRatio: 170 / 210,
            children: List.of(
              playlists.map(
                (playlist) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlaylistScreen(playlist)))
                        .then((value) {
                      setState(() {});
                    });
                  },
                  child: playlistTile(playlist, _database, snapshot.data),
                ),
              ),
            ),
          );
        });
  }

  Widget playlistTile(
      Playlist playlist, DBHelper _database, PlayingMediaItem playingSong) {
    _showPopupMenu(Offset offset) async {
      double left = offset.dx;
      double top = offset.dy;
      print(left);
      print(top);
      await showMenu<String>(
        context: context,
        //TODO check position
        position: RelativeRect.fromLTRB(left, top - 20.0, 0.0,
            0.0), //position where you want to show the menu on screen
        color: mainColor,
        items: [
          PopupMenuItem(
            child: const Text("Delete Playlist"),
            value: '1',
            textStyle: TextStyle(color: Colors.red, fontSize: 18),
          )
        ],
        elevation: 6.0,
      ).then<void>((String itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          _database.deleteAllPlaylistSongs(playlist.id);
          _database.deletePlaylist(playlist.id);
          setState(() {});
        } else if (itemSelected == "2") {
          //code here
        } else {
          //code here
        }
      });
    }

    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Container(
            width: 170.0,
            height: 170.0,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.asset('cover.jpeg'),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () async {
                      if (playingSong.playingItem.album !=
                          playlist.id.toString()) {
                        await _loadQueue(_database, playlist.id);
                        await AudioService.play();
                      } else {
                        if (playingSong.playbackState.playing)
                          await AudioService.pause();
                        else
                          await AudioService.play();
                      }
                    },
                    child: Icon(
                      playingSong.playingItem.album == playlist.id.toString() &&
                              playingSong.playbackState.playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled_sharp,
                      size: 36.0,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 170,
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        playlist.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        _showPopupMenu(details.globalPosition);

                        // Provider.of<DatabaseValue>(context, listen: false)
                        //     .deleteAllPlaylistSongs(playlist.id);
                        // Provider.of<DatabaseValue>(context, listen: false)
                        //     .deletePlaylist(playlist.id);
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                FutureBuilder<List<Song>>(
                    future: _database.getPlaylistSongs(playlist.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      return Text(
                        "${snapshot.data.length} songs",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: accentColor, fontSize: 14),
                      );
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _loadQueue(DBHelper _database, int playlistID) async {
    List<Song> playlistSongs = await _database.getPlaylistSongs(playlistID);
    if (playlistSongs.isEmpty) return;
    List<Map> songs = [];
    for (Song song in playlistSongs) {
      songs.add(song.toMap());
    }

    await AudioService.customAction('setPlaylistID', playlistID);
    await AudioService.customAction('loadPlaylist', songs);
  }
  // @override
  // Widget build(BuildContext context) {
  //   DBHelper _database = DBHelper();
  //   return Scaffold(
  //     body: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisSize: MainAxisSize.max,
  //       children: <Widget>[
  //         MaterialButton(
  //           color: Colors.red,
  //           onPressed: () {
  //             _database.savePlaylist(
  //               Playlist(
  //                 null,
  //                 'playlsit',
  //                 'cover',
  //                 DateTime.now(),
  //                 Duration.zero,
  //               ),
  //             );
  //             setState(() {});
  //           },
  //           child: Text("data"),
  //         ),
  //         Expanded(
  //           child: FutureBuilder(
  //             future: _database.getPlaylists(),
  //             builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
  //               if (snapshot.hasData) {
  //                 List<Playlist> _playlists = snapshot.data;

  //                 return ListView.builder(
  //                   itemCount: _playlists.length,
  //                   itemBuilder: (context, index) {
  //                     Playlist _playlist = _playlists[index];

  //                     return StreamBuilder<MediaItem>(
  //                         stream: AudioService.currentMediaItemStream,
  //                         builder: (context, snapshot) {
  //                           if (!snapshot.hasData)
  //                             return CircularProgressIndicator();
  //                           MediaItem playingSong = snapshot.data;
  //                           return GestureDetector(
  //                               onLongPress: () {
  //                                 _database.deletePlaylist(_playlist.id);
  //                                 setState(() {});
  //                               },
  //                               onTap: () {
  //                                 Navigator.push(context, MaterialPageRoute(
  //                                   builder: (context) {
  //                                     return PlaylistScreen(_playlist);
  //                                   },
  //                                 )).then((value) {
  //                                   setState(() {});
  //                                 });
  //                               },
  //                               child: Container(
  //                                   // width: 40,
  //                                   height: 100,
  //                                   color: playingSong.album ==
  //                                           _playlist.id.toString()
  //                                       ? Colors.red
  //                                       : Colors.blue,
  //                                   child: Column(
  //                                     children: [
  //                                       Text(_playlist.id.toString()),
  //                                       Text(_playlist.creationDate.toString()),
  //                                       Text(_playlist.name.toString()),
  //                                     ],
  //                                   )));
  //                         });
  //                   },
  //                 );
  //               } else {
  //                 return CircularProgressIndicator();
  //               }
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //     bottomSheet: MiniPlayer(),
  //     //  StreamBuilder(
  //     //   stream: AudioService.currentMediaItemStream,
  //     //   builder: (context, snapshot) {
  //     //     if (snapshot.hasData) {
  //     //       return MiniPlayer();
  //     //     } else {
  //     //       return Container(
  //     //         height: 0,
  //     //       );
  //     //     }
  //     //   },
  //     // )
  //     //TODO could work
  //   );
  // }
}

class PlayingMediaItem {
  MediaItem playingItem;
  PlaybackState playbackState;
  PlayingMediaItem(this.playingItem, this.playbackState);
}
