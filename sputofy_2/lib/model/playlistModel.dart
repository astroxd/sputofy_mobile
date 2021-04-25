import 'dart:ffi';

class Playlist {
  int id;
  String name;
  String cover;
  int creationDate;
  int duration;

  Playlist(this.id, this.name, this.cover, this.creationDate, this.duration);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'cover': cover,
      'creation_date': creationDate,
      'duration': duration,
    };
    return map;
  }

  Playlist.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['map'];
    cover = map['cover'];
    creationDate = map['creation_date'];
    duration = map['duration'];
  }
}
