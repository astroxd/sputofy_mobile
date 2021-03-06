import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/model/PlaylistModel.dart';
import 'package:sputofy_2/model/PlaylistSongModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';
import 'package:sputofy_2/pages/SelectSongPage.dart';
import 'package:sputofy_2/pages/SongDetailPage.dart';
import 'package:sputofy_2/provider/provider.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/DatabaseProvider.dart';
import 'package:sputofy_2/utils/palette.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sputofy_2/utils/AudioPlayer.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  PlaylistScreen(this.playlist);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  int playingPlaylistID;

  @override
  void initState() {
    AudioService.customAction('getPlaylistID');
    AudioService.customEventStream.listen((event) {
      playingPlaylistID = event;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double safePadding = mediaQueryData.padding.top;
    DBHelper _database = DBHelper();
    Provider.of<DBProvider>(context, listen: false)
        .getPlaylistSongs(widget.playlist.id);

    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: FutureBuilder(
          future: Provider.of<DBProvider>(context).playlistSongs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Song> playlistSongs = snapshot.data;
              return Column(
                children: <Widget>[
                  _buildWidgetPlaylistInfo(widthScreen, context, safePadding,
                      playlistSongs, _database),
                  SizedBox(height: 16.0),
                  _buildWidgetPlaylistSongsList(playlistSongs),
                  SizedBox(height: 50),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      bottomSheet: MiniPlayer(),
    );
  }

  Widget _buildWidgetPlaylistInfo(double widthScreen, BuildContext context,
      double safePadding, List<Song> playlistSongs, DBHelper _database) {
    return Container(
      width: widthScreen,
      color: secondaryColor,
      child: Column(
        children: <Widget>[
          _buildTopBar(context, _database),
          _buildPlaylistData(context, playlistSongs),
          SizedBox(height: 10.0),
          _buildPlaylistActionButtons(widthScreen, playlistSongs),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, DBHelper _database) {
    _showPopupMenu(Offset offset) async {
      double left = offset.dx;
      double top = offset.dy;
      await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(left, 0.0, 0.0,
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
              .deletePlaylist(widget.playlist.id);
          Navigator.pop(context);
        } else if (itemSelected == "2") {
          //code here
        } else {
          //code here
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios),
          ),
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _showPopupMenu(details.globalPosition);
            },
            child: Icon(
              Icons.more_vert,
              color: accentColor,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaylistData(BuildContext context, List<Song> playlistSongs) {
    return Container(
      padding: const EdgeInsets.only(left: 32.0, top: 16.0, right: 32.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 140,
            height: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset('cover.jpeg'), //TODO custom image?
            ),
          ),
          SizedBox(
            width: 16.0,
          ),
          Container(
            height: 140,
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 108,
                  child: Text(
                    widget.playlist.name ?? "noTITLE",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: accentColor),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          if (playingPlaylistID != widget.playlist.id) {
                            if (playlistSongs.isNotEmpty) {
                              await AudioService.setShuffleMode(
                                  AudioServiceShuffleMode.none);
                              await _loadQueue(playlistSongs);

                              await AudioService.play();
                            }
                          } else {
                            // _loadQueue(playlistSongs); //TODO TOGLI
                            await AudioService.play();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Icon(
                            Icons.play_arrow,
                            size: 32.0,
                            color: accentColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectSongList(
                                  playlistID: widget.playlist.id,
                                  playlistSongs: playlistSongs,
                                ),
                              )).then((value) {
                            if (value != null &&
                                playingPlaylistID == widget.playlist.id) {
                              AudioService.updateQueue(value);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Icon(
                            Icons.add,
                            size: 32.0,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaylistActionButtons(
      double widthScreen, List<Song> playlistSongs) {
    String _getPlaylistDuration() {
      Duration playlistDuration = Duration.zero;
      playlistSongs.map((e) => playlistDuration += e.duration).toList();

      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes =
          twoDigits(playlistDuration.inMinutes.remainder(60));
      String twoDigitSeconds =
          twoDigits(playlistDuration.inSeconds.remainder(60));
      return "${twoDigits(playlistDuration.inHours)}:$twoDigitMinutes:$twoDigitSeconds Hours";
    }

    return Container(
      width: widthScreen,
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                height: 36,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
              Container(
                height: 36,
                width: widthScreen,
                color: mainColor,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Text(
                    _getPlaylistDuration(),
                    style: TextStyle(fontSize: 16.0, color: accentColor),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: StreamBuilder<PlaybackState>(
                  stream: AudioService.playbackStateStream,
                  builder: (context, snapshot) {
                    PlaybackState playbackState = snapshot.data;
                    AudioServiceRepeatMode repeatMode =
                        playbackState?.repeatMode;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (playlistSongs.isNotEmpty) {
                              if (playingPlaylistID != widget.playlist.id) {
                                await _loadQueue(playlistSongs);
                              }

                              if (repeatMode == AudioServiceRepeatMode.all) {
                                await AudioService.setRepeatMode(
                                    AudioServiceRepeatMode.none);
                              } else {
                                await AudioService.setRepeatMode(
                                    AudioServiceRepeatMode.all);
                              }
                              if (!playbackState.playing)
                                await AudioService.play();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                                color: repeatMode == AudioServiceRepeatMode.all
                                    ? accentColor
                                    : thirdColor,
                                borderRadius: BorderRadius.circular(64.0)),
                            child: Icon(
                              Icons.repeat,
                              size: 32.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (playlistSongs.isNotEmpty) {
                              if (playingPlaylistID != widget.playlist.id) {
                                await _loadQueue(playlistSongs);
                              }

                              AudioService.customAction('shufflePlay');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(64.0)),
                            child: Icon(
                              AppIcon.shuffle, //TODO use svgIcon package
                              size: 32.0,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetPlaylistSongsList(List<Song> playlistSongs) {
    _showPopupMenu(Offset offset, Song song) async {
      double left = offset.dx;
      double top = offset.dy;
      await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(left, top, 0.0,
            0.0), //position where you want to show the menu on screen
        color: mainColor,
        items: [
          PopupMenuItem(
            child: const Text("Remove song"),
            value: '1',
            textStyle: TextStyle(color: Colors.red, fontSize: 18),
          )
        ],
        elevation: 6.0,
      ).then<void>((String itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          Provider.of<DBProvider>(context, listen: false)
              .deletePlaylistSong(widget.playlist.id, song.id);
          if (playingPlaylistID == widget.playlist.id) {
            AudioService.removeQueueItem(MediaItem(
                id: song.path,
                album: "${widget.playlist.id}",
                title: song.title));
          }
        } else if (itemSelected == "2") {
          //code here
        } else {
          //code here
        }
      });
    }

    return Expanded(
      child: StreamBuilder<MediaItem>(
          stream: AudioService.currentMediaItemStream,
          builder: (context, snapshot) {
            String playingSongPath = snapshot.data?.id ?? '';
            return ListView.builder(
              itemCount: playlistSongs.length,
              itemBuilder: (context, index) {
                Song song = playlistSongs[index];

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (playingPlaylistID == widget.playlist.id) {
                      AudioService.skipToQueueItem(song.path);
                      AudioService.play();
                    } else {
                      _loadQueue(playlistSongs, songPath: song.path);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailMusicPlayer(),
                      ),
                    );
                  },
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${index + 1}',
                              style:
                                  TextStyle(fontSize: 20, color: accentColor),
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                song.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: song.path == playingSongPath
                                      ? accentColor
                                      : Colors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTapDown: (TapDownDetails details) {
                                _showPopupMenu(details.globalPosition,
                                    playlistSongs[index]);
                              },
                              child: Icon(
                                Icons.more_vert,
                                color: accentColor,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        indent: 16.0,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              },
            );
          }),
      //
    );
  }

  _loadQueue(List<Song> playlistSongs, {String songPath}) async {
    //TODO se non funziona metty async e await
    List<Map> songs = [];
    for (Song song in playlistSongs) {
      songs.add(song.toMap());
    }

    await AudioService.customAction('setPlaylistID', widget.playlist.id);
    await AudioService.customAction('loadPlaylist', songs).then((value) => {
          if (songPath != null)
            {
              AudioService.skipToQueueItem(songPath)
                  .then((value) async => await AudioService.play())
            }
        });
  }
}
