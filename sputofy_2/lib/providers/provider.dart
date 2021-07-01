import 'package:flutter/foundation.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/services/database.dart';

class DBProvider extends ChangeNotifier {
  late DBHelper _database;

  List<Song>? _playlistSongs = [];
  List<Song>? get playlistSongs => _playlistSongs;

  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;
  bool isAlphabeticalOrder = false;

  List<Song> _songs = [];
  List<Song> get songs => _songs;

  DBProvider() {
    _database = DBHelper();
    getSongs();
    getPlaylists();
  }

  Future<void> getPlaylistSongs(int playlistID) async {
    _playlistSongs = await _database.getPlaylistSongs(playlistID);
    notifyListeners();
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
    _songs = await _database.getSongs();
    notifyListeners();
  }

  Future<void> saveSong(Song song) async {
    await _database.saveSong(song);

    notifyListeners();
  }

  Future<void> deleteSong(int songID) async {
    await _database.deleteSong(songID);
    getSongs();
    notifyListeners();
  }
}
