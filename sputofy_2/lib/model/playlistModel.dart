class Playlist {
  int id;
  String name;
  String cover;
  DateTime creationDate;
  Duration duration;

  Playlist(this.id, this.name, this.cover, this.creationDate, this.duration);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'cover': cover,
      'creation_date': creationDate.millisecondsSinceEpoch,
      'duration': duration.inMilliseconds,
    };
    return map;
  }

  Playlist.fromMap(Map<String, dynamic> map) {
    print(map['id']);
    print(map['name']);
    print(map['cover']);
    print(map['creation_date']);
    print(map['duration']);
    id = map['id'];
    name = map['map'];
    cover = map['cover'];
    creationDate = DateTime.fromMillisecondsSinceEpoch(map['creation_date']);
    duration = Duration(milliseconds: map['duration']);
  }
}
