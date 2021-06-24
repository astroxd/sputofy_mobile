import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

import 'package:sputofy_2/model/SongModel.dart';

import 'package:sputofy_2/pages/FouthPage.dart';
import 'package:sputofy_2/pages/MiniPlayerPage.dart';
import 'package:sputofy_2/pages/PaginaPerFarVedereLeCanzoni.dart';
import 'package:sputofy_2/pages/PlaylistListPage.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/pages/SongListPage.dart';
import 'package:sputofy_2/provider/provider.dart';
import 'package:sputofy_2/utils/AudioPlayer.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:sputofy_2/utils/palette.dart';

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
        theme: ThemeData(
            primarySwatch: Colors.orange,
            bottomSheetTheme: BottomSheetThemeData(backgroundColor: mainColor)),
        title: "Test",
        home: AudioServiceWidget(
          child: DefaultTabController(length: 4, child: MainScreen()),
        ),
      ),
    );
  }
}

_backgroundTaskEntryPoint() {
  print("entrypoint");
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DBHelper _database = DBHelper();
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text("test"),
        bottom: TabBar(
          tabs: [
            Tab(
              icon: Icon(
                Icons.home,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.playlist_add,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.playlist_add,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.playlist_add,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          PrimaPagina(context),
          SongList(),
          PlaylistsList(),
          FourthPage(),
        ],
      ),
      // bottomSheet: MiniPlayer(),
    );
  }

  //* AudioService lo usi per parlare con la background task

  start() async {
    // final mediaList = [];
    // for (var song in playlist) {
    //   print(song);
    //   final mediaItem = MediaItem(
    //     id: song.id,
    //     album: song.album,
    //     title: song.title,
    //     duration: song.duration,
    //     artUri: song.artUri,
    //   );
    //   mediaList.add(mediaItem.toJson());
    // }
    // if (mediaList.isEmpty) return;
    // final params = {'data': mediaList};
    AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntryPoint,
        // params: ,
        androidEnableQueue: true,
        androidNotificationColor: 0x0000ff);
  }
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class PlayingMediaItem {
  final MediaItem mediaItem;
  final Duration position;
  final PlaybackState playbackState;

  PlayingMediaItem(this.mediaItem, this.position, this.playbackState);
}

class PrimaPagina extends StatelessWidget {
  PrimaPagina(this.context);
  final BuildContext context;

  final List<Song> playlist = [
    Song(
      null,
      '/data/user/0/com.example.sputofy_2/cache/file_picker/「Rock」 Hatsuki Yura (葉月ゆら) - 少女と黄金竜の物語 (Shoujo to Ougon Ryuu no Monogatari).mp3',
      'oregairu',
      'tanta',
      "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
      Duration(milliseconds: 273057),
    ),
  ];

  Stream<QueueState> get _queueStateStream =>
      Rx.combineLatest2<List<MediaItem>, MediaItem, QueueState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          (queue, mediaItem) => QueueState(queue, mediaItem));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<PlaybackState>(
              stream: AudioService.playbackStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                final processingState = snapshot.data?.processingState ??
                    AudioProcessingState.stopped;
                print("playing var = $playing");
                print("processingstate var = $processingState");
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (playing)
                      MaterialButton(
                        child: Text("Pause"),
                        onPressed: pause,
                        color: Colors.green,
                      )
                    else
                      MaterialButton(
                        child: Text("Play"),
                        onPressed: () {
                          // showDialogWindow(context);
                          play();
                        },
                        color: Colors.green,
                      ),
                    if (processingState != AudioProcessingState.stopped &&
                        processingState != AudioProcessingState.none)
                      MaterialButton(
                        child: Text("Stop"),
                        onPressed: stop,
                        color: Colors.red,
                      ),
                  ],
                );
              },
            ),
            MaterialButton(
                child: Text("ADD"),
                color: Colors.blue,
                onPressed: () {
                  openPlaylist();
                }),
            StreamBuilder(
              stream: _queueStateStream,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  final queueStateStream = snapshot.data;
                  return Container(
                    width: double.infinity,
                    height: 300,
                    child: ListView.builder(
                      itemCount: queueStateStream.queue.length,
                      itemBuilder: (context, index) {
                        final mediaItem = queueStateStream.queue[index];
                        final currentMediaItem = queueStateStream.mediaItem;
                        return MaterialButton(
                          onPressed: () => seek(mediaItem.id),
                          child: mediaItem == currentMediaItem
                              ? Text(
                                  "${currentMediaItem.title}---${currentMediaItem.duration.toString()}",
                                  style: TextStyle(color: Colors.blue),
                                )
                              : Text(
                                  "${mediaItem.title}----${mediaItem.duration.toString()}"),
                        );
                      },
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  start() async {
    // final mediaList = [];
    // for (var song in playlist) {
    //   print(song);
    //   final mediaItem = MediaItem(
    //     id: song.id,
    //     album: song.album,
    //     title: song.title,
    //     duration: song.duration,
    //     artUri: song.artUri,
    //   );
    //   mediaList.add(mediaItem.toJson());
    // }
    // if (mediaList.isEmpty) return;
    // final params = {'data': mediaList};
    AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntryPoint,
        // params: params,
        androidEnableQueue: true,
        androidNotificationColor: 0x0000ff);
  }

  openPlaylist() {
    final mediaList = [];
    for (var song in playlist) {
      print(song);
      final mediaItem = MediaItem(
        id: song.path,
        album: song.author,
        title: song.title,
        duration: song.duration,
        artUri: song.cover,
      );
      mediaList.add(mediaItem.toJson());
    }
    if (mediaList.isEmpty) return;
    // final params = {'data': mediaList};
    AudioService.customAction('openPlaylist', mediaList);
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => PlaylistScreen(),
    //     ));
  }

  pause() {
    print("Pause");
    AudioService.pause();
  }

  stop() {
    print("stop");
    AudioService.stop();
  }

  play() async {
    if (AudioService.running) {
      AudioService.play();
    } else {
      start();
    }
  }

  add(MediaItem mediaItem) {
    AudioService.addQueueItem(mediaItem);
    // AudioService.setRating(Rating.newHeartRating(true));
  }

  seek(String mediaId) {
    AudioService.skipToQueueItem(mediaId);
  }
}
