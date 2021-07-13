import 'package:flutter/foundation.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/services/database.dart';

class DBProvider extends ChangeNotifier {
  late DBHelper _database;

  List<Song> _playlistSongs = [];
  List<Song> get playlistSongs => _playlistSongs;

  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;
  // !DEPRECATED bool isAlphabeticalOrder = false;

  List<Song> _songs = [];
  List<Song> get songs => _songs;

  Playlist? _watchingPlaylist;
  Playlist? get watchingPlaylist => _watchingPlaylist;

  DBProvider() {
    _database = DBHelper();
    getSongs();
    getPlaylists();
    notifyListeners();
  }

  Future<void> getPlaylistSongs(int playlistID) async {
    // if (playlistID == 0) {
    //   _playlistSongs = await _database.getFavoriteSongs();
    // } else {
    //   _playlistSongs = await _database.getPlaylistSongs(playlistID);
    // }
    _playlistSongs = await _database.getPlaylistSongs(playlistID);
    notifyListeners();
  }

  //TODO review
  Future<List<Song>> testGetPlaylistSongs(int playlistID) async {
    return await _database.getPlaylistSongs(playlistID);
  }

  Future<void> savePlaylistSongs(
      int playlistID, List<PlaylistSong> songs) async {
    for (var i = 0; i < songs.length; i++) {
      _database.savePlaylistSong(songs[i]);
    }
    getPlaylistSongs(playlistID);
    notifyListeners();
  }

  Future<void> deletePlaylistSong(int playlistID, int songID) async {
    _database.deletePlaylistSong(playlistID, songID);
    getPlaylistSongs(playlistID);
    notifyListeners();
  }

  Future<void> getPlaylists() async {
    List<Playlist> playlists = await _database.getPlaylists();

    //*sortDirection
    // if (isAlphabeticalOrder) {
    //   playlists.sort((a, b) => a.name.compareTo(b.name));
    // } else {
    //   playlists.sort((a, b) => b.name.compareTo(a.name));
    // }
    _playlists = playlists;
    notifyListeners();
  }

  Future<void> getPlaylist(int playlistID) async {
    _watchingPlaylist = await _database.getPlaylist(playlistID);
    notifyListeners();
  }

  ///!DEPRECATED
  // void sortPlaylists() {
  //   isAlphabeticalOrder = !isAlphabeticalOrder;
  //   notifyListeners();
  // }

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

  Future<void> updatePlaylist(Playlist playlist) async {
    print(await _database.updatePlaylist(playlist));
    getPlaylists();
    getPlaylist(playlist.id!);
    notifyListeners();
  }

  Future<void> getSongs() async {
    _songs = await _database.getSongs();
    notifyListeners();
  }

  Future<void> saveSong(Song song) async {
    await _database.saveSong(song);
    getSongs();
    notifyListeners();
  }

  Future<void> deleteSong(int songID) async {
    await _database.deleteSong(songID);
    getSongs();
    notifyListeners();
  }

  Future<void> updateSong(Song song, {Playlist? playlist}) async {
    await _database.updateSong(song);
    getSongs();
    if (playlist != null) {
      getPlaylistSongs(playlist.id!);
    }
    notifyListeners();
  }
}
