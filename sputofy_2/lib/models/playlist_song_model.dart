class PlaylistSong {
  int? id;
  late int playlistID;
  late int songID;

  PlaylistSong(this.id, this.playlistID, this.songID);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'playlist_id': playlistID,
      'song_id': songID,
    };
    return map;
  }

  PlaylistSong.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    playlistID = map['playlist_id'];
    songID = map['song_id'];
  }
}
