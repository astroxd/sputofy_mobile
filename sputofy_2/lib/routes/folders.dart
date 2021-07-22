import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> songPath() async {
  Directory documentsDir = await getApplicationDocumentsDirectory();
  String finalDir = join(documentsDir.path, 'song');

  return finalDir;
}

Future<String> playlistPath() async {
  Directory documentsDir = await getApplicationDocumentsDirectory();
  String finalDir = join(documentsDir.path, 'playlist');

  return finalDir;
}
