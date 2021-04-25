class Song {
  int id;
  String title;
  String author;
  String cover;
  int duration;

  Song(this.id, this.title, this.author, this.cover, this.duration);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'author': author,
      'cover': cover,
      'duration': duration,
    };
    return map;
  }

  Song.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    author = map['author'];
    cover = map['cover'];
    duration = map['duration'];
  }
}
