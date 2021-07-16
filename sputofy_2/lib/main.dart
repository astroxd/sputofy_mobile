import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
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
      androidNotificationIcon: 'mipmap/ic_launcher',
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Not implemented yet'),
                ),
              );
            },
            icon: Icon(Icons.search),
          ),
          tabIndex == 0
              ? PopupMenuButton<String>(
                  onSelected: (String choice) => _handleClick(choice, context),
                  itemBuilder: (BuildContext context) {
                    return {'Download Song', 'Load Songs'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              : IconButton(
                  onPressed: () => showNewPlaylistDialog(context),
                  icon: Icon(Icons.add),
                ),
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
      } else
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Check your connection before downloading'),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop('dialog'),
                  child: Text('OK'),
                )
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
