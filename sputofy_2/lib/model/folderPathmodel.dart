class FolderPath {
  // int id;
  String path;

  FolderPath(this.path);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'path': path};
    return map;
  }

  FolderPath.fromMap(Map<String, dynamic> map) {
    path = map['path'];
  }
}
