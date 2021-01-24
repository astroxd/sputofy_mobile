import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/utils/Database.dart';

class DatabaseValue extends ChangeNotifier {
  final dbProvider = DBProvider.instance;
  List<String> playlistNames = [];
  List<int> playlistIds = [];

  // DatabaseValue() {
  //   List<String> playlistNames = getDatabaseValue();
  // }

  getDatabaseName() async {
    playlistNames.clear();
    final allRows = await dbProvider.queryAllRows();
    allRows.forEach((row) {
      playlistNames.add(row['name']);
    });
    notifyListeners();
    return playlistNames;
  }

  deletePlaylist() async {
    playlistIds.clear();
    final allRows = await dbProvider.queryAllRows();
    allRows.forEach((row) {
      playlistIds.add(row['id']);
    });
    final rowsDeleted = await dbProvider.delete(playlistIds.length);
    getDatabaseName();
  }
}
