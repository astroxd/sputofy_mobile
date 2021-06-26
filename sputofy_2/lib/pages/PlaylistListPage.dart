import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/model/PlaylistModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';
import 'package:sputofy_2/pages/PlaylistScreenPage.dart';
import 'package:sputofy_2/provider/provider.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/palette.dart';
import 'package:rxdart/rxdart.dart';

class PlaylistsList extends StatefulWidget {
  @override
  _PlaylistsListState createState() => _PlaylistsListState();
}

class _PlaylistsListState extends State<PlaylistsList> {
  Stream<PlayingMediaItem> get _playingMediaItemStream =>
      Rx.combineLatest2<MediaItem, PlaybackState, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (mediaItem, playbackState) =>
              PlayingMediaItem(mediaItem, playbackState));

  @override
  Widget build(BuildContext context) {
    DBHelper _database = DBHelper();
    Provider.of<DBProvider>(context, listen: false).getPlaylists();
    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        children: <Widget>[
          MaterialButton(
            color: Colors.red,
            onPressed: () {
              Provider.of<DBProvider>(context, listen: false).savePlaylist(
                Playlist(
                  null,
                  'Atest',
                  'cover',
                  DateTime.now(),
                  Duration.zero,
                ),
              );
            },
            child: Text("data"),
          ),
          _buildWidgetButtonController(_database),
          _buildWidgetPlaylistList(context, _database),
          SizedBox(height: 50),
        ],
      ),
      bottomSheet: MiniPlayer(),
    );
  }

  Widget _buildWidgetButtonController(DBHelper _database) {
    return StreamBuilder<PlaybackState>(
        stream: AudioService.playbackStateStream,
        builder: (context, snapshot) {
          final repeatMode = snapshot?.data?.repeatMode;
          final isPlaying = snapshot?.data?.playing;
          return Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 10.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        List<Playlist> playlists =
                            await _database.getPlaylists();
                        List<Map> playlistSongs = [];
                        for (final playlist in playlists) {
                          List<Song> songs =
                              await _database.getPlaylistSongs(playlist.id);
                          songs.forEach((song) {
                            playlistSongs.add(song.toMap());
                          });
                        }
                        if (playlistSongs.isEmpty) return;
                        await AudioService.customAction('setPlaylistID', -1);
                        await AudioService.customAction(
                            'loadPlaylist', playlistSongs);
                        AudioService.customAction('shufflePlay');
                        if (!isPlaying) await AudioService.play();
                      },
                      child: Icon(
                        AppIcon.shuffle,
                        color: accentColor,
                        size: 24.0,
                      ),
                    ),
                    // SizedBox(
                    //   width: 12.0,
                    // ),
                    // GestureDetector(
                    //   onTap: () async {
                    //     if (playingPlaylistID != -1) {
                    //       List<Playlist> playlists =
                    //           await _database.getPlaylists();
                    //       List<Map> playlistSongs = [];
                    //       for (final playlist in playlists) {
                    //         List<Song> songs =
                    //             await _database.getPlaylistSongs(playlist.id);
                    //         songs.forEach((song) {
                    //           playlistSongs.add(song.toMap());
                    //         });
                    //       }
                    //       if (playlistSongs.isEmpty) return;
                    //       await AudioService.customAction('setPlaylistID', -1);
                    //       await AudioService.customAction(
                    //           'loadPlaylist', playlistSongs);

                    //       if (repeatMode == AudioServiceRepeatMode.all) {
                    //         await AudioService.setRepeatMode(
                    //             AudioServiceRepeatMode.none);
                    //       } else {
                    //         await AudioService.setRepeatMode(
                    //             AudioServiceRepeatMode.all);
                    //       }
                    //     } else {
                    //       if (repeatMode == AudioServiceRepeatMode.all) {
                    //         await AudioService.setRepeatMode(
                    //             AudioServiceRepeatMode.none);
                    //       } else {
                    //         await AudioService.setRepeatMode(
                    //             AudioServiceRepeatMode.all);
                    //       }
                    //     }
                    //     if (!isPlaying) await AudioService.play();
                    //   },
                    //   child: Icon(
                    //     Icons.repeat,
                    //     color: playingPlaylistID == -1 &&
                    //             repeatMode == AudioServiceRepeatMode.all
                    //         ? accentColor
                    //         : Colors.black,
                    //     size: 28.0,
                    //   ),
                    // ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Provider.of<DBProvider>(context, listen: false)
                        .sortPlaylists();
                  },
                  child: Icon(
                    AppIcon.arrow_up_down,
                    size: 22.0,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildWidgetPlaylistList(BuildContext context, DBHelper _database) {
    return Expanded(
      child: FutureBuilder(
        future: Provider.of<DBProvider>(context).playlists,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Playlist> playlists = snapshot.data;
            return playlistList(context, playlists, _database);
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget playlistList(
      BuildContext context, List<Playlist> playlists, DBHelper _database) {
    return StreamBuilder<PlayingMediaItem>(
        stream: _playingMediaItemStream,
        builder: (context, snapshot) {
          PlayingMediaItem playingMediaItem = snapshot.data;
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
                        builder: (context) => PlaylistScreen(playlist),
                      ),
                    );
                  },
                  child: playlistTile(playlist, _database, playingMediaItem),
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
          Provider.of<DBProvider>(context, listen: false)
              .deletePlaylist(playlist.id);
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
                      if (playingSong?.playingItem?.album !=
                          playlist.id.toString()) {
                        await AudioService.setShuffleMode(
                            AudioServiceShuffleMode.none);
                        await _loadQueue(_database, playlist.id);
                      } else {
                        if (playingSong.playbackState.playing)
                          await AudioService.pause();
                        else
                          await AudioService.play();
                      }
                    },
                    child: Icon(
                      playingSong?.playingItem?.album ==
                                  playlist.id.toString() &&
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
            width: 170.0,
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
                      List<Song> playlistSongs = snapshot?.data ?? [];
                      // if (!snapshot.hasData) return CircularProgressIndicator();
                      return Text(
                        "${playlistSongs.length} songs",
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
    await AudioService.customAction('loadPlaylist', songs)
        .then((value) => AudioService.play());
  }
}

class PlayingMediaItem {
  MediaItem playingItem;
  PlaybackState playbackState;
  PlayingMediaItem(this.playingItem, this.playbackState);
}
