import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/screens/game_input/picture_placeholder/picture_placeholder_widget.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';
import 'package:untitled/utils/typedefs/typedefs.dart';

class PictureAddGame extends StatefulWidget {
  const PictureAddGame({super.key, required this.onPhotoUpdated});

  final FileCallback onPhotoUpdated;

  @override
  State<PictureAddGame> createState() => _PictureAddGameState();
}

class _PictureAddGameState extends State<PictureAddGame> {
  File? file;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        File? file = await onWantsToTakePicture(context);
        if (file != null) {
          setState(() {
            this.file = file;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Column(
                children: [
                  Text(
                    "some text here",
                    style: context.textStyle.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: PicturePlaceholder(title: "asdsad", file: file))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<File?> onWantsToTakePicture(BuildContext context) async {
    try {
      File pictureFile = await _openCamera();
      widget.onPhotoUpdated(pictureFile);
      return pictureFile;
    } catch (e, s) {
      Lgr.errorLog("Exception while trying to get the picture of the game",
          exception: e, st: s);
    }
    return null;
  }
}

Future<File> _openCamera() async {
  final XFile? imageFile = await ImagePicker()
      .pickImage(source: ImageSource.camera, maxHeight: 500, maxWidth: 500);

  if (imageFile == null) {
    throw "Null image file, most likely cancelled";
  }

  final Uint8List imageBytes = await imageFile.readAsBytes();
  final file = File(imageFile.path);

  file.writeAsBytes(imageBytes.toList());
  return file;
}
