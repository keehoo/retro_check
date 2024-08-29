import 'package:hive/hive.dart';

part 'generic_video_game_model.g.dart';

@HiveType(typeId: 4)
class VideoGameModel {
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final GamingPlatform platform;
  @HiveField(4)
  final String? ean; // bar code number as string
  @HiveField(5)
  final String? imageUrl;
  @HiveField(6)
  final String? imageBase64;

  VideoGameModel(
      {required this.title,
      required this.description,
      required this.platform,
      required this.ean,
      required this.imageUrl,
      required this.imageBase64});
}

@HiveType(typeId: 5)
class GamingPlatform {
  @HiveField(1)
  final String twitchiId;
  @HiveField(2)
  final String name;

  GamingPlatform({required this.twitchiId, required this.name});
}
