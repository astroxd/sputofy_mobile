class Playlist {
  int? id;
  late String name;
  Uri? cover;
  late DateTime creationDate;
  bool isHidden = false;

  Playlist(this.id, this.name, this.cover, this.creationDate, this.isHidden);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'cover': cover?.toString() ?? null,
      'creation_date': creationDate.millisecondsSinceEpoch,
      'is_hidden': isHidden ? 1 : 0,
    };
    return map;
  }

  Playlist.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    cover = map['cover'] == null ? null : Uri.parse(map['cover']);
    creationDate = DateTime.fromMillisecondsSinceEpoch(map['creation_date']);
    isHidden = map['is_hidden'] == 1 ? true : false;
  }

  Playlist copyWith({
    int? id,
    String? name,
    Uri? cover,
    DateTime? creationDate,
    bool? isHidden,
  }) =>
      Playlist(
        id ?? this.id,
        name ?? this.name,
        cover ?? this.cover,
        creationDate ?? this.creationDate,
        isHidden ?? this.isHidden,
      );
}
