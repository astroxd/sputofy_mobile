import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/components/appbar.dart';
import 'package:sputofy_2/providers/provider.dart';
import 'package:sputofy_2/screens/playlistListScreen/playlist_list_screen.dart';
import 'package:sputofy_2/screens/songListScreen/song_list_screen.dart';
import 'package:sputofy_2/theme/style.dart';

import 'services/audioPlayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    print("Initi");
    _start();
    super.initState();
  }

  _start() {
    AudioService.start(
      backgroundTaskEntrypoint: _backgroundTaskEntryPoint,
      androidEnableQueue: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: StreamBuilder<bool>(
          stream: AudioService.runningStream,
          builder: (context, snapshot) {
            final isRunning = snapshot.data ?? false;
            if (!isRunning) _start();
            return TabBarView(
              children: [
                if (snapshot.connectionState != ConnectionState.active) ...[
                  // SizedBox(),
                  Container(
                    color: Colors.red,
                  ),
                  SizedBox()
                ] else ...[
                  if (!isRunning) ...[
                    Container(
                      color: Colors.red,
                    ),
                    Container()
                  ] else ...[
                    SongListScreen(),
                    PlaylistListScreen(),
                  ]
                ]
              ],
            );
          }),
    );
  }
}
