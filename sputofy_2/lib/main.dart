import 'dart:io';
import 'package:path/path.dart';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
  DBHelper _database = DBHelper();
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

//TODO could move into another file
//*------------------------------------------------------------------------*//
//*                            LOAD SONGS                                 *//
//*----------------------------------------------------------------------*//
// void _loadSongs(BuildContext context) async {
//   bool canAccesStorage = await Permission.storage.request().isGranted;
//   if (canAccesStorage) {
//     FilePicker.platform.getDirectoryPath().then((String? folder) {
//       if (folder != null) {
//         print(folder);
//         _loadFolderItems(folder, context);
//       }
//     });
//   }
// }

// void _loadFolderItems(String folder_path, BuildContext context) async {
//   DBHelper _database = DBHelper();
//   List<Song> newSongs = [];
//   List<Song> currentSongs = await _database.getSongs();
//   AudioPlayer _audioPlayer = AudioPlayer();
//   Directory folder = Directory(folder_path);

//   List<FileSystemEntity> folderContent = folder.listSync();

//   var contentToRemove = [];

//   for (FileSystemEntity file in folderContent) {
//     if (file is Directory) {
//       contentToRemove.add(file);
//     }

//     if (!file.path.endsWith('mp3') && !file.path.endsWith('ogg')) {
//       contentToRemove.add(file);
//     }

//     if (currentSongs.map((song) => song.path).toList().contains(file.path)) {
//       contentToRemove.add(file);
//     }
//   }

//   folderContent.removeWhere((element) => contentToRemove.contains(element));
//   folderContent.forEach((element) {
//     print("ADD $element");
//   });
//   contentToRemove.forEach((element) {
//     print("DELETE $element");
//   });

//   for (FileSystemEntity file in folderContent) {
//     try {
//       Duration? songDuration = await _audioPlayer
//           .setAudioSource(AudioSource.uri(Uri.file(file.path)));
//       String baseFileName = basename(file.path);
//       String fileName =
//           baseFileName.substring(0, baseFileName.lastIndexOf('.'));

//       newSongs.add(Song(null, file.path, fileName, '', '', songDuration));
//     } catch (e) {
//       print("Error on loading Song from folder $e");
//     }
//   }

//   for (Song song in newSongs) {
//     Provider.of<DBProvider>(context, listen: false).saveSong(song);
//   }
//   AudioService.addQueueItems(newSongs.map((e) => e.toMediaItem()).toList());
// }

//*----------------------------------------------------------------------------*//
//*                            DOWNLOAD SONGS                                 *//
//*--------------------------------------------------------------------------*//

// _showDownloadSongDialog(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return DownloadSong();
//     },
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(24.0),
//         topRight: Radius.circular(24.0),
//       ),
//     ),
//   );
// }

// class DownloadSong extends StatefulWidget {
//   const DownloadSong({Key? key}) : super(key: key);

//   @override
//   _DownloadSongState createState() => _DownloadSongState();
// }

// class _DownloadSongState extends State<DownloadSong> {
//   var textController = TextEditingController(text: '');
//   bool isValid = true;
//   @override
//   void dispose() {
//     textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return Padding(
//       padding: EdgeInsets.only(
//           top: 16.0, left: 16.0, right: 16.0, bottom: bottomPadding),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Text(
//             "Download Songs",
//             style: Theme.of(context).textTheme.headline6,
//           ),
//           SizedBox(height: 16.0),
//           Padding(
//             padding: EdgeInsets.only(bottom: 0.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'https://youtu.be/VEe_yIbW64w',
//                 hintStyle: TextStyle(color: kPrimaryColor),
//                 errorText: isValid ? null : 'Link can\'t be empty',
//               ),
//               autofocus: true,
//               controller: textController,
//             ),
//           ),
//           SizedBox(height: 24.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               MaterialButton(
//                 color: kSecondaryColor,
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text("Cancel"),
//               ),
//               MaterialButton(
//                 onPressed: () async {
//                   if (textController.text.isEmpty) {
//                     setState(() {
//                       isValid = false;
//                     });
//                   } else {
//                     setState(() {
//                       isValid = true;
//                     });

//                     _downloadHandler(
//                         textController.text, _scaffoldKey.currentContext!);
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Text("Download"),
//                 color: kAccentColor,
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// List<String> downloadSongs = [];
// int initiaDownloadSongslLength = 0;
// final downloadStream = BehaviorSubject<int>();

// _downloadHandler(String URL, BuildContext context) {
//   if (URL.contains('playlist')) {
//     _downloadPlaylist(URL, context);
//   } else {
//     _downloadSong(URL, context);
//   }
// }

// _downloadPlaylist(String playlistURL, BuildContext context) async {
//   var yt = youtubeDownloader.YoutubeExplode();
//   var playlist = await yt.playlists.get(playlistURL);
//   String title = playlist.title;
//   await for (var video in yt.playlists.getVideos(playlistURL)) {
//     downloadSongs.add(video.id.toString());
//   }
//   downloadSongs = downloadSongs.reversed.toList();
//   initiaDownloadSongslLength = downloadSongs.length;
//   yt.close();
//   _downloadSong(downloadSongs.last, context, playlistName: title);
// }

// _downloadSong(String videoURL, BuildContext context,
//     {String? playlistName}) async {
//   try {
//     var yt = youtubeDownloader.YoutubeExplode();
//     String videoID = videoURL.split('/').last;

//     //* Get video metadata
//     var video = await yt.videos.get(videoID);
//     String videoTitle = video.title
//         .replaceAll(r'\', '')
//         .replaceAll('/', '')
//         .replaceAll('*', '')
//         .replaceAll('?', '')
//         .replaceAll('"', '')
//         .replaceAll('<', '')
//         .replaceAll('>', '')
//         .replaceAll('|', '');

//     //*Get video manifest
//     var manifest = await yt.videos.streamsClient.getManifest(videoID);
//     var streamInfo = manifest.audioOnly.withHighestBitrate();
//     Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfo);

//     File file = File('/storage/emulated/0/Music/$videoTitle.mp3');

//     // Delete the file if exists.
//     if (file.existsSync()) {
//       file.deleteSync();
//     }
//     var fileSizeInBytes = streamInfo.size.totalBytes;

//     var output = file.openWrite(mode: FileMode.writeOnlyAppend);

//     var count = 0;
//     var percentage = 0;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StreamBuilder(
//           stream: downloadStream,
//           initialData: 0,
//           builder: (context, snapshot) {
//             var value = snapshot.data ?? 0;

//             return AlertDialog(
//               title: playlistName != null
//                   ? Text(
//                       'Downloading...\n$playlistName ${initiaDownloadSongslLength - (downloadSongs.length - 1)}/$initiaDownloadSongslLength')
//                   : Text('Downloading...'),
//               content: value == -1
//                   ? Text("Download Completed")
//                   : Text("$videoTitle: $value%"),
//             );
//           },
//         );
//       },
//     );

//     await for (final data in stream) {
//       count += data.length;
//       output.add(data);
//       print(count);
//       percentage = ((count / fileSizeInBytes) * 100).ceil();
//       downloadStream.add(percentage);
//     }
//     Navigator.of(context, rootNavigator: true).pop('dialog');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("$videoTitle downloaded"),
//         behavior: SnackBarBehavior.floating,
//         elevation: 0.0,
//         action: SnackBarAction(
//           label: 'HIDE',
//           onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//         ),
//       ),
//     );
//     downloadStream.add(-1);
//     await output.close().then((value) {
//       if (downloadSongs.length > 0) {
//         downloadSongs.removeLast();
//       }
//       if (downloadSongs.isNotEmpty) {
//         _downloadSong(downloadSongs.last, context, playlistName: playlistName);
//       }
//     });
//     yt.close();
//   } catch (e) {
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: Text('Can\'t download song'),
//           actions: [
//             TextButton(
//                 onPressed: () =>
//                     Navigator.of(context, rootNavigator: true).pop('dialog'),
//                 child: Text('OK'))
//           ],
//         );
//       },
//     );
//     // .then((value) => Navigator.of(context, rootNavigator: true).pop('dialog'));
//     print("ERROR IN DOWNLOAD $e");
//     downloadSongs.clear();
//   }
// }

//TODO could move into another file
//*------------------------------------------------------------------------*//
//*                            PLAYLIST                                   *//
//*----------------------------------------------------------------------*//

// void _showNewPlaylistDialog(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return NewPlaylistDialog();
//     },
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(24.0),
//         topRight: Radius.circular(24.0),
//       ),
//     ),
//   );
// }

// class NewPlaylistDialog extends StatefulWidget {
//   const NewPlaylistDialog({Key? key}) : super(key: key);

//   @override
//   _NewPlaylistDialogState createState() => _NewPlaylistDialogState();
// }

// class _NewPlaylistDialogState extends State<NewPlaylistDialog> {
//   var textController = TextEditingController(text: '');
//   bool isValid = true;

//   @override
//   void dispose() {
//     textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return Padding(
//       padding: EdgeInsets.only(
//           top: 16.0, left: 16.0, right: 16.0, bottom: bottomPadding),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Text(
//             "Create Playlist",
//             style: Theme.of(context).textTheme.headline6,
//           ),
//           SizedBox(height: 16.0),
//           Padding(
//             padding: EdgeInsets.only(bottom: 0.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'my beautiful playlist',
//                 hintStyle: TextStyle(color: kPrimaryColor),
//                 errorText: isValid ? null : 'Playlist name can\'t be empty',
//               ),
//               autofocus: true,
//               controller: textController,
//             ),
//           ),
//           SizedBox(height: 24.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               MaterialButton(
//                 color: kSecondaryColor,
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text("Cancel"),
//               ),
//               MaterialButton(
//                 onPressed: () {
//                   if (textController.text.isEmpty) {
//                     setState(() {
//                       isValid = false;
//                     });
//                   } else {
//                     setState(() {
//                       isValid = true;
//                     });
//                     _savePlaylist(textController.text, context);
//                   }
//                 },
//                 child: Text("Save"),
//                 color: kAccentColor,
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// _savePlaylist(String playlistName, BuildContext context) {
//   Playlist playlist = Playlist(null, playlistName, '', DateTime.now());
//   Provider.of<DBProvider>(context, listen: false).savePlaylist(playlist);
//   Navigator.pop(context);
// }
