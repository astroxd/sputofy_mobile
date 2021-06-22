import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sputofy_2/model/PlaylistSongModel.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sputofy_2/model/PlaylistModel.dart';
import 'package:rxdart/rxdart.dart';

class DBHelper {
  static Database _db;
  static const String DB_NAME = 'SSSSSSSSSsssssSSSSSSSSSputofy.db';
  //* SONG TABLE
  static const String SONG_TABLE = 'song';
  static const String SONG_ID = 'id';
  static const String SONG_PATH = 'path';
  static const String SONG_TITLE = 'title';
  static const String SONG_AUTHOR = 'author';
  static const String SONG_COVER = 'cover';
  static const String SONG_DURATION = 'duration';
  //* SONG TABLE

  //* PLAYLIST TABLE
  static const String PLAYLIST_TABLE = 'playlist';
  static const String PLAYLIST_ID = 'id';
  static const String PLAYLIST_NAME = 'name';
  static const String PLAYLIST_COVER = 'cover';
  static const String PLAYLIST_CREATION_DATE = 'creation_date';
  static const String PLAYLIST_DURATION = 'duration';
  //* PLAYLIST TABLE

  //* PLAYLIST SONG TABLE
  static const String PLAYLISTSONG_TABLE = 'playlist_song';
  static const String PLAYLISTSONG_ID = 'id';
  static const String PLAYLISTSONG_PLAYLIST_ID = 'playlist_id';
  static const String PLAYLISTSONG_SONG_ID = 'song_id';
  //* PLAYLIST SONG TABLE

  final StreamController<List<Song>> _controller =
      StreamController<List<Song>>();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $SONG_TABLE (       
        $SONG_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $SONG_PATH TEXT UNIQUE,
        $SONG_TITLE TEXT NOT NULL,
        $SONG_AUTHOR TEXT,
        $SONG_COVER TEXT,
        $SONG_DURATION INTEGER
      )
      ''');
    await db.execute('''
      CREATE TABLE $PLAYLIST_TABLE (
        $PLAYLIST_ID INTEGER PRIMARY KEY,
        $PLAYLIST_NAME TEXT NOT NULL,
        $PLAYLIST_COVER TEXT,
        $PLAYLIST_CREATION_DATE INTEGER NOT NULL,
        $PLAYLIST_DURATION INTEGER
      )
     ''');

    await db.execute('''
      CREATE TABLE $PLAYLISTSONG_TABLE (
        $PLAYLISTSONG_ID INTEGER PRIMARY KEY,
        $PLAYLISTSONG_PLAYLIST_ID INTEGER NOT NULL,
        $PLAYLISTSONG_SONG_ID INTEGER NOT NULL
      )
     ''');
  }

  Future<Song> saveSong(Song song) async {
    var dbClient = await db;
    song.id = await dbClient.insert(SONG_TABLE, song.toMap());
    return song;
  }

  Future<int> deleteSong(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(SONG_TABLE, where: '$SONG_ID = ?', whereArgs: [id]);
  }

  Future<int> updateSong(Song song) async {
    var dbClient = await db;
    return await dbClient.update(SONG_TABLE, song.toMap(),
        where: '$SONG_ID = ?', whereArgs: [song.id]);
  }

  Future<List<Song>> getSongs() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(SONG_TABLE, columns: [
      SONG_ID,
      SONG_PATH,
      SONG_TITLE,
      SONG_AUTHOR,
      SONG_COVER,
      SONG_DURATION
    ]);
    List<Song> songs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        songs.add(Song.fromMap(maps[i]));
      }
    }
    return songs;
  }

  Future<Song> getSong(int songID) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(SONG_TABLE, columns: [
      SONG_ID,
      SONG_PATH,
      SONG_TITLE,
      SONG_AUTHOR,
      SONG_COVER,
      SONG_DURATION
    ]);
    Song song;
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        song = (Song.fromMap(maps[i]));
      }
    }
    return song;
  }

  Future<Playlist> savePlaylist(Playlist playlist) async {
    var dbClient = await db;
    playlist.id = await dbClient.insert(PLAYLIST_TABLE, playlist.toMap());

    return playlist;
  }

  Future<int> deletePlaylist(int playlistID) async {
    var dbClient = await db;
    return await dbClient.delete(PLAYLIST_TABLE,
        where: '$PLAYLIST_ID = ?', whereArgs: [playlistID]);
  }

  Future<int> updatePlaylist(Duration playlistDuration, int playlistID) async {
    var dbClient = await db;
    // return await dbClient.update(PLAYLIST_TABLE, playlist.toMap(),
    //     where: '$PLAYLIST_ID = ?', whereArgs: [playlist.id]);
    return await dbClient.rawUpdate(
      '''
    UPDATE $PLAYLIST_TABLE
    SET $PLAYLIST_DURATION = ?
    WHERE $PLAYLIST_ID = ?
     ''',
      [playlistDuration.inMilliseconds, playlistID],
    );
    //TODO maybe implement
  }

  Future<List<Playlist>> getPlaylists() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(PLAYLIST_TABLE, columns: [
      PLAYLIST_ID,
      PLAYLIST_NAME,
      PLAYLIST_COVER,
      PLAYLIST_CREATION_DATE,
      PLAYLIST_DURATION
    ]);
    List<Playlist> playlists = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        playlists.add(Playlist.fromMap(maps[i]));
      }
    }
    return playlists;
  }

  Future<PlaylistSong> savePlaylistSong(PlaylistSong playlistSong) async {
    var dbClient = await db;
    playlistSong.id =
        await dbClient.insert(PLAYLISTSONG_TABLE, playlistSong.toMap());
    return playlistSong;
  }

  Future<int> deletePlaylistSong(int playlistID, int songID) async {
    var dbClient = await db;
    return await dbClient.delete(PLAYLISTSONG_TABLE,
        where: '$PLAYLISTSONG_PLAYLIST_ID = ? and $PLAYLISTSONG_SONG_ID = ?',
        whereArgs: [playlistID, songID]);
  }

  Future<int> deleteAllPlaylistSongs(int playlistID) async {
    var dbClient = await db;
    return await dbClient.delete(PLAYLISTSONG_TABLE,
        where: '$PLAYLISTSONG_PLAYLIST_ID = ?', whereArgs: [playlistID]);
  }

  //* updatePlaylistSong();

  //! maybe useless
  Future<List<PlaylistSong>> testGetPlaylistSongs(int playlistID) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      PLAYLISTSONG_TABLE,
      columns: [
        PLAYLISTSONG_ID,
        PLAYLISTSONG_PLAYLIST_ID,
        PLAYLISTSONG_SONG_ID
      ],
      where: '$PLAYLISTSONG_PLAYLIST_ID = ?',
      whereArgs: [playlistID],
    );
    List<PlaylistSong> playlistSongs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        playlistSongs.add(PlaylistSong.fromMap(maps[i]));
      }
    }
    return playlistSongs;
  }

  Future<List<Song>> getPlaylistSongs(int playlistID) async {
    var dbClient = await db;
    List<PlaylistSong> playlistSongs = await testGetPlaylistSongs(playlistID);
    List<Song> returnedSongs = [];
    List<Map> maps = [];
    for (int i = 0; i < playlistSongs.length; i++) {
      maps = await dbClient.query(
        SONG_TABLE,
        columns: [
          SONG_ID,
          SONG_PATH,
          SONG_TITLE,
          SONG_AUTHOR,
          SONG_COVER,
          SONG_DURATION
        ],
        where: '$SONG_ID = ?',
        whereArgs: [playlistSongs[i].songID],
      );
      returnedSongs.add(Song.fromMap(maps[0]));
    }
    _controller.add(returnedSongs);
    return returnedSongs;
  }

  Stream<List<Song>> get playlistSongs =>
      _controller.stream.asBroadcastStream();

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
