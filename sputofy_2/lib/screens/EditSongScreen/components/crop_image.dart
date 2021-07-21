import 'dart:io';

import 'package:image_cropper/image_cropper.dart';

import 'package:sputofy_2/theme/palette.dart';

Future<File?> cropImage(String filePath) async {
  File? croppedFile = await ImageCropper.cropImage(
    cropStyle: CropStyle.rectangle,
    sourcePath: filePath,
    aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    aspectRatioPresets: [CropAspectRatioPreset.square],
    androidUiSettings: AndroidUiSettings(
      toolbarColor: kAccentColor,
      toolbarWidgetColor: kThirdColor,
      initAspectRatio: CropAspectRatioPreset.square,
    ),
    iosUiSettings: IOSUiSettings(
      minimumAspectRatio: 1.0,
    ),
  );
  return croppedFile;
}
