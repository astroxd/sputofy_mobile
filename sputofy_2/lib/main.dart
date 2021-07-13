import 'dart:io';
import 'package:path/path.dart';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/MiniPlayerScreen/mini_player.dart';
import 'package:sputofy_2/screens/playlistListScreen/playlist_list_screen.dart';
import 'package:sputofy_2/screens/songListScreen/song_list_screen.dart';
import 'package:sputofy_2/theme/style.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    as youtubeDownloader;
import 'package:rxdart/rxdart.dart';

import 'components/download_song.dart';
import 'components/load_song.dart';
import 'components/playlist_dialog.dart';
import 'models/playlist_model.dart';
import 'models/song_model.dart';
import 'screens/EditPlaylistScreen/edit_playlist_screen.dart';
import 'screens/EditSongScreen/edit_song_screen.dart';
import 'services/audioPlayer.dart';
import 'services/database.dart';
import 'theme/palette.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DBProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sputofy',
        theme: appTheme(),
        home: AudioServiceWidget(
          child: DefaultTabController(
            length: 2,
            child: MyHomePage(),
          ),
        ),
      ),
    );
  }
}

_backgroundTaskEntryPoint() {
  print("entrypoint");
  AudioServiceBackground.run(() => AudioPlayerTask());
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int tabIndex = 0;
  bool isSearching = false;
  Widget appBarTitle = Text('Sputofy');
  @override
  void initState() {
    print("Initi");
    Permission.storage.request();

    _start();
    super.initState();
  }

  _start() {
    AudioService.start(
      backgroundTaskEntrypoint: _backgroundTaskEntryPoint,
      androidNotificationChannelName: 'Sputofy',
      androidEnableQueue: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidStopForegroundOnPause: true,
      // androidNotificationColor: 0x00000000,
      androidNotificationColor: 0x0000ff,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TabController _tabController = DefaultTabController.of(context)!;
    Provider.of<DBProvider>(context, listen: false).getSongs();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            setState(() {
              tabIndex = 0;
              // isSearching = false;
              // appBarTitle = Text('Sputofy');
            });
            break;
          case 1:
            setState(() {
              tabIndex = 1;
              // isSearching = false;
              // appBarTitle = Text('Sputofy');
            });
            break;
        }
      }
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: appBarTitle,
        actions: <Widget>[
          if (!isSearching) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  isSearching = true;
                  appBarTitle = TextField();
                });
              },
              icon: Icon(Icons.search),
            ),
            tabIndex == 0
                ? PopupMenuButton<String>(
                    onSelected: (String choice) =>
                        _handleClick(choice, context),
                    itemBuilder: (BuildContext context) {
                      return {'Download Song', 'Load Songs'}
                          .map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                          // child: Row(
                          // children: [
                          //   Text("62.5%"),
                          //   SizedBox(width: 4.0),
                          //   Text(
                          //     choice,
                          //   ),
                          // ],
                          // ),
                        );
                      }).toList();
                    },
                  )
                : IconButton(
                    onPressed: () => showNewPlaylistDialog(context),
                    icon: Icon(Icons.add),
                  ),
          ] else ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  isSearching = false;
                  appBarTitle = Text('Sputofy');
                });
              },
              child: Text("cacca"),
            )
          ],
        ],
        bottom: TabBar(
          tabs: [
            Tab(
              text: "Songs",
            ),
            Tab(
              text: "Playlist",
            )
          ],
        ),
      ),
      body: StreamBuilder<bool>(
        stream: AudioService.runningStream,
        builder: (context, snapshot) {
          final isRunning = snapshot.data ?? false;
          if (!isRunning) _start();
          return TabBarView(
            children: [
              SongListScreen(),
              PlaylistListScreen(),
              // if (snapshot.connectionState != ConnectionState.active) ...[
              //   // SizedBox(),
              //   Container(
              //     color: Colors.red,
              //   ),
              //   SizedBox()
              // ] else ...[
              //   if (!isRunning) ...[
              //     Container(
              //       color: Colors.red,
              //     ),
              //     Container()
              //   ] else ...[
              //     SongListScreen(),
              //     PlaylistListScreen(),
              //   ]
              // ]
            ],
          );
        },
      ),
      bottomSheet: MiniPlayer(),
    );
  }
}

void _handleClick(String choice, BuildContext context) async {
  switch (choice) {
    case 'Download Song':
      bool isConnected = false;
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('connected');
          isConnected = true;
        }
      } on SocketException catch (_) {
        print('not connected');
        isConnected = false;
      }
      if (isConnected) {
        //* Before first download stream is null
        if (downloadStream.valueOrNull == -1 ||
            downloadStream.valueOrNull == -2 ||
            downloadStream.valueOrNull == null) {
          showDownloadSongDialog(context, _scaffoldKey);
        } else {
          showDownloadDialog(context);
        }
      } else
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Check your connection before downloading'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true)
                        .pop('dialog'),
                    child: Text('OK'))
              ],
            );
          },
        );
      ;
      break;
    case 'Load Songs':
      loadSongs(context);
      break;
  }
}

Widget songMenuButton(Song song, BuildContext context,
    {Playlist? playlist, IconData? icon}) {
  return PopupMenuButton<List>(
    onSelected: (List params) =>
        songMenuHandleClick(params, context, playlist: playlist),
    icon: icon == null ? Icon(Icons.more_horiz) : Icon(icon),
    padding: EdgeInsets.zero,
    itemBuilder: (context) {
      return {'Delete Song', 'Edit Song', 'Share Song'}.map((String choice) {
        return PopupMenuItem<List>(
          value: [choice, song],
          child: Text(choice),
        );
      }).toList();
    },
  );
}

songMenuHandleClick(List params, BuildContext context, {Playlist? playlist}) {
  //* params = [choice, song]
  String choice = params[0];
  Song song = params[1];

  switch (choice) {
    case 'Delete Song':
      _deleteSong(song, context, playlist: playlist);
      break;
    case 'Edit Song':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditSongScreen(song, playlist: playlist),
        ),
      );
      break;
    case 'Share Song':
      Share.shareFiles([song.path]);
      break;
  }
}

void _deleteSong(Song song, BuildContext context, {Playlist? playlist}) {
  if (AudioService.currentMediaItem?.album == '-2') {
    AudioService.removeQueueItem(song.toMediaItem());
    Provider.of<DBProvider>(context, listen: false).deleteSong(song.id!);
  } else if (playlist != null) {
    if (playlist.id == 0) {
      Provider.of<DBProvider>(context, listen: false)
          .updateSong(song.copyWith(isFavorite: false));
      AudioService.updateMediaItem(
          song.copyWith(isFavorite: false).toMediaItem());
    } else {
      if (AudioService.currentMediaItem?.album == '${playlist.id}') {
        AudioService.removeQueueItem(song.toMediaItem());
      }
      Provider.of<DBProvider>(context, listen: false)
          .deletePlaylistSong(playlist.id!, song.id!);
    }
  } else {
    Provider.of<DBProvider>(context, listen: false).deleteSong(song.id!);
  }
}

Widget playlistMenuButton(
    Playlist playlist, BuildContext context, bool shouldPop) {
  return PopupMenuButton<List>(
    onSelected: (List params) =>
        playlistMenuHandleClick(params, context, shouldPop),
    icon: Icon(Icons.more_vert),
    padding: EdgeInsets.zero,
    itemBuilder: (context) {
      return {'Delete Playlist', 'Edit Playlist'}.map((String choice) {
        return PopupMenuItem<List>(
          value: [choice, playlist],
          child: Text(choice),
        );
      }).toList();
    },
  );
}

playlistMenuHandleClick(List params, BuildContext context, bool shouldPop) {
  //* params = [choice, playlist]
  String choice = params[0];
  Playlist playlist = params[1];
  switch (choice) {
    case 'Delete Playlist':
      if (playlist.id == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Favorite playlist can't be deleted"),
            action: SnackBarAction(
              label: 'HIDE',
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      } else {
        Provider.of<DBProvider>(context, listen: false)
            .deletePlaylist(playlist.id!);
        if (shouldPop) Navigator.pop(context);
      }
      break;
    case 'Edit Playlist':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPlaylistScreen(playlist),
        ),
      );
      break;
  }
}

Future<void> loadQueue(int playlistID, List<Song> songs,
    {String? songPath, String? playlistTitle}) async {
  if (songs.isEmpty) return;
  List<MediaItem> mediaItems = [];
  for (Song song in songs) {
    mediaItems.add(
      song
          .toMediaItem(
              playlistTitle: playlistTitle != null ? playlistTitle : null)
          .copyWith(album: '$playlistID'),
    );
  }
  await AudioService.updateQueue(mediaItems).then(
    (value) => {
      if (songPath != null)
        {
          AudioService.skipToQueueItem(songPath).then(
            (value) async => await AudioService.play(),
          )
        }
    },
  );
}
