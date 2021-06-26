class Song {
  int id;
  String path;
  String title;
  String author;
  String cover;
  Duration duration;

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
    id = map['id'];
    path = map['path'];
    title = map['title'];
    author = map['author'];
    cover = map['cover'];
    duration = Duration(milliseconds: map['duration']);
  }
}
