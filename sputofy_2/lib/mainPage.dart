import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/model/databaseValues.dart';
import 'package:sputofy_2/model/folderPathmodel.dart';
import 'package:sqflite/sqflite.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<PlatformFile> lista;
  getSongs() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'ogg'],
    );
    if (result != null) {
      List<PlatformFile> file = result.files;

      // List<File> songs = result.paths.map((path) => File(path)).toList();
      // List<String> names = result.names;

      setState(() {
        // lista = names;
        lista = file;
      });
    } else {
      print("Hai cancellato");
    }
  }

  List<FileSystemEntity> itemList;
  getFolderItem() {
    FilePicker.platform.getDirectoryPath().then((String folder) {
      print("cacacacacaca$folder");
      Directory dir = Directory(folder);
      List<FileSystemEntity> files = dir.listSync();
      List<FileSystemEntity> lista = files;

      // for (File file in lista) {
      //   if (file.path.split('.').last != 'mp3') {
      //     files.remove(file);
      //   } else {
      //     debugPrint("##################${file.path}");
      //   }
      // }
      setState(() {
        itemList = lista;
      });
    });
  }

  loadFolder() {
    Directory cartella = Directory("/storage/emulated/0/Music");
    List<FileSystemEntity> canzoni = cartella.listSync();
    setState(() {
      itemList = canzoni;
    });
  }

  loadFolderItem(List<String> paths) {
    List<FileSystemEntity> files;
    for (String path in paths) {
      Directory folder = Directory(path);
      files = folder.listSync();
    }
    setState(() {
      itemList = files;
    });
  }

  getFolder(BuildContext context) {
    FilePicker.platform.getDirectoryPath().then((String folder) {
      Provider.of<DatabaseValue>(context, listen: false)
          .saveFolder(FolderPath(folder));
    });
  }

  @override
  void initState() {
    // loadFolder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Center(
            child: MaterialButton(
              onPressed: () => getSongs(),
              child: Text("Aggiungi canzoni"),
            ),
          ),
          Center(
            child: MaterialButton(
              onPressed: () => getFolder(context),
              child: Text("Aggiungi Folder"),
            ),
          ),
          FutureBuilder(
            future: Provider.of<DatabaseValue>(context).paths,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data.length == 0
                    ? CircularProgressIndicator()
                    : Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text("${snapshot.data[index].path}"),
                            );
                          },
                        ),
                      );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          // itemList != null
          //     ? Expanded(
          //         child: ListView.builder(
          //           itemCount: itemList.length,
          //           itemBuilder: (context, index) {
          //             return ListTile(
          //               title: Text("${itemList[index].path}"),
          //             );
          //           },
          //         ),
          //       )
          //     : Text("cacca"),
          lista != null
              ? Expanded(
                  child: ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            "${lista[index].name.replaceAll(('.' + lista[index].name.split('.').last), '')}"),
                      );
                    },
                  ),
                )
              : Text("cacca"),
        ],
      ),
    );
  }

  void premuto() {
    print("premuto");
  }
}

// class FilePickerDemo extends StatefulWidget {
//   @override
//   _FilePickerDemoState createState() => _FilePickerDemoState();
// }

// class _FilePickerDemoState extends State<FilePickerDemo> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   String _fileName;
//   List<PlatformFile> _paths;
//   String _directoryPath;
//   String _extension;
//   bool _loadingPath = false;
//   bool _multiPick = false;
//   FileType _pickingType = FileType.any;
//   TextEditingController _controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() => _extension = _controller.text);
//   }

//   void _openFileExplorer() async {
//     setState(() => _loadingPath = true);
//     try {
//       _directoryPath = null;
//       _paths = (await FilePicker.platform.pickFiles(
//         type: _pickingType,
//         allowMultiple: _multiPick,
//         allowedExtensions: (_extension?.isNotEmpty ?? false)
//             ? _extension?.replaceAll(' ', '')?.split(',')
//             : null,
//       ))
//           ?.files;
//     } on PlatformException catch (e) {
//       print("Unsupported operation" + e.toString());
//     } catch (ex) {
//       print(ex);
//     }
//     if (!mounted) return;
//     setState(() {
//       _loadingPath = false;
//       _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
//     });
//   }

//   void _clearCachedFiles() {
//     FilePicker.platform.clearTemporaryFiles().then((result) {
//       _scaffoldKey.currentState.showSnackBar(
//         SnackBar(
//           backgroundColor: result ? Colors.green : Colors.red,
//           content: Text((result
//               ? 'Temporary files removed with success.'
//               : 'Failed to clean temporary files')),
//         ),
//       );
//     });
//   }

//   void _selectFolder() {
//     FilePicker.platform.getDirectoryPath().then((value) {
//       setState(() => _directoryPath = value);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           title: const Text('File Picker example app'),
//         ),
//         body: Center(
//             child: Padding(
//           padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.only(top: 20.0),
//                   child: DropdownButton(
//                       hint: const Text('LOAD PATH FROM'),
//                       value: _pickingType,
//                       items: <DropdownMenuItem>[
//                         DropdownMenuItem(
//                           child: const Text('FROM AUDIO'),
//                           value: FileType.audio,
//                         ),
//                         DropdownMenuItem(
//                           child: const Text('FROM IMAGE'),
//                           value: FileType.image,
//                         ),
//                         DropdownMenuItem(
//                           child: const Text('FROM VIDEO'),
//                           value: FileType.video,
//                         ),
//                         DropdownMenuItem(
//                           child: const Text('FROM MEDIA'),
//                           value: FileType.media,
//                         ),
//                         DropdownMenuItem(
//                           child: const Text('FROM ANY'),
//                           value: FileType.any,
//                         ),
//                         DropdownMenuItem(
//                           child: const Text('CUSTOM FORMAT'),
//                           value: FileType.custom,
//                         ),
//                       ],
//                       onChanged: (value) => setState(() {
//                             _pickingType = value;
//                             if (_pickingType != FileType.custom) {
//                               _controller.text = _extension = '';
//                             }
//                           })),
//                 ),
//                 ConstrainedBox(
//                   constraints: const BoxConstraints.tightFor(width: 100.0),
//                   child: _pickingType == FileType.custom
//                       ? TextFormField(
//                           maxLength: 15,
//                           autovalidateMode: AutovalidateMode.always,
//                           controller: _controller,
//                           decoration:
//                               InputDecoration(labelText: 'File extension'),
//                           keyboardType: TextInputType.text,
//                           textCapitalization: TextCapitalization.none,
//                         )
//                       : const SizedBox(),
//                 ),
//                 ConstrainedBox(
//                   constraints: const BoxConstraints.tightFor(width: 200.0),
//                   child: SwitchListTile.adaptive(
//                     title:
//                         Text('Pick multiple files', textAlign: TextAlign.right),
//                     onChanged: (bool value) =>
//                         setState(() => _multiPick = value),
//                     value: _multiPick,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
//                   child: Column(
//                     children: <Widget>[
//                       ElevatedButton(
//                         onPressed: () => _openFileExplorer(),
//                         child: const Text("Open file picker"),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => _selectFolder(),
//                         child: const Text("Pick folder"),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => _clearCachedFiles(),
//                         child: const Text("Clear temporary files"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Builder(
//                   builder: (BuildContext context) => _loadingPath
//                       ? Padding(
//                           padding: const EdgeInsets.only(bottom: 10.0),
//                           child: const CircularProgressIndicator(),
//                         )
//                       : _directoryPath != null
//                           ? ListTile(
//                               title: const Text('Directory path'),
//                               subtitle: Text(_directoryPath),
//                             )
//                           : _paths != null
//                               ? Container(
//                                   padding: const EdgeInsets.only(bottom: 30.0),
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.50,
//                                   child: Scrollbar(
//                                       child: ListView.separated(
//                                     itemCount:
//                                         _paths != null && _paths.isNotEmpty
//                                             ? _paths.length
//                                             : 1,
//                                     itemBuilder:
//                                         (BuildContext context, int index) {
//                                       final bool isMultiPath =
//                                           _paths != null && _paths.isNotEmpty;
//                                       final String name = 'File $index: ' +
//                                           (isMultiPath
//                                               ? _paths
//                                                   .map((e) => e.name)
//                                                   .toList()[index]
//                                               : _fileName ?? '...');
//                                       final path = _paths
//                                           .map((e) => e.path)
//                                           .toList()[index]
//                                           .toString();

//                                       return ListTile(
//                                         title: Text(
//                                           name,
//                                         ),
//                                         subtitle: Text(path),
//                                       );
//                                     },
//                                     separatorBuilder:
//                                         (BuildContext context, int index) =>
//                                             const Divider(),
//                                   )),
//                                 )
//                               : const SizedBox(),
//                 ),
//               ],
//             ),
//           ),
//         )),
//       ),
//     );
//   }
// }
