import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/generic_video_game_model.dart';

const twitchClientId = "7ye79qmkzxt2w2w1p42pzk2righnqv";
const twitchClientSecret = "j6766v8gdnbbcq6yrf0b2hu90y9j0m";

final xboxKeywords = [
  "xbox",
  "microsoft",
  "xbox360",
  "xbox 360",
  "xbox one",
  "series s",
  "series x",
  "xbox series x|s"
];

final nintendoKeywords = [
  "n66",
  "gameboy",
  "game boy",
  "game boy color",
  "nintendo",
  "nintendo switch",
  "super famicon",
  "famicon"
      "ngc",
  "gamecube",
  "nintendo gamecube",
  "nintendo entertainment system",
  "super nintendo entertainment system",
  "super nintendo",
  "nintendo 64",
  "nintendo 64dd",
  "game cube",
  "wii",
  "wii u",
  "game & watch",
  "nes",
  "nintendo ds",
  "nintendo dsi",
  "super nintendo entertainment system",
  "nintendo 3ds",
  "nes",
  "virtual boy",
  "ds",
  "3ds"
];

final psKeywords = [
  "vita",
  "playstation vita",
  "ps vita",
  "playstation",
  "playstation vr",
  "playstation vr2",
  "playstation 1",
  "playstation 2",
  "playstation 3",
  "playstation 4",
  "playstation 5",
  "ps1",
  "ps2",
  "ps3",
  "ps4",
  "psx",
  "ps5",
  "psp",
  "portable",
  "playstation portable",
];

Future<GaminPlatformsBreakdown> getGamingPlatforms() async {
  final platformsBox = await Hive.openBox<GamingPlatform>("gaming_platforms");

  if (platformsBox.values.isNotEmpty) {
    return GaminPlatformsBreakdown(platforms: platformsBox.values.toList());
  }

  await platformsBox.clear();

  // POST: https://id.twitch.tv/oauth2/token?client_id=abcdefg12345&client_secret=hijklmn67890&grant_type=client_credentials
  final dio = Dio();
  final response = await dio.post(
      "https://id.twitch.tv/oauth2/token?client_id=$twitchClientId&client_secret=$twitchClientSecret&grant_type=client_credentials");

  final String accessToken = response.data["access_token"];

  final Response platforms = await dio.post('https://api.igdb.com/v4/platforms',
      data: "fields *; limit 300;",
      options: Options(headers: <String, dynamic>{
        "Client-ID": twitchClientId,
        "Authorization": "Bearer $accessToken"
      }));

  final Iterable<MapEntry> platformsString = (platforms.data as List<dynamic>)
      .map((p) => MapEntry<String, dynamic>(p['id'].toString(), p['name']));
  final Map<dynamic, dynamic> d = Map.fromEntries(platformsString);

  final List<GamingPlatform> plats = d.entries
      .map((a) => GamingPlatform(twitchiId: a.key, name: a.value))
      .toList();

  await platformsBox.addAll(plats);

  final testP = platformsBox.values.toList();

  return GaminPlatformsBreakdown(platforms: testP);
}

class GaminPlatformsBreakdown {
  final List<GamingPlatform> _platforms;

  GaminPlatformsBreakdown({required List<GamingPlatform> platforms})
      : _platforms = platforms;

  List<GamingPlatform> getByPlatform(GamingPlatformEnum platform) =>
      switch (platform) {
        GamingPlatformEnum.playstation => ps,
        GamingPlatformEnum.sega => segas,
        GamingPlatformEnum.xbox => xboxes,
        GamingPlatformEnum.nintendo => nintendos,
      };

  List<GamingPlatform> get all => _platforms;

  List<GamingPlatform> get ps => _platforms
      .where((item) => psKeywords.contains(item.name.toLowerCase()))
      .toList();

  List<GamingPlatform> get nintendos => _platforms
      .where((item) => nintendoKeywords.contains(item.name.toLowerCase()))
      .toList();

  List<GamingPlatform> get xboxes => _platforms
      .where((item) => xboxKeywords.contains(item.name.toLowerCase()))
      .toList();

  List<GamingPlatform> get segas => _platforms
      .where((item) => item.name.toLowerCase().contains("sega"))
      .toList();
}

enum GamingPlatformEnum {
  playstation,
  sega,
  xbox,
  nintendo;

  const GamingPlatformEnum();

  String getLogoAsset() => switch (this) {
        GamingPlatformEnum.playstation =>
          "assets/platforms/playstation/ps_logo.png",
        GamingPlatformEnum.sega => "assets/platforms/sega/sega_logo.png",
        GamingPlatformEnum.xbox => "assets/platforms/xbox/xbox_logo.png",
        GamingPlatformEnum.nintendo =>
          "assets/platforms/nintendo/nintendo_logo.png",
      };
}
