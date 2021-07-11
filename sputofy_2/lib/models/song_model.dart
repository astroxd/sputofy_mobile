import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';

class Song {
  int? id;
  late String path;
  late String title;
  String? author;
  Uint8List? cover;
  Duration? duration;
  bool isFavorite = true;

  Song(
    this.id,
    this.path,
    this.title,
    this.author,
    this.cover,
    this.duration,
    this.isFavorite,
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'path': path,
      'title': title,
      'author': author ?? '',
      'cover': cover,
      'duration': duration?.inMilliseconds ?? 0,
      'is_favorite': isFavorite ? 1 : 0,
    };
    return map;
  }

  Song.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    path = map['path'];
    title = map['title'];
    author = map['author'];
    cover = map['cover'];
    duration = Duration(milliseconds: map['duration']);
    isFavorite = map['is_favorite'] == 1 ? true : false;
  }

  MediaItem toMediaItem() {
    MediaItem item = MediaItem(
      id: path,
      album: '${-2}',
      title: title,
      duration: duration,
      artUri: cover != null
          ? Uri.file('/storage/emulated/0/Download/album.jpg')
          : null,
      rating: Rating.newHeartRating(isFavorite),
      extras: <String, dynamic>{
        'id': id,
      },
    );
    return item;
  }

  Song.fromMediaItem(MediaItem mediaItem) {
    id = mediaItem.extras!['id'];
    path = mediaItem.id;
    title = mediaItem.title;
    author = mediaItem.artist;

    cover = mediaItem.artUri != null
        ? File.fromUri(mediaItem.artUri!).readAsBytesSync()
        : null;
    duration = mediaItem.duration;
    isFavorite = mediaItem.rating?.hasHeart() ?? false;
  }

  copyWith({
    int? id,
    String? path,
    String? title,
    String? author,
    Uint8List? cover,
    Duration? duration,
    bool? isFavorite,
  }) =>
      Song(
        id ?? this.id,
        path ?? this.path,
        title ?? this.title,
        author ?? this.author,
        cover ?? this.cover,
        duration ?? this.duration,
        isFavorite ?? this.isFavorite,
      );
}
