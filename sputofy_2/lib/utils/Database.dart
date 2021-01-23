import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sputofy_2/model/playlistModel.dart';
import 'package:sqflite/sqflite.dart';

// TestWidgetsFlutterBinding.ensureInitialized()

// Database db;

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE playlist (
          title TEXT PRIMARY KEY, path TEXT
        )''');
      },
      version: 1,
    );
  }

  Future<void> insertPlaylist(Playlist playlist) async {
    final Database db = await database;

    await db.insert('playlist', playlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Playlist>> getPlaylist() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('playlist');

    return List.generate(maps.length, (i) {
      return Playlist(
        maps[i]['title'],
        maps[i]['path'],
      );
    });
  }
}
