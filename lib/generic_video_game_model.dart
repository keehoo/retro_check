import 'package:hive/hive.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:uuid/v4.dart';

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
  @HiveField(7)
  final String? uuid;

  VideoGameModel(
      {required this.uuid,
      required this.title,
      required this.description,
      required this.platform,
      required this.ean,
      required this.imageUrl,
      required this.imageBase64});

  factory VideoGameModel.fromItems(Items item) {
    return VideoGameModel(
        title: item.title ?? "",
        description: item.description,
        platform: _getGaminPlatformFromItem(),
        ean: item.ean,
        uuid: const UuidV4().generate(),
        imageUrl: item.images?.firstOrNull ?? "",
        imageBase64: null);
  }

  static GamingPlatform _getGaminPlatformFromItem() {
    return GamingPlatform(twitchiId: "", name: 'no name');
  }

  VideoGameModel copyWithBase64Image({
    String? title,
    String? description,
    GamingPlatform? platform,
    String? ean,
    String? imageUrl,
    required String imageBase64,
  }) {
    return VideoGameModel(
      title: this.title,
      description: this.description,
      platform: this.platform,
      ean: this.ean,
      imageUrl: null,
      uuid: uuid,
      imageBase64: imageBase64,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'platform': platform.name,
      'ean': ean,
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'uuid': uuid,
    };
  }

  factory VideoGameModel.fromMap(Map<String, dynamic> map) {
    return VideoGameModel(
      title: map['title'] as String,
      description: map['description'] as String,
      platform: map['platform'] as GamingPlatform,
      ean: map['ean'] as String,
      imageUrl: map['imageUrl'] as String,
      imageBase64: map['imageBase64'] as String,
      uuid: map['uuid'] as String,
    );
  }
}

@HiveType(typeId: 5)
class GamingPlatform {
  @HiveField(1)
  final String twitchiId;
  @HiveField(2)
  final String name;

  GamingPlatform({required this.twitchiId, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'twitchiId': this.twitchiId,
      'name': this.name,
    };
  }

  factory GamingPlatform.fromJson(Map<String, dynamic> map) {
    return GamingPlatform(
      twitchiId: map['twitchiId'] as String,
      name: map['name'] as String,
    );
  }
}
