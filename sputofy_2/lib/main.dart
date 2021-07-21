import 'dart:collection';
import 'dart:io';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sputofy_2/components/get_song_duration.dart';
import 'package:sputofy_2/components/load_queue.dart';
import 'package:sputofy_2/routes/folders.dart';
import 'package:sputofy_2/screens/playlistSongsScreen/playlist_songs_screen.dart';
import 'package:sputofy_2/theme/palette.dart';
import 'components/remove_all_songs.dart';
import 'components/show_hidden_playlists.dart';
import 'models/playlist_model.dart';
import 'models/song_model.dart';
import 'services/audioPlayer.dart';

import 'package:provider/provider.dart';
import 'providers/provider.dart';

import 'package:permission_handler/permission_handler.dart';

import 'screens/MiniPlayerScreen/mini_player.dart';
import 'screens/playlistListScreen/playlist_list_screen.dart';
import 'screens/songListScreen/song_list_screen.dart';

import 'theme/style.dart';

import 'components/download_song.dart';
import 'components/load_song.dart';
import 'components/playlist_dialog.dart';

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
  @override
  void initState() {
    Permission.storage.request();
    _createCoverDir(songPath()); //* Folder for songs cover
    _createCoverDir(playlistPath()); //* Folder for playlists cover
    _start();
    super.initState();
  }

  _start() {
    AudioService.start(
      backgroundTaskEntrypoint: _backgroundTaskEntryPoint,
      androidNotificationChannelName: 'Sputofy',
      androidEnableQueue: true,
      androidNotificationIcon: 'mipmap/ic_stat_sputofy',
      androidStopForegroundOnPause: true,
    );
  }

  _createCoverDir(Future<String> dirPath) async {
    Directory directory = Directory(await dirPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
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
            });
            break;
          case 1:
            setState(() {
              tabIndex = 1;
            });
            break;
        }
      }
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sputofy'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: DataSearch(context, tabIndex),
              );
            },
            icon: Icon(Icons.search),
          ),
          tabIndex == 0
              ? PopupMenuButton<String>(
                  onSelected: (String choice) => _handleClick(choice, context),
                  itemBuilder: (BuildContext context) {
                    return {'Download Song', 'Load Songs', 'Remove all Songs'}
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              : PopupMenuButton<String>(
                  onSelected: (String choice) => _handleClick(choice, context),
                  itemBuilder: (BuildContext context) {
                    return {'Create Playlist', 'Show hidden Playlists'}
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
        ],
        bottom: TabBar(
          tabs: [
            Tab(
              text: 'Songs',
            ),
            Tab(
              text: 'Playlist',
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
              //! Uncomment if you want to display something while is loading AudioService Isolate
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
      bool canAccesStorage = await Permission.storage.request().isGranted;
      if (canAccesStorage) {
        bool isConnected = false;
        try {
          final result = await InternetAddress.lookup('example.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            isConnected = true;
          }
        } on SocketException catch (_) {
          isConnected = false;
        }
        if (isConnected) {
          //* Before first download, stream is null
          if (downloadStream.valueOrNull == -1 ||
              downloadStream.valueOrNull == -2 ||
              downloadStream.valueOrNull == null) {
            showDownloadSongDialog(context, _scaffoldKey);
          } else {
            showDownloadDialog(context);
          }
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Check your connection before downloading'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true)
                        .pop('dialog'),
                    child: Text('OK'),
                  )
                ],
              );
            },
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'In order to load songs you have to grant permission storage'),
          ),
        );
      }

      break;
    case 'Load Songs':
      loadSongs(context);
      break;
    case 'Remove all Songs':
      removeAllSongs(context);
      break;
    case 'Create Playlist':
      showNewPlaylistDialog(context);
      break;
    case 'Show hidden Playlists':
      showHiddenPlaylist(context);
      break;
  }
}

class DataSearch extends SearchDelegate<String> {
  final BuildContext context;
  final int tabIndex;

  late final items;
  late HashMap<String, dynamic> hashItems;

  DataSearch(this.context, this.tabIndex) {
    if (tabIndex == 0) {
      items = Provider.of<DBProvider>(context, listen: false).songs;
      hashItems = HashMap.fromIterable(
        items,
        key: (song) => song.title,
        value: (song) => song,
      );
    } else {
      items = Provider.of<DBProvider>(context, listen: false).playlists;
      hashItems = HashMap.fromIterable(
        items,
        key: (playlist) => playlist.name,
        value: (playlist) => playlist,
      );
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme(
        primary: kThirdColor,
        primaryVariant: kSecondAccentColor,
        secondary: kAccentColor,
        secondaryVariant: kSecondAccentColor,
        surface: kSecondaryBackgroundColor,
        background: kBackgroundColor,
        error: Colors.red,
        onPrimary: kThirdColor,
        onSecondary: kThirdColor,
        onSurface: kThirdColor,
        onBackground: kThirdColor,
        onError: Colors.black,
        brightness: Brightness.dark,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //* Not used
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = hashItems.keys
        .where((element) => element.toLowerCase().contains(query))
        .toList();
    // final suggestionList = hashSongs.keys
    //     .map((e) => e.toLowerCase().allMatches(query).toString())
    //     .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        if (tabIndex == 0) {
          Song song = hashItems[suggestionList[index]]!;
          return ListTile(
            onTap: () {
              if (AudioService.currentMediaItem?.album != '-2') {
                loadQueue(-2, items, songPath: song.path);
              } else {
                AudioService.skipToQueueItem(song.path);
              }
              close(context, suggestionList[index]);
            },
            title: RichText(
              text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: kAccentColor),
                children: [
                  TextSpan(
                    text: suggestionList[index].substring(query.length),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
            subtitle: Text(
              getSongDuration(song.duration),
              style: Theme.of(context).textTheme.subtitle2,
            ),
            trailing: Icon(
              Icons.play_arrow_outlined,
              color: kPrimaryColor,
            ),
          );
        } else {
          Playlist playlist = hashItems[suggestionList[index]];
          return ListTile(
            onTap: () {
              Provider.of<DBProvider>(context, listen: false)
                  .getPlaylist(playlist.id!);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistSongsScreen(playlist),
                ),
              );
            },
            title: Text(playlist.name),
          );
        }
      },
    );
  }
}
