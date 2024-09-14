import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class PicturePlaceholder extends StatelessWidget {
  const PicturePlaceholder({super.key, required this.title, this.file});

  final String title;
  final File? file;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return FutureBuilder(
          future: file?.readAsBytes(),
          builder: (context, AsyncSnapshot<Uint8List> snapshot) {
            return snapshot.hasData && snapshot.data != null
                ? Image.memory(
                snapshot.data!,
                fit: BoxFit.contain,
                                  )
                : _noImageWidget(context);
          });
    }
    return _noImageWidget(context);
  }

  DottedBorder _noImageWidget(BuildContext context) {
    return DottedBorder(
      padding: const EdgeInsets.all(24),
      radius: const Radius.circular(8),
      color: Colors.grey,
      borderType: BorderType.RRect,
      strokeWidth: 1,
      dashPattern: const [5, 4],
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
      ),
    );
  }
}
