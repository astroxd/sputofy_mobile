import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/app_icons.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';
import 'package:sputofy_2/provider/provider.dart';
import 'package:sputofy_2/utils/palette.dart';
import 'package:rxdart/rxdart.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  Stream<PlayingMediaItem> get _playingMediaItemStream =>
      Rx.combineLatest2<MediaItem?, PlaybackState, PlayingMediaItem>(
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (mediaItem, playbackState) =>
              PlayingMediaItem(mediaItem, playbackState));
  @override
  Widget build(BuildContext context) {
    Provider.of<DBProvider>(context, listen: false).getSongs();

    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        children: <Widget>[
          _buildWidgetButtonController(context),
          SizedBox(height: 8.0),
          _buildWidgetSongList(),
          SizedBox(height: 50.0)
        ],
      ),
      bottomSheet: MiniPlayer(),
    );
  }

  Widget _buildWidgetButtonController(BuildContext context) {
    return StreamBuilder<PlayingMediaItem>(
      stream: _playingMediaItemStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isPlaying = snapshot.data?.playbackState.playing;
          final playingItem = snapshot.data?.playingItem;
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        if (playingItem!.album != (-2).toString()) {
                          List<Song> songs = await Provider.of<DBProvider>(
                                  context,
                                  listen: false)
                              .songs!;

                          _loadQueue(songs);
                        }

                        AudioService.customAction('shufflePlay');
                        if (!isPlaying!) await AudioService.play();
                      },
                      child: Icon(
                        AppIcon.shuffle,
                        color: accentColor,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Icons.repeat,
                      size: 28,
                      color: accentColor,
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.arrow_downward,
                      size: 28,
                    ),
                    SizedBox(width: 8.0),
                    GestureDetector(
                      // onTap: () =>
                      //     Provider.of<DBProvider>(context, listen: false)
                      //         .deletePlaylist(5),
                      child: Icon(
                        Icons.thumbs_up_down_sharp,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: () => getFolder(),
                      child: Icon(
                        Icons.create_new_folder_outlined,
                        size: 28,
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  void getFolder() async {
    bool canAccesStorage = await Permission.storage.request().isGranted;
    if (canAccesStorage) {
      FilePicker.platform.getDirectoryPath().then((String? folder) {
        if (folder != null) {
          print(folder);
          loadSingleFolderItem(folder);
        }
      });
    } else {
      print("non posso entrare");
    }
  }

  void loadSingleFolderItem(String path) async {
    List<Song> songs =
        await Provider.of<DBProvider>(context, listen: false).songs!;
    List<Song> toADD = [];
    AudioPlayer _audioPlayer = AudioPlayer();
    Directory folder = Directory(path);
    List<FileSystemEntity> files = folder.listSync();
    var toRemove = [];
    for (FileSystemEntity file in files) {
      if (file is Directory) {
        toRemove.add(file);
      }
      if (!file.path.endsWith('mp3') && !file.path.endsWith('ogg')) {
        print("la stiamo togliendo ${file.path}");
        toRemove.add(file);
      }

      for (Song song in songs) {
        if (song.path == file.path) {
          toRemove.add(file);
          toRemove.forEach((element) {
            print(element.path);
          });
          print("BREAK");
          break;
        }
      }
    }

    files.removeWhere((e) => toRemove.contains(e));
    for (var i = 0; i < files.length; i++) {
      try {
        Duration? songDuration = await _audioPlayer
            .setAudioSource(AudioSource.uri(Uri.parse(files[i].path)));
        print("percorso da aggiungere ${files[i].path}");
        toADD.add(
          Song(
            null,
            files[i].path,
            files[i].path.split("/").last.replaceAll('.mp3', ''),
            "author",
            "cover",
            songDuration,
          ),
        );
      } catch (e) {
        print("errore aggiunta song $e");
      }
    }

    for (var i = 0; i < toADD.length; i++) {
      Provider.of<DBProvider>(context, listen: false).saveSong(toADD[i]);
    }
    setState(() {});
  }

  Widget _buildWidgetSongList() {
    _showPopupMenu(
        Offset offset, Song song, MediaItem? playingMediaItem) async {
      double left = offset.dx;
      double top = offset.dy;
      await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(left, top, 0.0,
            0.0), //position where you want to show the menu on screen
        color: mainColor,
        items: [
          PopupMenuItem(
            child: const Text("Delete Song"),
            value: '1',
            textStyle: TextStyle(color: Colors.red, fontSize: 18),
          )
        ],
        elevation: 6.0,
      ).then<void>((String? itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          if (playingMediaItem!.album == (-2).toString()) {
            AudioService.removeQueueItem(
                MediaItem(id: song.path!, album: '-2', title: song.title!));
            Provider.of<DBProvider>(context, listen: false).deleteSong(song.id);
          } else {
            Provider.of<DBProvider>(context, listen: false).deleteSong(song.id);
          }

          // Provider.of<DBProvider>(context, listen: false)
          //     .deletePlaylist(widget.playlist.id);
          // Navigator.pop(context);
        } else if (itemSelected == "2") {
          //code here
        } else {
          //code here
        }
      });
    }

    return Expanded(
      child: FutureBuilder(
        future: Provider.of<DBProvider>(context).songs,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Song>? songs = snapshot.data as List<Song>?;
            return StreamBuilder<MediaItem?>(
                stream: AudioService.currentMediaItemStream,
                builder: (context, snapshot) {
                  MediaItem? playingSong = snapshot.data;
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.black,
                    ),
                    itemCount: songs!.length,
                    itemBuilder: (context, index) {
                      Song song = songs[index];
                      return GestureDetector(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () async {
                                if (playingSong?.album != (-2).toString()) {
                                  await _loadQueue(songs, songPath: song.path);
                                } else {
                                  await AudioService.skipToQueueItem(
                                      song.path!);
                                  await AudioService.play();
                                }
                              },
                              title: Text(
                                "${song.title}",
                                style: TextStyle(
                                    color: song.path == playingSong?.id
                                        ? accentColor
                                        : Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                "${_getSongDuration(song.duration!)}",
                                style: TextStyle(color: secondaryColor),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.favorite_border,
                                    size: 30.0,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 12.0),
                                  GestureDetector(
                                    onTapDown: (TapDownDetails details) =>
                                        _showPopupMenu(details.globalPosition,
                                            song, playingSong),
                                    child: Icon(
                                      Icons.more_vert,
                                      size: 30.0,
                                      color: accentColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  String _getSongDuration(Duration songDuration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitSeconds = twoDigits(songDuration.inSeconds.remainder(60));
    return "${songDuration.inMinutes}:$twoDigitSeconds";
  }

  Future<void> _loadQueue(List<Song> songs, {String? songPath}) async {
    if (songs.isEmpty) return;
    List<Map> mapSongs = [];
    for (Song song in songs) {
      mapSongs.add(song.toMap());
    }

    await AudioService.customAction('setPlaylistID', -2);
    await AudioService.customAction('loadPlaylist', mapSongs).then((value) => {
          if (songPath != null)
            {
              AudioService.skipToQueueItem(songPath)
                  .then((value) async => await AudioService.play())
            }
        });
  }
}

class PlayingMediaItem {
  MediaItem? playingItem;
  PlaybackState playbackState;
  PlayingMediaItem(this.playingItem, this.playbackState);
}
