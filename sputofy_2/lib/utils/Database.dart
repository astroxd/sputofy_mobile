import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sputofy_2/model/folderPathmodel.dart';
import 'package:sputofy_2/model/playlistModels.dart';
import 'package:sputofy_2/model/playlistSongsModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// class DBProvider {
//   static final _databaseName = "MyDatabase.db";
//   static final _databaseVersion = 1;

//   static final table = 'playlist_table';

//   static final columnId = 'id';
//   static final columnName = 'name';
//   static final columnSongPath = 'song_path';

//   DBProvider._privateConstructor();
//   static final DBProvider instance = DBProvider._privateConstructor();

//   static Database _database;

//   Future<Database> get database async {
//     if (_database != null) return _database;

//     _database = await _initDatabase();
//     return _database;
//   }

//   _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, _databaseName);
//     return await openDatabase(path,
//         version: _databaseVersion, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//     CREATE TABLE $table (
//       $columnId INTEGER PRIMARY KEY,
//       $columnName TEXT NOT NULL,
//       $columnSongPath TEXT NOT NULL
//     )
//     ''');
//   }

//   Future<int> insert(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     return await db.insert(table, row);
//   }

//   Future<List<Map<String, dynamic>>> queryAllRows() async {
//     Database db = await instance.database;
//     return await db.query(table);
//   }

//   Future<int> update(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     int id = row[columnId];
//     return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
//   }

//   Future<int> delete(int id) async {
//     Database db = await instance.database;
//     return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
//   }

//   Future<int> queryRowCount() async {
//     Database db = await instance.database;
//     return Sqflite.firstIntValue(
//         await db.rawQuery('SELECT COUNT(*) FROM $table'));
//   }
// }

class DBHelper {
  static Database _db;
  static const String DB_NAME = 'NewNewNewNewNewNewNewNewDatabase.db';
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String TABLE = 'Playlist';
  static const String TABLE2 = 'folder_path';
  static const String PATH = 'path';
  static const String TABLE3 = 'playlist_songs_path';
  static const String SONGPATH = 'song_path';
  static const String PLAYLIST_ID = 'id';

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
      CREATE TABLE $TABLE2 (       
        $PATH TEXT PRIMARY KEY
      )
      ''');
    await db.execute('''
      CREATE TABLE $TABLE (       
        $ID INTEGER PRIMARY KEY,
        $NAME TEXT NOT NULL
      )
      ''');
    await db.execute('''
      CREATE TABLE $TABLE3 (
        $PLAYLIST_ID INTEGER NOT NULL,
        $SONGPATH TEXT NOT NULL
      )
    ''');
  }

  /// Playlist function ///
  Future<List<Playlist>> getPlaylist() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, NAME]);
    List<Playlist> playlists = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        playlists.add(Playlist.fromMap(maps[i]));
      }
    }
    return playlists;
  }

  Future<Playlist> savePlaylist(Playlist playlist) async {
    var dbClient = await db;
    playlist.id = await dbClient.insert(TABLE, playlist.toMap());
    return playlist;
  }

  Future<int> deletePlaylist(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> updatePlaylist(Playlist playlist) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, playlist.toMap(),
        where: '$ID = ?', whereArgs: [playlist.id]);
  }

  /// PlaylistSongs function ///
  Future<List<PlaylistSongs>> getPlaylistSongs(int id) async {
    var dbClient = await db;
    List<Map> map = await dbClient.query(TABLE3,
        columns: [PLAYLIST_ID, SONGPATH],
        where: '$PLAYLIST_ID = ?',
        whereArgs: [id]);
    List<PlaylistSongs> songs = [];
    if (map.length > 0) {
      for (int i = 0; i < map.length; i++) {
        songs.add(PlaylistSongs.fromMap(map[i]));
      }
    }
    return songs;
  }

  Future savePlaylistSongs(int playlistId, List<String> songsPath) async {
    var dbClient = await db;
    songsPath.forEach((songPath) async {
      PlaylistSongs playlistSong = PlaylistSongs(playlistId, songPath);
      await dbClient.insert(TABLE3, playlistSong.toMap());
    });
  }

  Future<int> deletePlaylistSong(int playlistId, String songPath) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE3,
        where: '$PLAYLIST_ID = ? and $SONGPATH = ?',
        whereArgs: [playlistId, songPath]);
  }

  Future deleteAllPlaylistSongs(int playlistId) async {
    var dbClient = await db;
    await dbClient
        .delete(TABLE3, where: '$PLAYLIST_ID = ?', whereArgs: [playlistId]);
  }

  /// FolderPaths function ///
  Future<List<FolderPath>> getFolderPath() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE2, columns: [PATH]);
    List<FolderPath> paths = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        paths.add(FolderPath.fromMap(maps[i]));
      }
    }
    return paths;
  }

  Future<FolderPath> saveFolder(FolderPath folderPath) async {
    var dbClient = await db;
    await dbClient.insert(TABLE2, folderPath.toMap());
    return folderPath;
  }

  Future<int> deleteFolder(String path) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE2, where: '$PATH = ?', whereArgs: [path]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
