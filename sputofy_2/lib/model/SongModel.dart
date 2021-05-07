class Song {
  int id;
  String path;
  String title;
  String author;
  String cover;
  Duration duration;
  // int duration;

  Song(this.id, this.path, this.title, this.author, this.cover, this.duration);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'path': path,
      'title': title,
      'author': author,
      'cover': cover,
      'duration': duration.inMilliseconds,
    };
    return map;
  }

  Song.fromMap(Map<String, dynamic> map) {
    print(map['duration']);
    print(map['id']);
    print(map['title']);
    print(map['author']);
    print(map['cover']);
    id = map['id'];
    path = map['path'];
    title = map['title'];
    author = map['author'];
    cover = map['cover'];
    // duration = map['duration'];
    duration = Duration(milliseconds: map['duration']);
    // duration = Duration(milliseconds: map['duration']);
    // duration = Duration(milliseconds: 30);
  }
}
