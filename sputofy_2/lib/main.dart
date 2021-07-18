import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:sputofy_2/components/get_song_duration.dart';
import 'package:sputofy_2/components/load_queue.dart';
import 'package:sputofy_2/theme/palette.dart';
import 'components/remove_all_songs.dart';
import 'components/show_hidden_playlists.dart';
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
  //! SearchBar related
  bool isSearching = false;
  Widget appBarTitle = Text('Sputofy');
  @override
  void initState() {
    Permission.storage.request();

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
              //! SearchBar related
              // isSearching = false;
              // appBarTitle = Text('Sputofy');
            });
            break;
          case 1:
            setState(() {
              tabIndex = 1;
              //! SearchBar related
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
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(context));
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('Not implemented yet'),
              //   ),
              // );
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
              // : IconButton(
              //     onPressed: () => showNewPlaylistDialog(context),
              //     icon: Icon(Icons.add),
              //   ),
              : PopupMenuButton<String>(
                  onSelected: (String choice) => _handleClick(choice, context),
                  itemBuilder: (BuildContext context) {
                    return {'Show hidden Playlists'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
          //! Uncomment for enabling search bar (needs to be implemented)
          // if (!isSearching) ...[
          //   IconButton(
          //     onPressed: () {
          //       setState(() {
          //         isSearching = true;
          //         appBarTitle = TextField();
          //       });
          //     },
          //     icon: Icon(Icons.search),
          //   ),
          //   tabIndex == 0
          //       ? PopupMenuButton<String>(
          //           onSelected: (String choice) =>
          //               _handleClick(choice, context),
          //           itemBuilder: (BuildContext context) {
          //             return {'Download Song', 'Load Songs'}
          //                 .map((String choice) {
          //               return PopupMenuItem<String>(
          //                 value: choice,
          //                 child: Text(choice),
          //               );
          //             }).toList();
          //           },
          //         )
          //       : IconButton(
          //           onPressed: () => showNewPlaylistDialog(context),
          //           icon: Icon(Icons.add),
          //         ),
          // ] else ...[
          //   GestureDetector(
          //     onTap: () {
          //       setState(() {
          //         isSearching = false;
          //         appBarTitle = Text('Sputofy');
          //       });
          //     },
          //     child: Text("cancel"),
          //   )
          // ],
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
    case 'Show hidden Playlists':
      showHiddenPlaylist(context);
      break;
  }
}

class DataSearch extends SearchDelegate<String> {
  BuildContext context;
  late List<Song> songs;
  late HashMap<String, Song> hashSongs;
  DataSearch(this.context) {
    songs = Provider.of<DBProvider>(context, listen: false).songs;
    hashSongs = HashMap.fromIterable(
      songs,
      key: (song) => song.title,
      value: (song) => song,
    );
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
    //* Never used
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = hashSongs.keys
        .where((element) => element.toLowerCase().contains(query))
        .toList();
    // final suggestionList = hashSongs.keys
    //     .map((e) => e.toLowerCase().allMatches(query).toString())
    //     .toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        Song song = hashSongs[suggestionList[index]]!;
        return ListTile(
          onTap: () {
            if (AudioService.currentMediaItem?.album != '-2') {
              loadQueue(-2, songs, songPath: song.path);
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
      },
    );
  }
}
