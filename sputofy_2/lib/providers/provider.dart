import 'package:flutter/foundation.dart';
import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';
import 'package:sputofy_2/services/database.dart';

class DBProvider extends ChangeNotifier {
  late DBHelper _database;

  List<Song> _playlistSongs = [];
  List<Song> get playlistSongs => _playlistSongs;
  bool playlistSongsAlphabeticalOrder = false;

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
    List<Song> songs = await _database.getPlaylistSongs(playlistID);
    if (playlistSongsAlphabeticalOrder) {
      songs.sort((a, b) => a.title.compareTo(b.title));
    } else {
      songs.sort((a, b) => b.title.compareTo(a.title));
    }
    _playlistSongs = songs;
    notifyListeners();
  }

  void sortPlaylistSongs(int playlistID) {
    playlistSongsAlphabeticalOrder = !playlistSongsAlphabeticalOrder;
    getPlaylistSongs(playlistID);
  }

  Future<List<Song>> retrievePlaylistSongs(int playlistID) async {
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
    _database.updatePlaylist(playlist);
    getPlaylists();
    getPlaylist(playlist.id!);
    notifyListeners();
  }

  Future<void> getSongs() async {
    _songs = await _database.getSongs();
    notifyListeners();
  }

  Future<Song> saveSong(Song song) async {
    Song songWithID = await _database.saveSong(song);
    getSongs();
    notifyListeners();
    return songWithID;
  }

  Future<void> deleteSong(int? songID) async {
    await _database.deleteSong(songID);
    getSongs();
    notifyListeners();
  }

  Future<void> updateSong(Song song, {Playlist? playlist}) async {
    await _database.updateSong(song);
    getSongs();
    //* Used for update song in playlist songs list
    if (playlist != null) {
      getPlaylistSongs(playlist.id!);
    }
    notifyListeners();
  }
}
