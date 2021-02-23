class PlaylistSongs {
  int id;
  String songPath;

  PlaylistSongs(this.id, this.songPath);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'song_path': songPath,
    };
    return map;
  }

  PlaylistSongs.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    songPath = map['song_path'];
  }
}
