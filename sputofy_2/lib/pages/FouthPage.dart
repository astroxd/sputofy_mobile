import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/utils/Database.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sputofy_2/utils/DatabaseProvider.dart';

class FourthPage extends StatefulWidget {
  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  DBHelper _database = DBHelper();

  @override
  void initState() {
    // loadSongs();
    super.initState();
  }

  // Future<List<Song>> loadSongs() async {
  //   songs = await _database.getSongs();
  //   songs.forEach((element) {
  //     print(element.path);
  //   });
  //   return songs;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          MaterialButton(
            onPressed: getFolder,
            child: Text("getFolder"),
          ),
          Expanded(
            child: FutureBuilder(
              future: _database.getSongs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Song> songs = snapshot.data;
                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      Song song = songs[index];
                      return GestureDetector(
                          onLongPress: () {
                            _database.deleteSong(song.id);
                            setState(() {});
                          },
                          child: Container(
                              color: Colors.red,
                              child: Text("${song.path}-----${song.id}")));
                    },
                  );
                } else
                  return CircularProgressIndicator();
              },
            ),
          ),
          // Expanded(
          //   child: StreamBuilder<List<Song>>(
          //     stream: _database.playlistSongs,
          //     builder: (context, snapshot) {
          //       if (snapshot.hasData) {
          //         return ListView.builder(
          //           itemCount: snapshot.data.length,
          //           itemBuilder: (context, index) {
          //             return Text(snapshot.data[index].path);
          //           },
          //         );
          //       } else
          //         return CircularProgressIndicator();
          //     },
          //   ),
          // )
        ],
      ),
    );
  }

  void getFolder() async {
    PermissionHandler _permissionHandler = PermissionHandler();
    var result =
        await _permissionHandler.requestPermissions([PermissionGroup.storage]);
    if (result[PermissionGroup.storage] == PermissionStatus.granted) {
      FilePicker.platform.getDirectoryPath().then((String folder) {
        if (folder != null) {
          loadSingleFolderItem(folder);
        }
      });
    }
  }

  void loadSingleFolderItem(String path) async {
    List<Song> songs = await _database.getSongs();
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
        Duration songDuration = await _audioPlayer
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
      _database.saveSong(toADD[i]);
      setState(() {});
    }
  }

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // String _fileName;
  // List<PlatformFile> _paths;
  // String _directoryPath;
  // String _extension;
  // bool _loadingPath = false;
  // bool _multiPick = false;
  // FileType _pickingType = FileType.any;
  // TextEditingController _controller = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   _controller.addListener(() => _extension = _controller.text);
  // }

  // void _openFileExplorer() async {
  //   setState(() => _loadingPath = true);
  //   try {
  //     _directoryPath = null;
  //     _paths = (await FilePicker.platform.pickFiles(
  //       type: _pickingType,
  //       allowMultiple: _multiPick,
  //       allowedExtensions: (_extension?.isNotEmpty ?? false)
  //           ? _extension.replaceAll(' ', '').split(',')
  //           : null,
  //     ))
  //         ?.files;
  //   } on PlatformException catch (e) {
  //     print("Unsupported operation" + e.toString());
  //   } catch (ex) {
  //     print(ex);
  //   }
  //   if (!mounted) return;
  //   setState(() {
  //     _loadingPath = false;
  //     print(_paths.first.extension);
  //     _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
  //   });
  // }

  // void _clearCachedFiles() {
  //   FilePicker.platform.clearTemporaryFiles().then((result) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: result ? Colors.green : Colors.red,
  //         content: Text((result
  //             ? 'Temporary files removed with success.'
  //             : 'Failed to clean temporary files')),
  //       ),
  //     );
  //   });
  // }

  // void _selectFolder() {
  //   FilePicker.platform.getDirectoryPath().then((value) {
  //     setState(() => _directoryPath = value);
  //   });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       key: _scaffoldKey,
  //       appBar: AppBar(
  //         title: const Text('File Picker example app'),
  //       ),
  //       body: Center(
  //           child: Padding(
  //         padding: const EdgeInsets.only(left: 10.0, right: 10.0),
  //         child: SingleChildScrollView(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: <Widget>[
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 20.0),
  //                 child: DropdownButton<FileType>(
  //                     hint: const Text('LOAD PATH FROM'),
  //                     value: _pickingType,
  //                     items: <DropdownMenuItem<FileType>>[
  //                       DropdownMenuItem(
  //                         child: const Text('FROM AUDIO'),
  //                         value: FileType.audio,
  //                       ),
  //                       DropdownMenuItem(
  //                         child: const Text('FROM IMAGE'),
  //                         value: FileType.image,
  //                       ),
  //                       DropdownMenuItem(
  //                         child: const Text('FROM VIDEO'),
  //                         value: FileType.video,
  //                       ),
  //                       DropdownMenuItem(
  //                         child: const Text('FROM MEDIA'),
  //                         value: FileType.media,
  //                       ),
  //                       DropdownMenuItem(
  //                         child: const Text('FROM ANY'),
  //                         value: FileType.any,
  //                       ),
  //                       DropdownMenuItem(
  //                         child: const Text('CUSTOM FORMAT'),
  //                         value: FileType.custom,
  //                       ),
  //                     ],
  //                     onChanged: (value) => setState(() {
  //                           _pickingType = value;
  //                           if (_pickingType != FileType.custom) {
  //                             _controller.text = _extension = '';
  //                           }
  //                         })),
  //               ),
  //               ConstrainedBox(
  //                 constraints: const BoxConstraints.tightFor(width: 100.0),
  //                 child: _pickingType == FileType.custom
  //                     ? TextFormField(
  //                         maxLength: 15,
  //                         autovalidateMode: AutovalidateMode.always,
  //                         controller: _controller,
  //                         decoration:
  //                             InputDecoration(labelText: 'File extension'),
  //                         keyboardType: TextInputType.text,
  //                         textCapitalization: TextCapitalization.none,
  //                       )
  //                     : const SizedBox(),
  //               ),
  //               ConstrainedBox(
  //                 constraints: const BoxConstraints.tightFor(width: 200.0),
  //                 child: SwitchListTile.adaptive(
  //                   title:
  //                       Text('Pick multiple files', textAlign: TextAlign.right),
  //                   onChanged: (bool value) =>
  //                       setState(() => _multiPick = value),
  //                   value: _multiPick,
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
  //                 child: Column(
  //                   children: <Widget>[
  //                     ElevatedButton(
  //                       onPressed: () => _openFileExplorer(),
  //                       child: const Text("Open file picker"),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () => _selectFolder(),
  //                       child: const Text("Pick folder"),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () => _clearCachedFiles(),
  //                       child: const Text("Clear temporary files"),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Builder(
  //                 builder: (BuildContext context) => _loadingPath
  //                     ? Padding(
  //                         padding: const EdgeInsets.only(bottom: 10.0),
  //                         child: const CircularProgressIndicator(),
  //                       )
  //                     : _directoryPath != null
  //                         ? ListTile(
  //                             title: const Text('Directory path'),
  //                             subtitle: Text(_directoryPath),
  //                           )
  //                         : _paths != null
  //                             ? Container(
  //                                 padding: const EdgeInsets.only(bottom: 30.0),
  //                                 height:
  //                                     MediaQuery.of(context).size.height * 0.50,
  //                                 child: Scrollbar(
  //                                     child: ListView.separated(
  //                                   itemCount:
  //                                       _paths != null && _paths.isNotEmpty
  //                                           ? _paths.length
  //                                           : 1,
  //                                   itemBuilder:
  //                                       (BuildContext context, int index) {
  //                                     final bool isMultiPath =
  //                                         _paths != null && _paths.isNotEmpty;
  //                                     final String name = 'File $index: ' +
  //                                         (isMultiPath
  //                                             ? _paths
  //                                                 .map((e) => e.name)
  //                                                 .toList()[index]
  //                                             : _fileName ?? '...');
  //                                     final path = _paths
  //                                         .map((e) => e.path)
  //                                         .toList()[index]
  //                                         .toString();

  //                                     return ListTile(
  //                                       title: Text(
  //                                         name,
  //                                       ),
  //                                       subtitle: Text(path),
  //                                     );
  //                                   },
  //                                   separatorBuilder:
  //                                       (BuildContext context, int index) =>
  //                                           const Divider(),
  //                                 )),
  //                               )
  //                             : const SizedBox(),
  //               ),
  //             ],
  //           ),
  //         ),
  //       )),
  //     ),
  //   );
  // }
}
