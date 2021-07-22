import 'dart:io';

Future<File> moveImage(File sourceFile, String newPath) async {
  final newFile = await sourceFile.copy(newPath);
  await sourceFile.delete();
  return newFile;
}
