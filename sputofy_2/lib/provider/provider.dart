import 'package:flutter/foundation.dart';
import 'package:sputofy_2/model/PlaylistSongModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/utils/Database.dart';

class DBProvider extends ChangeNotifier {
  DBHelper _database;

  Future<List<Song>> _playlistSongs;
  Future<List<Song>> get playlistSongs => _playlistSongs;

  DBProvider() {
    _database = DBHelper();
  }

  Future<void> getPlaylistSongs(int playlistID) async {
    _playlistSongs = _database.getPlaylistSongs(playlistID);
    // notifyListeners();
  }

  Future<void> savePlaylistSongs(
      int playlistID, List<PlaylistSong> songs) async {
    for (var i = 0; i < songs.length; i++) {
      _database.savePlaylistSong(songs[i]);
    }
    notifyListeners();
  }

  Future<void> deletePlaylistSong(int playlistID, int songID) async {
    _database.deletePlaylistSong(playlistID, songID);
    notifyListeners();
  }
}
