import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/model/PlaylistModel.dart';
import 'package:sputofy_2/model/PlaylistSongModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';
import 'package:sputofy_2/pages/SelectSongPage.dart';
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

    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: FutureBuilder(
          future: _database.getPlaylistSongs(widget.playlist.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Song> playlistSongs = snapshot.data;
              return Column(
                children: <Widget>[
                  _buildWidgetPlaylistInfo(
                      widthScreen, context, safePadding, playlistSongs),
                  SizedBox(height: 16.0),
                  _buildWidgetPlaylistSongsList(playlistSongs, _database),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWidgetPlaylistInfo(double widthScreen, BuildContext context,
      double safePadding, List<Song> playlistSongs) {
    return Container(
      width: widthScreen,
      color: secondaryColor,
      child: Column(
        children: <Widget>[
          _buildTopBar(),
          _buildPlaylistData(playlistSongs),
          SizedBox(height: 10.0),
          _buildPlaylistActionButtons(widthScreen, playlistSongs),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
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
            onTap: () {
              // _showPopupMenu();
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

  Widget _buildPlaylistData(List<Song> playlistSongs) {
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
                              await _loadQueue(playlistSongs);
                            }
                          } else {
                            await AudioService.play();
                          }

                          // showDialogWindow(context);
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
                              )).then((value) => setState(() {
                                if (value != null &&
                                    playingPlaylistID == widget.playlist.id) {
                                  AudioService.customAction('addSong', value);
                                } else {
                                  print("sono qui dentro=? $value+");
                                }
                              }));
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
    Duration playlistDuration = Duration.zero;
    playlistSongs.map((e) => playlistDuration += e.duration).toList();

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
                    "$playlistDuration",
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
                    AudioServiceShuffleMode shuffleMode =
                        playbackState?.shuffleMode;
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

                              await AudioService.setShuffleMode(
                                  AudioServiceShuffleMode.all);
                              if (!playbackState.playing)
                                await AudioService.play();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(64.0)),
                            child: Icon(
                              AppIcon.shuffle,
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

  Widget _buildWidgetPlaylistSongsList(
      List<Song> playlistSongs, DBHelper _database) {
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
          _database.deletePlaylistSong(widget.playlist.id, song.id);
          setState(() {
            if (playingPlaylistID == widget.playlist.id) {
              AudioService.customAction('removeSong', song.path);
            }
          });
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
                      if (!AudioService.playbackState.playing) {
                        AudioService.play();
                      }
                    } else {
                      _loadQueue(playlistSongs, songPath: song.path);
                    }
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
    await AudioService.customAction('loadPlaylist', songs);
    if (songPath != null) {
      await AudioService.skipToQueueItem(songPath);
    }
  }
}
