class Playlist {
  int id;
  String name;
  String songPath;

  Playlist(this.id, this.name, this.songPath);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'song_path': songPath,
    };
    return map;
  }

  Playlist.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    songPath = map['song_path'];
  }
}
