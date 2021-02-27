import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/model/databaseValues.dart';
import 'package:sputofy_2/model/folderPathmodel.dart';
import 'package:sputofy_2/model/playlistSongsModel.dart';
import 'package:sputofy_2/palette.dart';
import 'package:sputofy_2/utils/CustomExpansionTile.dart';

class SelectableSongList extends StatefulWidget {
  final int playlistID;
  final List<PlaylistSongs> playlistSongs;

  const SelectableSongList({Key key, this.playlistID, this.playlistSongs})
      : super(key: key);
  @override
  _SelectableSongListState createState() => _SelectableSongListState();
}

class _SelectableSongListState extends State<SelectableSongList> {
  List<FileSystemEntity> loadSingleFolderItem(String path) {
    Directory folder = Directory(path);
    List<FileSystemEntity> files = folder.listSync();
    var toRemove = [];
    for (FileSystemEntity file in files) {
      if (file is Directory) {
        toRemove.add(file);
      }
      if (!file.path.endsWith('mp3') || file.path.endsWith('ogg')) {
        toRemove.add(file);
      }
    }

    files.removeWhere((e) => toRemove.contains(e));

    return files;
  }

  String getFileName(FileSystemEntity file) {
    List<String> splittedPath = file.path.split("/");
    return splittedPath[splittedPath.length - 1].replaceAll(".mp3", "");
  }

  List<String> selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MaterialButton(
              child: Text(
                "ADD SONGS",
                style: TextStyle(
                    color: selectedFiles.length == 0
                        ? secondaryColor
                        : accentColor),
              ),
              onPressed: selectedFiles.length == 0
                  ? null
                  : () {
                      Provider.of<DatabaseValue>(context, listen: false)
                          .addSongs(
                        widget.playlistID,
                        selectedFiles,
                      );
                      Navigator.of(context).pop();
                    },
              splashColor: Colors.transparent,
            ),
            Expanded(
              child: FutureBuilder(
                future: Provider.of<DatabaseValue>(context).paths,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        FolderPath folder = snapshot.data[index];
                        List<FileSystemEntity> folderContent =
                            loadSingleFolderItem(folder.path);
                        return GestureDetector(
                          child: Theme(
                            data: ThemeData(
                                accentColor: secondaryColor,
                                unselectedWidgetColor: secondaryColor),
                            child: CustomExpansionTile(
                              initiallyExpanded: true,
                              title: Text(
                                folder.path.split("/").last.toString(),
                                style: TextStyle(color: accentColor),
                              ),
                              subtitle: Text(
                                "${folderContent.length} songs",
                                style:
                                    TextStyle(fontSize: 14, color: thirdColor),
                              ),
                              children: [expandedContent(folderContent)],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget expandedContent(List<FileSystemEntity> folderContent) {
    List<String> dynamicPlaylistSongs = [];
    widget.playlistSongs
        .forEach((song) => dynamicPlaylistSongs.add(song.songPath));
    return ListView.builder(
      shrinkWrap: true,
      itemCount: folderContent.length,
      itemBuilder: (context, index) {
        return dynamicPlaylistSongs.contains(folderContent[index].path)
            ? _unselectableSong(folderContent[index])
            : _selectableSong(folderContent[index]);
      },
    );
  }

  Widget _selectableSong(FileSystemEntity song) {
    return GestureDetector(
      onTap: () {
        //DEBUG
        // print("cliccato ${song.path}");
        if (selectedFiles.contains(song.path)) {
          // print("lo contiene");
          setState(() {
            selectedFiles.remove(song.path);
          });
        } else {
          // print("non lo contiene");
          setState(() {
            selectedFiles.add(song.path);
          });
        }
        // print(selectedFiles);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    getFileName(song),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.check_box,
                  color: selectedFiles.contains(song.path)
                      ? Colors.blue
                      : Colors.red,
                )
              ],
            ),
          ),
          Divider(
            thickness: .5,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  Widget _unselectableSong(FileSystemEntity song) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  getFileName(song),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.check_box,
                color: Color.fromARGB(40, 255, 0, 255),
              )
            ],
          ),
        ),
        Divider(
          thickness: .5,
          color: Colors.black,
        )
      ],
    );
  }
}
