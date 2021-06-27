class Playlist {
  int? id;
  late String name;
  String? cover;
  late DateTime creationDate;
  // Duration duration;

  // Playlist(this.id, this.name, this.cover, this.creationDate, this.duration);
  Playlist(this.id, this.name, this.cover, this.creationDate);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'cover': cover,
      'creation_date': creationDate.millisecondsSinceEpoch,
      // 'duration': duration!.inMilliseconds,
    };
    return map;
  }

  Playlist.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    cover = map['cover'];
    creationDate = DateTime.fromMillisecondsSinceEpoch(map['creation_date']);
    // duration = Duration(milliseconds: map['duration']);
  }
}
