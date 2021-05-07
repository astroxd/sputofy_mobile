// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sputofy_2/model/folderPathmodel.dart';
// import 'package:sputofy_2/model/playlistModels.dart';
// import 'package:sputofy_2/model/playlistSongsModel.dart';
// import 'package:sputofy_2/utils/Database.dart';

// class DatabaseValue extends ChangeNotifier {
//   Future<List<Playlist>> playlists;
//   Future<List<FolderPath>> paths;
//   Future<List<PlaylistSongs>> playlistSongs;
//   var dbHelper = DBHelper();

//   DatabaseValue() {
//     playlists = dbHelper.getPlaylist();
//     paths = dbHelper.getFolderPath();
//     notifyListeners();
//   }

//   void savePlaylist(Playlist playlist) {
//     dbHelper.savePlaylist(playlist);
//     playlists = dbHelper.getPlaylist();
//     notifyListeners();
//   }

//   void deletePlaylist(int id) {
//     dbHelper.deletePlaylist(id);
//     playlists = dbHelper.getPlaylist();
//     notifyListeners();
//   }

//   void getPaths() {
//     paths = dbHelper.getFolderPath();
//     notifyListeners();
//   }

//   void saveFolder(FolderPath folderPath) {
//     dbHelper.saveFolder(folderPath);
//     paths = dbHelper.getFolderPath();
//     notifyListeners();
//   }

//   void deleteFolder(String path) {
//     dbHelper.deleteFolder(path);
//     paths = dbHelper.getFolderPath();
//     notifyListeners();
//   }

//   void addSongs(int id, List<String> paths) {
//     dbHelper.savePlaylistSongs(id, paths);
//     playlistSongs = dbHelper.getPlaylistSongs(id);
//     notifyListeners();
//   }

//   void retrieveSongs(int id) async {
//     playlistSongs = dbHelper.getPlaylistSongs(id);
//     //DEBUG a quanto pare quando cancella una playlist non aggiorna gli id
//     //quindi se cancelli la playlist 2, la playlist 3 non diventa 2 ma rimane 3
//     //ecco perché funzionano le canzoni
//     List<PlaylistSongs> canzoni = await playlistSongs;
//     print("playlist $id");
//     print(canzoni);
//     canzoni.forEach((canzone) => print(canzone.id));
//     notifyListeners();
//   }

//   void deletePlaylistSong(int playlistId, String songPath) {
//     dbHelper.deletePlaylistSong(playlistId, songPath);
//     playlistSongs = dbHelper.getPlaylistSongs(playlistId);
//     notifyListeners();
//   }

//   void deleteAllPlaylistSongs(int playlistId) {
//     dbHelper.deleteAllPlaylistSongs(playlistId);
//   }

//   Future<List<PlaylistSongs>> getPlaylistSongs(int id) async {
//     return await dbHelper.getPlaylistSongs(id);
//   }
// }
