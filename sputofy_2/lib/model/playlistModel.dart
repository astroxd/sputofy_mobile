class Playlist {
  final String title;
  final String path;

  Playlist(this.title, this.path);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'path': path,
    };
  }

  @override
  String toString() {
    return 'Playlist{title: $title, path: $path}';
  }
}
