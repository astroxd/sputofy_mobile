import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'crop_image.dart';

Future<File?> pickImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
  );
  if (result != null) {
    String pickedImagePath = result.files.first.path!;
    File? file = await cropImage(pickedImagePath);

    return file == null ? null : file;
  } else {
    return null;
  }
}
