// import 'dart:async';
// import 'dart:io';
// import 'package:path/path.dart';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:sputofy_2/models/playlist_model.dart';
// import 'package:sputofy_2/models/song_model.dart';
// import 'package:sputofy_2/providers/provider.dart';
// import 'package:sputofy_2/services/database.dart';
// import 'package:sputofy_2/theme/palette.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart'
//     as youtubeDonwloader;

// AppBar appBar(int tabIndex, BuildContext context) {
//   return AppBar(
//     title: Text("Sputofy"),
//     actions: <Widget>[
//       IconButton(
//         onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Not implemented yet"),
//           ),
//         ),
//         icon: Icon(Icons.search),
//       ),
//       tabIndex == 0
//           ? PopupMenuButton<String>(
//               onSelected: (String choice) => _handleClick(choice, context),
//               itemBuilder: (BuildContext context) {
//                 return {'Download Song', 'Load Songs'}.map((String choice) {
//                   return PopupMenuItem<String>(
//                     value: choice,
//                     child: Text(
//                       choice,
//                     ),
//                   );
//                 }).toList();
//               },
//             )
//           : IconButton(
//               onPressed: () => _showNewPlaylistDialog(context),
//               icon: Icon(Icons.add),
//             ),
//     ],
//     bottom: TabBar(
//       tabs: [
//         Tab(
//           text: "Songs",
//         ),
//         Tab(
//           text: "Playlist",
//         )
//       ],
//     ),
//   );
// }

// void _handleClick(String choice, BuildContext context) {
//   switch (choice) {
//     case 'Download Song':
//       _showSongSheet(context);
//       break;
//     case 'Load Songs':
//       _loadSongs(context);
//       break;
//   }
// }

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
//           .setAudioSource(AudioSource.uri(Uri.parse(file.path)));
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
// }

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
//           SizedBox(height: 32.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               MaterialButton(
//                 color: kSecondaryColor,
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text("cancel"),
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

// _showSongSheet(BuildContext context) {
//   TextEditingController _textController = TextEditingController(text: '');
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return Padding(
//         padding:
//             EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _textController,
//             ),
//             MaterialButton(
//               onPressed: () => _downloadSong(_textController.text),
//               child: Text(
//                 "download",
//                 style: Theme.of(context).textTheme.subtitle1,
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// _downloadSong(String videoURL) async {
//   var yt = youtubeDonwloader.YoutubeExplode();
//   String videoID = videoURL.split('/').last;
//   // print(videoURL);

//   //* Get video metadata
//   var video = await yt.videos.get(videoID);

//   //*Get video manifest
//   var manifest = await yt.videos.streamsClient.getManifest(videoID);
//   var streamInfo = manifest.audioOnly.withHighestBitrate();
//   Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfo);

//   File file = File('/storage/emulated/0/Music/${video.title}.mp3');

//   var output = file.openWrite(mode: FileMode.writeOnlyAppend);

//   var count = 0;
//   await for (final data in stream) {
//     count += data.length;
//     output.add(data);
//     print(count);
//   }
//   await output.close();
//   yt.close();
// }
