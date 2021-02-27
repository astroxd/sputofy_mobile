import 'package:flutter/material.dart';
import 'package:sputofy_2/model/folderPathmodel.dart';
import 'package:sputofy_2/model/playlistModel.dart';
import 'package:sputofy_2/model/playlistSongsModel.dart';
import 'package:sputofy_2/utils/Database.dart';

class DatabaseValue extends ChangeNotifier {
  Future<List<Playlist>> playlists;
  Future<List<FolderPath>> paths;
  Future<List<PlaylistSongs>> playlistSongs;
  var dbHelper = DBHelper();

  DatabaseValue() {
    playlists = dbHelper.getPlaylist();
    paths = dbHelper.getFolderPath();
    notifyListeners();
  }

  void savePlaylist(Playlist playlist) {
    dbHelper.savePlaylist(playlist);
    playlists = dbHelper.getPlaylist();
    notifyListeners();
  }

  void deletePlaylist(int id) {
    dbHelper.deletePlaylist(id);
    playlists = dbHelper.getPlaylist();
    notifyListeners();
  }

  void getPaths() {
    paths = dbHelper.getFolderPath();
    notifyListeners();
  }

  void saveFolder(FolderPath folderPath) {
    dbHelper.saveFolder(folderPath);
    paths = dbHelper.getFolderPath();
    notifyListeners();
  }

  void deleteFolder(String path) {
    dbHelper.deleteFolder(path);
    paths = dbHelper.getFolderPath();
    notifyListeners();
  }

  void addSongs(int id, List<String> paths) {
    dbHelper.savePlaylistSongs(id, paths);
    playlistSongs = dbHelper.getPlaylistSongs(id);
    notifyListeners();
  }

  void retrieveSongs(int id) async {
    playlistSongs = dbHelper.getPlaylistSongs(id);
    notifyListeners();
  }

  void deletePlaylistSong(int playlistId, String songPath) {
    dbHelper.deletePlaylistSong(playlistId, songPath);
    playlistSongs = dbHelper.getPlaylistSongs(playlistId);
    notifyListeners();
  }

  void deleteAllPlaylistSongs(int playlistId, List<String> songPaths) {
    dbHelper.deleteAllPlaylistSongs(playlistId, songPaths);
  }

  Future<List<PlaylistSongs>> getPlaylistSongs(int id) async {
    return await dbHelper.getPlaylistSongs(id);
  }
}
