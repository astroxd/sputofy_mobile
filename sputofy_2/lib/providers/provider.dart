import 'package:flutter/foundation.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/services/database.dart';

class DBProvider extends ChangeNotifier {
  late DBHelper _database;

  Future<List<Song>>? _playlistSongs;
  Future<List<Song>>? get playlistSongs => _playlistSongs;

  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;
  bool isAlphabeticalOrder = false;

  Future<List<Song>>? _songs;
  Future<List<Song>>? get songs => _songs;

  DBProvider() {
    _database = DBHelper();
    getSongs();
    getPlaylists();
  }

  Future<List<Song>> getPlaylistSongs(int playlistID) async {
    _playlistSongs = _database.getPlaylistSongs(playlistID);
    // notifyListeners();
    return await _database.getPlaylistSongs(playlistID);
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
    List<Playlist> playlists = await _database.getPlaylists();

    //*sortDirection
    if (isAlphabeticalOrder) {
      playlists.sort((a, b) => a.name.compareTo(b.name));
    } else {
      playlists.sort((a, b) => b.name.compareTo(a.name));
    }

    _playlists = playlists;
    notifyListeners();
  }

  void sortPlaylists() {
    isAlphabeticalOrder = !isAlphabeticalOrder;
    notifyListeners();
  }

  Future<void> savePlaylist(Playlist playlist) async {
    _database.savePlaylist(playlist);
    getPlaylists();
    notifyListeners();
  }

  Future<void> deletePlaylist(int playlistID) async {
    _database.deleteAllPlaylistSongs(playlistID);
    _database.deletePlaylist(playlistID);
    getPlaylists();
    notifyListeners();
  }

  Future<void> getSongs() async {
    _songs = _database.getSongs();
  }

  Future<void> saveSong(Song song) async {
    _database.saveSong(song);
    notifyListeners();
  }

  Future<void> deleteSong(int songID) async {
    _database.deleteSong(songID);
    getSongs();
    notifyListeners();
  }
}
