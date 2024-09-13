import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/utils/typedefs/typedefs.dart';

class ImageWidget extends StatelessWidget {
  ImageWidget({super.key, required this.game});

  final VideoGameModel game;

  final AppWriteHandler appWriteHandler = AppWriteHandler();

  @override
  Widget build(BuildContext context) {
    if (game.imageUrl?.startsWith("http") ?? false) {
      return CachedNetworkImage(
        imageUrl: game.imageUrl!,
        errorWidget: (_, __, ___) {
          return getNoPictureImage(
            game,
          );
        },
      );
    }

    if (game.imageBase64 != null) {
      return Image.memory(base64Decode(game.imageBase64!));
    } else {
      return FutureBuilder(
          future: appWriteHandler.getFileDownload(game),
          builder: (context, AsyncSnapshot<Uint8List> snapshot) {
            return snapshot.hasData && snapshot.data != null
                ? Image.memory(snapshot.data!, fit: BoxFit.fill,)
                : getNoPictureImage(game);
          });
    }
  }
}

Widget getNoPictureImage(VideoGameModel game, {BoxFit? fit, VideoGameCallback? onTapped}) {
  final imageWidget = switch (game.gamingPlatformEnum) {
    GamingPlatformEnum.playstation => Image.asset(
        "assets/platforms/playstation/ps4_image_cover.jpeg",
        fit: fit,
      ),
    GamingPlatformEnum.sega => Image.asset(
        "assets/platforms/sega/sega_generic_cover.jpeg",
        fit: fit,
      ),
    GamingPlatformEnum.xbox =>
      Image.asset("assets/platforms/xbox/xbox_generic_cover.jpeg", fit: fit),
    GamingPlatformEnum.nintendo => Image.asset(
        "assets/platforms/nintendo/nintendo_generic_cover.jpeg",
        fit: fit),
    GamingPlatformEnum.unknown => const Icon(
        Icons.no_photography_outlined,
        color: Colors.red,
      )
  };
  return GestureDetector(child: imageWidget, onTap: () => onTapped?.call(game, null));
}
