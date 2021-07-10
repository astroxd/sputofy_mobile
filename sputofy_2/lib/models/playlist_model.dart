import 'dart:typed_data';

class Playlist {
  int? id;
  late String name;
  Uint8List? cover;
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

  Playlist copyWith({
    int? id,
    String? name,
    Uint8List? cover,
    DateTime? creationDate,
  }) =>
      Playlist(
        id ?? this.id,
        name ?? this.name,
        cover ?? this.cover,
        creationDate ?? this.creationDate,
      );
}
