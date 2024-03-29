import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:sputofy_2/models/playlist_model.dart';
import 'package:sputofy_2/models/playlist_song_model.dart';
import 'package:sputofy_2/models/song_model.dart';

class DBHelper {
  static Database? _db;
  static const String DB_NAME = 'unity.db';
  //* SONG TABLE
  static const String SONG_TABLE = 'song';
  static const String SONG_ID = 'id';
  static const String SONG_PATH = 'path';
  static const String SONG_TITLE = 'title';
  static const String SONG_AUTHOR = 'author';
  static const String SONG_COVER = 'cover';
  static const String SONG_DURATION = 'duration';
  static const String SONG_FAVORITE = 'is_favorite';
  //* SONG TABLE

  //* PLAYLIST TABLE
  static const String PLAYLIST_TABLE = 'playlist';
  static const String PLAYLIST_ID = 'id';
  static const String PLAYLIST_NAME = 'name';
  static const String PLAYLIST_COVER = 'cover';
  static const String PLAYLIST_CREATION_DATE = 'creation_date';
  static const String PLAYLIST_DURATION = 'duration';
  static const String PLAYLIST_HIDDEN = 'is_hidden';
  //* PLAYLIST TABLE

  //* PLAYLIST SONG TABLE
  static const String PLAYLISTSONG_TABLE = 'playlist_song';
  static const String PLAYLISTSONG_ID = 'id';
  static const String PLAYLISTSONG_PLAYLIST_ID = 'playlist_id';
  static const String PLAYLISTSONG_SONG_ID = 'song_id';
  //* PLAYLIST SONG TABLE

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path,
        version: 1, onCreate: _onCreate, singleInstance: true);
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
        $SONG_DURATION INTEGER,
        $SONG_FAVORITE INTEGER
      )
      ''');
    await db.execute('''
      CREATE TABLE $PLAYLIST_TABLE (
        $PLAYLIST_ID INTEGER PRIMARY KEY,
        $PLAYLIST_NAME TEXT NOT NULL,
        $PLAYLIST_COVER TEXT,
        $PLAYLIST_CREATION_DATE INTEGER NOT NULL,
        $PLAYLIST_DURATION INTEGER,
        $PLAYLIST_HIDDEN INTEGER
      )
     ''');

    await db.execute('''
      CREATE TABLE $PLAYLISTSONG_TABLE (
        $PLAYLISTSONG_ID INTEGER PRIMARY KEY,
        $PLAYLISTSONG_PLAYLIST_ID INTEGER NOT NULL,
        $PLAYLISTSONG_SONG_ID INTEGER NOT NULL
      )
     ''');

    await db.insert(PLAYLIST_TABLE,
        Playlist(0, 'Favorites', null, DateTime.now(), false).toMap());
  }

//*##########################################################################*//
//*                                   SONG                                   *//
//*##########################################################################*//

  Future<Song> saveSong(Song song) async {
    var dbClient = await db;
    song.id = await dbClient.insert(SONG_TABLE, song.toMap());
    return song;
  }

  Future<int> deleteSong(int? songID) async {
    var dbClient = await db;
    if (songID == null) {
      //*If song is deleted we have to delete it from all the playlists
      await dbClient.delete(PLAYLISTSONG_TABLE);
      return await dbClient.delete(SONG_TABLE);
    } else {
      //*If song is deleted we have to delete it from all the playlists
      await dbClient.delete(PLAYLISTSONG_TABLE,
          where: '$PLAYLISTSONG_SONG_ID = ?', whereArgs: [songID]);
      return await dbClient
          .delete(SONG_TABLE, where: '$SONG_ID = ?', whereArgs: [songID]);
    }
  }

  Future<int> updateSong(Song song) async {
    var dbClient = await db;
    return await dbClient.update(SONG_TABLE, song.toMap(),
        where: '$SONG_ID = ?', whereArgs: [song.id]);
  }

  Future<List<Song>> getSongs() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps =
        await dbClient.query(SONG_TABLE, columns: [
      SONG_ID,
      SONG_PATH,
      SONG_TITLE,
      SONG_AUTHOR,
      SONG_COVER,
      SONG_DURATION,
      SONG_FAVORITE,
    ]);
    List<Song> songs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        songs.add(Song.fromMap(maps[i]));
      }
    }
    return songs;
  }

//*##########################################################################*//
//*                               PLAYLIST                                   *//
//*##########################################################################*//

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

  Future<int> updatePlaylist(Playlist playlist) async {
    var dbClient = await db;
    return await dbClient.update(PLAYLIST_TABLE, playlist.toMap(),
        where: '$PLAYLIST_ID = ?', whereArgs: [playlist.id]);

    //!USE THIS FOR UPDATE JUST ONE FIELD
    // return await dbClient.rawUpdate(
    //   '''
    // UPDATE $PLAYLIST_TABLE
    // SET $PLAYLIST_DURATION = ?
    // WHERE $PLAYLIST_ID = ?
    //  ''',
    //   [playlistDuration.inMilliseconds, playlistID],
    // );
  }

  Future<List<Playlist>> getPlaylists() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(
      PLAYLIST_TABLE,
      columns: [
        PLAYLIST_ID,
        PLAYLIST_NAME,
        PLAYLIST_COVER,
        PLAYLIST_CREATION_DATE,
        PLAYLIST_DURATION,
        PLAYLIST_HIDDEN
      ],
    );

    List<Playlist> playlists = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        playlists.add(Playlist.fromMap(maps[i]));
      }
    }
    return playlists;
  }

  Future<Playlist> getPlaylist(int playlistID) async {
    var dbClient = await db;
    List<Map<String, dynamic>> map = await dbClient.query(
      PLAYLIST_TABLE,
      columns: [
        PLAYLIST_ID,
        PLAYLIST_NAME,
        PLAYLIST_COVER,
        PLAYLIST_CREATION_DATE,
        PLAYLIST_DURATION,
        PLAYLIST_HIDDEN,
      ],
      where: '$PLAYLIST_ID = ?',
      whereArgs: [playlistID],
    );

    //!For calling this function you have to be inside a playlist, so playlist exist
    return Playlist.fromMap(map[0]);
  }

//*##########################################################################*//
//*                              PLAYLISTSONG                                *//
//*##########################################################################*//

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

  Future<List<PlaylistSong>> retrievePlaylistSongs(int playlistID) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(
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
    List<PlaylistSong> playlistSongs = await retrievePlaylistSongs(playlistID);
    List<Song> returnedSongs = [];
    List<Map<String, dynamic>> maps = [];
    for (int i = 0; i < playlistSongs.length; i++) {
      maps = await dbClient.query(
        SONG_TABLE,
        columns: [
          SONG_ID,
          SONG_PATH,
          SONG_TITLE,
          SONG_AUTHOR,
          SONG_COVER,
          SONG_DURATION,
          SONG_FAVORITE,
        ],
        where: '$SONG_ID = ?',
        whereArgs: [playlistSongs[i].songID],
      );
      returnedSongs.add(Song.fromMap(maps[0]));
    }
    return returnedSongs;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
