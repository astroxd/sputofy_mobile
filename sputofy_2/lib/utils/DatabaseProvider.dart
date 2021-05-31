import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sputofy_2/model/SongModel.dart';
import 'package:sputofy_2/utils/Database.dart';

List<String> CONTACTS = ["CACCA1", "CACCA2"];

abstract class CounterEvent {}

class IncrementEvent extends CounterEvent {}

class DecrementEvent extends CounterEvent {}

class Bloc {
  int _counter = 0;

  final _counterStateController = StreamController<int>();
  StreamSink<int> get _inCounter => _counterStateController.sink;

  Stream<int> get counter => _counterStateController.stream;

  final _counterEventController = StreamController<CounterEvent>();

  Sink<CounterEvent> get counterEventSink => _counterEventController.sink;

  Bloc() {
    _counterEventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(CounterEvent event) {
    if (event is IncrementEvent) {
      _counter++;
    } else
      _counter--;

    _inCounter.add(_counter);
  }

  void dispose() {
    _counterStateController.close();
    _counterEventController.close();
  }

  // Future<List<Song>> playlistSong;
  // DBHelper _database = DBHelper();
  // StreamController<List<Song>> controller = StreamController<List<Song>>();
  // Stream<List<Song>> get playlistSongs => controller.stream;
  // async* {
  //   // _database.getPlaylistSongs(1);
  //   // for (var i = 0; i < CONTACTS.length; i++) {
  //   //   yield CONTACTS.sublist(0, i + 1);
  //   // }
  // Stream.fromFuture(_database.getPlaylistSongs(1));
  // }

}
