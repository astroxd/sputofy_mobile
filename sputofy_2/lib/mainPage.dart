// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sputofy_2/app_icons.dart';
// import 'package:sputofy_2/model/audioPlayer.dart';
// import 'package:sputofy_2/model/databaseValues.dart';
// import 'package:sputofy_2/model/folderPathmodel.dart';
// import 'package:sputofy_2/utils/palette.dart';
// import 'package:sputofy_2/utils/CustomExpansionTile.dart';

// class MainPage extends StatefulWidget {
//   @override
//   _MainPageState createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   //TODO implementa
//   List<PlatformFile> lista;
//   getSongs() async {
//     FilePickerResult result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       type: FileType.custom,
//       allowedExtensions: ['mp3', 'ogg'],
//     );
//     if (result != null) {
//       List<PlatformFile> file = result.files;

//       // List<File> songs = result.paths.map((path) => File(path)).toList();
//       // List<String> names = result.names;

//       setState(() {
//         // lista = names;
//         lista = file;
//       });
//     } else {
//       print("Hai cancellato");
//     }
//   }

//   void getFolder(BuildContext context) async {
//     FilePicker.platform.getDirectoryPath().then((String folder) {
//       if (folder != null) {
//         print(folder);
//         Provider.of<DatabaseValue>(context, listen: false)
//             .saveFolder(FolderPath(folder));
//       }
//     });
//   }

//   List<FileSystemEntity> loadSingleFolderItem(String path) {
//     Directory folder = Directory(path);
//     List<FileSystemEntity> files = folder.listSync();
//     var toRemove = [];
//     for (FileSystemEntity file in files) {
//       if (file is Directory) {
//         toRemove.add(file);
//       }
//       if (!file.path.endsWith('mp3') || file.path.endsWith('ogg')) {
//         toRemove.add(file);
//       }
//     }

//     files.removeWhere((e) => toRemove.contains(e));
//     files.forEach((file) => print(file.path));

//     return files;
//   }

//   String getFileName(FileSystemEntity file) {
//     List<String> splittedPath = file.path.split("/");
//     return splittedPath[splittedPath.length - 1].replaceAll(".mp3", "");
//   }

//   @override
//   void initState() {
//     // loadFolder();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: mainColor,
//       body: Column(
//         children: <Widget>[
//           _buildWidgetButtonController(context),
//           SizedBox(height: 8.0),
//           _buildWidgetSongList()
//         ],
//       ),
//     );
//   }

//   Widget _buildWidgetButtonController(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               Icon(
//                 AppIcon.shuffle,
//               ),
//               SizedBox(width: 8.0),
//               Icon(
//                 Icons.repeat,
//                 size: 28,
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               Icon(
//                 Icons.arrow_downward,
//                 size: 28,
//               ),
//               SizedBox(width: 8.0),
//               Icon(
//                 Icons.thumbs_up_down_sharp,
//                 size: 28,
//               ),
//               SizedBox(width: 8.0),
//               GestureDetector(
//                 onTap: () {
//                   getFolder(context);
//                 },
//                 child: Icon(
//                   Icons.create_new_folder_outlined,
//                   size: 28,
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildWidgetSongList() {
//     return Expanded(
//       child: FutureBuilder(
//         future: Provider.of<DatabaseValue>(context).paths,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return ListView.builder(
//               itemCount: snapshot.data.length,
//               itemBuilder: (context, index) {
//                 FolderPath folder = snapshot.data[index];
//                 List<FileSystemEntity> folderContent =
//                     loadSingleFolderItem(folder.path);
//                 return GestureDetector(
//                   onLongPress: () =>
//                       Provider.of<DatabaseValue>(context, listen: false)
//                           .deleteFolder(snapshot.data[index].path),
//                   child: Theme(
//                     data: ThemeData(
//                         accentColor: secondaryColor,
//                         unselectedWidgetColor: secondaryColor),
//                     child: CustomExpansionTile(
//                       initiallyExpanded: true,
//                       title: Text(
//                         folder.path.split("/").last.toString(),
//                         style: TextStyle(color: accentColor),
//                       ),
//                       subtitle: Text(
//                         "${folderContent.length} songs",
//                         style: TextStyle(fontSize: 14, color: thirdColor),
//                       ),
//                       children: [expandedContent(folderContent)],
//                     ),
//                   ),
//                 );
//               },
//             );
//           } else {
//             return CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }

//   Widget expandedContent(List<FileSystemEntity> folderContent) {
//     return Consumer<MyAudio>(
//       builder: (context, audioPlayer, child) => ListView.builder(
//         shrinkWrap: true,
//         itemCount: folderContent.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             // onTap: () => audioPlayer.pathPlay(folderContent[index]),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0, vertical: 16.0),
//                   child: Row(
//                     children: <Widget>[
//                       Expanded(
//                         child: Text(
//                           getFileName(folderContent[index]),
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: accentColor,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Row(
//                         children: <Widget>[
//                           Icon(
//                             Icons.favorite_border_rounded,
//                             size: 28,
//                           ),
//                           SizedBox(
//                             width: 8.0,
//                           ),
//                           Icon(
//                             Icons.more_vert,
//                             size: 28,
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 Divider(
//                   thickness: .5,
//                   color: Colors.black,
//                 )
//               ],
//             ),
//             // child: Container(
//             //   decoration: BoxDecoration(
//             //     border: Border(
//             //       bottom: BorderSide(color: Colors.black, width: .5),
//             //     ),
//             //   ),
//             //   child: Row(
//             //     children: <Widget>[
//             //       Row(
//             //         children: <Widget>[
//             //           Text(getFileName(folderContent[index])),
//             //         ],
//             //       )
//             //     ],
//             //   ),
//             // ),
//           );
//         },
//       ),
//     );
//   }
// }

// // class ExpandableContainer extends StatefulWidget {
// //   final Widget collapsedChild;
// //   final Widget expandedChild;

// //   const ExpandableContainer({Key key, this.collapsedChild, this.expandedChild})
// //       : super(key: key);
// //   @override
// //   ExpandableContainerState createState() => ExpandableContainerState();
// // }

// // class ExpandableContainerState extends State<ExpandableContainer> {
// //   bool isExpanded = true;
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           isExpanded = !isExpanded;
// //         });
// //       },
// //       child: AnimatedContainer(
// //         duration: Duration(milliseconds: 200),
// //         curve: Curves.easeInOut,
// //         child: isExpanded ? widget.expandedChild : widget.collapsedChild,
// //       ),
// //     );
// //   }
// // }

// // class CollapsedTile extends StatelessWidget {
// //   final Text title;
// //   final Text subTitle;
// //   final IconData icon;
// //   const CollapsedTile({Key key, this.title, this.subTitle, this.icon})
// //       : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: <Widget>[
// //         Row(
// //           children: <Widget>[
// //             title,
// //             Icon(icon),
// //           ],
// //         ),
// //         subTitle,
// //       ],
// //     );
// //   }
// // }

// // class ExpandedTile extends StatelessWidget {
// //   final Text title;
// //   final Text subTitle;
// //   final IconData icon;
// //   final List<Widget> children;
// //   const ExpandedTile(
// //       {Key key, this.title, this.subTitle, this.icon, this.children})
// //       : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: <Widget>[
// //         Row(
// //           children: <Widget>[
// //             title,
// //             Icon(icon),
// //           ],
// //         ),
// //         subTitle,
// //         SingleChildScrollView(
// //           child: Text("prova"),
// //         ),
// //       ],
// //     );
// //   }
// // }
// // class FilePickerDemo extends StatefulWidget {
// //   @override
// //   _FilePickerDemoState createState() => _FilePickerDemoState();
// // }

// // class _FilePickerDemoState extends State<FilePickerDemo> {
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// //   String _fileName;
// //   List<PlatformFile> _paths;
// //   String _directoryPath;
// //   String _extension;
// //   bool _loadingPath = false;
// //   bool _multiPick = false;
// //   FileType _pickingType = FileType.any;
// //   TextEditingController _controller = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller.addListener(() => _extension = _controller.text);
// //   }

// //   void _openFileExplorer() async {
// //     setState(() => _loadingPath = true);
// //     try {
// //       _directoryPath = null;
// //       _paths = (await FilePicker.platform.pickFiles(
// //         type: _pickingType,
// //         allowMultiple: _multiPick,
// //         allowedExtensions: (_extension?.isNotEmpty ?? false)
// //             ? _extension?.replaceAll(' ', '')?.split(',')
// //             : null,
// //       ))
// //           ?.files;
// //     } on PlatformException catch (e) {
// //       print("Unsupported operation" + e.toString());
// //     } catch (ex) {
// //       print(ex);
// //     }
// //     if (!mounted) return;
// //     setState(() {
// //       _loadingPath = false;
// //       _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
// //     });
// //   }

// //   void _clearCachedFiles() {
// //     FilePicker.platform.clearTemporaryFiles().then((result) {
// //       _scaffoldKey.currentState.showSnackBar(
// //         SnackBar(
// //           backgroundColor: result ? Colors.green : Colors.red,
// //           content: Text((result
// //               ? 'Temporary files removed with success.'
// //               : 'Failed to clean temporary files')),
// //         ),
// //       );
// //     });
// //   }

// //   void _selectFolder() {
// //     FilePicker.platform.getDirectoryPath().then((value) {
// //       setState(() => _directoryPath = value);
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         key: _scaffoldKey,
// //         appBar: AppBar(
// //           title: const Text('File Picker example app'),
// //         ),
// //         body: Center(
// //             child: Padding(
// //           padding: const EdgeInsets.only(left: 10.0, right: 10.0),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: <Widget>[
// //                 Padding(
// //                   padding: const EdgeInsets.only(top: 20.0),
// //                   child: DropdownButton(
// //                       hint: const Text('LOAD PATH FROM'),
// //                       value: _pickingType,
// //                       items: <DropdownMenuItem>[
// //                         DropdownMenuItem(
// //                           child: const Text('FROM AUDIO'),
// //                           value: FileType.audio,
// //                         ),
// //                         DropdownMenuItem(
// //                           child: const Text('FROM IMAGE'),
// //                           value: FileType.image,
// //                         ),
// //                         DropdownMenuItem(
// //                           child: const Text('FROM VIDEO'),
// //                           value: FileType.video,
// //                         ),
// //                         DropdownMenuItem(
// //                           child: const Text('FROM MEDIA'),
// //                           value: FileType.media,
// //                         ),
// //                         DropdownMenuItem(
// //                           child: const Text('FROM ANY'),
// //                           value: FileType.any,
// //                         ),
// //                         DropdownMenuItem(
// //                           child: const Text('CUSTOM FORMAT'),
// //                           value: FileType.custom,
// //                         ),
// //                       ],
// //                       onChanged: (value) => setState(() {
// //                             _pickingType = value;
// //                             if (_pickingType != FileType.custom) {
// //                               _controller.text = _extension = '';
// //                             }
// //                           })),
// //                 ),
// //                 ConstrainedBox(
// //                   constraints: const BoxConstraints.tightFor(width: 100.0),
// //                   child: _pickingType == FileType.custom
// //                       ? TextFormField(
// //                           maxLength: 15,
// //                           autovalidateMode: AutovalidateMode.always,
// //                           controller: _controller,
// //                           decoration:
// //                               InputDecoration(labelText: 'File extension'),
// //                           keyboardType: TextInputType.text,
// //                           textCapitalization: TextCapitalization.none,
// //                         )
// //                       : const SizedBox(),
// //                 ),
// //                 ConstrainedBox(
// //                   constraints: const BoxConstraints.tightFor(width: 200.0),
// //                   child: SwitchListTile.adaptive(
// //                     title:
// //                         Text('Pick multiple files', textAlign: TextAlign.right),
// //                     onChanged: (bool value) =>
// //                         setState(() => _multiPick = value),
// //                     value: _multiPick,
// //                   ),
// //                 ),
// //                 Padding(
// //                   padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
// //                   child: Column(
// //                     children: <Widget>[
// //                       ElevatedButton(
// //                         onPressed: () => _openFileExplorer(),
// //                         child: const Text("Open file picker"),
// //                       ),
// //                       ElevatedButton(
// //                         onPressed: () => _selectFolder(),
// //                         child: const Text("Pick folder"),
// //                       ),
// //                       ElevatedButton(
// //                         onPressed: () => _clearCachedFiles(),
// //                         child: const Text("Clear temporary files"),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Builder(
// //                   builder: (BuildContext context) => _loadingPath
// //                       ? Padding(
// //                           padding: const EdgeInsets.only(bottom: 10.0),
// //                           child: const CircularProgressIndicator(),
// //                         )
// //                       : _directoryPath != null
// //                           ? ListTile(
// //                               title: const Text('Directory path'),
// //                               subtitle: Text(_directoryPath),
// //                             )
// //                           : _paths != null
// //                               ? Container(
// //                                   padding: const EdgeInsets.only(bottom: 30.0),
// //                                   height:
// //                                       MediaQuery.of(context).size.height * 0.50,
// //                                   child: Scrollbar(
// //                                       child: ListView.separated(
// //                                     itemCount:
// //                                         _paths != null && _paths.isNotEmpty
// //                                             ? _paths.length
// //                                             : 1,
// //                                     itemBuilder:
// //                                         (BuildContext context, int index) {
// //                                       final bool isMultiPath =
// //                                           _paths != null && _paths.isNotEmpty;
// //                                       final String name = 'File $index: ' +
// //                                           (isMultiPath
// //                                               ? _paths
// //                                                   .map((e) => e.name)
// //                                                   .toList()[index]
// //                                               : _fileName ?? '...');
// //                                       final path = _paths
// //                                           .map((e) => e.path)
// //                                           .toList()[index]
// //                                           .toString();

// //                                       return ListTile(
// //                                         title: Text(
// //                                           name,
// //                                         ),
// //                                         subtitle: Text(path),
// //                                       );
// //                                     },
// //                                     separatorBuilder:
// //                                         (BuildContext context, int index) =>
// //                                             const Divider(),
// //                                   )),
// //                                 )
// //                               : const SizedBox(),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         )),
// //       ),
// //     );
// //   }
// // }
