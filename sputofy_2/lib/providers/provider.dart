import 'package:flutter/foundation.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/services/database.dart';

class DBProvider extends ChangeNotifier {
  late DBHelper _database;

  Future<List<Song>>? _playlistSongs;
  Future<List<Song>>? get playlistSongs => _playlistSongs;

  Future<List<Playlist>>? _playlists;
  Future<List<Playlist>>? get playlists => _playlists;
  bool isAlphabeticalOrder = false;

  List<Song> _songs = [];
  List<Song> get songs => _songs;

  DBProvider() {
    _database = DBHelper();
    getSongs();
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

  Future<void> getPlaylists() async {
    Future<List<Playlist>> playlists = _database.getPlaylists();
    //*sortDirection
    if (isAlphabeticalOrder) {
      playlists.then((value) => value.sort((a, b) => a.name.compareTo(b.name)));
    } else {
      playlists.then((value) => value.sort((a, b) => b.name.compareTo(a.name)));
    }

    _playlists = playlists;
  }

  void sortPlaylists() {
    isAlphabeticalOrder = !isAlphabeticalOrder;
    notifyListeners();
  }

  Future<void> savePlaylist(Playlist playlist) async {
    _database.savePlaylist(playlist);
    notifyListeners();
  }

  Future<void> deletePlaylist(int playlistID) async {
    _database.deleteAllPlaylistSongs(playlistID);
    _database.deletePlaylist(playlistID);
    notifyListeners();
  }

  Future<void> getSongs() async {
    _songs = await _database.getSongs();
    notifyListeners();
  }

  Future<void> saveSong(Song song) async {
    _database.saveSong(song);
    getSongs();
    notifyListeners();
  }

  Future<void> deleteSong(int songID) async {
    _database.deleteSong(songID);
    getSongs();
    notifyListeners();
  }
}
