// TestWidgetsFlutterBinding.ensureInitialized()

// Database db;

// class DBProvider {
//   DBProvider._();
//   static final DBProvider db = DBProvider._();
//   static Database _database;

//   Future<Database> get database async {
//     if (_database != null) return _database;

//     _database = await initDB();
//     return _database;
//   }

//   initDB() async {
//     return await openDatabase(
//       join(await getDatabasesPath(), 'database.db'),
//       onCreate: (db, version) async {
//         await db.execute('''
//         CREATE TABLE playlist (
//           title TEXT PRIMARY KEY, path TEXT
//         )''');
//       },
//       version: 1,
//     );
//   }

//   Future<void> insertPlaylist(Playlist playlist) async {
//     final Database db = await database;

//     await db.insert('playlist', playlist.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   Future<List<Playlist>> getPlaylist() async {
//     final Database db = await database;

//     final List<Map<String, dynamic>> maps = await db.query('playlist');

//     return List.generate(maps.length, (i) {
//       return Playlist(
//         maps[i]['title'],
//         maps[i]['path'],
//       );
//     });
//   }
// }

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'playlist_table';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnSongPath = 'song_path';

  DBProvider._privateConstructor();
  static final DBProvider instance = DBProvider._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnSongPath TEXT NOT NULL
    )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }
}
