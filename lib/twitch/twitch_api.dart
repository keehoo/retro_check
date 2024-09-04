import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/generic_video_game_model.dart';

const twitchClientId = "7ye79qmkzxt2w2w1p42pzk2righnqv";
const twitchClientSecret = "j6766v8gdnbbcq6yrf0b2hu90y9j0m";

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
      .map((a) => GamingPlatform(
          twitchiId: a.key,
          name: a.value,
          commonNames: _getCommonNamesFor(a.value as String)))
      .toList();

  await platformsBox.addAll(plats);

  final testP = platformsBox.values.toList();

  return GaminPlatformsBreakdown(platforms: testP);
}

List<String> _getCommonNamesFor(String value) {
  final String platformTwitchName = value.toLowerCase().trim();

  switch (platformTwitchName) {
    case "playstation 3":
      return ["ps3", "playstation 3"];
    case "playstation 4":
      return ["ps4", "playstation 4"];
    case "playstation 5":
      return ["ps5", "playstation 5"];
    case "playstation 2":
      return ["ps2", "playstation 2"];
    case "playstation":
      return ["ps1", "psx", "playstation", "playstation 1"];
    case "playstation portable":
      return ["psp", "playstation portable"];
    case "playstation vita":
      return ["ps vita", "playstation vita"];

    // Nintendo Consoles
    case "nintendo entertainment system":
      return ["nes", "nintendo entertainment system"];
    case "super nintendo entertainment system":
      return ["snes", "super nintendo", "super nintendo entertainment system"];
    case "nintendo 64":
      return ["n64", "nintendo 64"];
    case "gamecube":
      return ["gc", "gamecube", "nintendo gamecube"];
    case "wii":
      return ["wii"];
    case "wii u":
      return ["wii u"];
    case "nintendo switch":
      return ["switch", "nintendo switch"];
    case "game boy":
      return ["gb", "game boy"];
    case "game boy color":
      return ["gbc", "game boy color"];
    case "game boy advance":
      return ["gba", "game boy advance"];
    case "nintendo ds":
      return ["ds", "nintendo ds"];
    case "nintendo 3ds":
      return ["3ds", "nintendo 3ds"];

    // Xbox Consoles
    case "xbox":
      return ["xbox", "original xbox"];
    case "xbox 360":
      return ["xbox 360", "360", "x360"];
    case "xbox one":
      return ["xbox one", "xbox 1"];
    case "xbox series x":
      return ["xbox series x"];
    case "xbox series s":
      return ["xbox series s"];
    case "xbox series x|s":
      return ["xbox series x|s"];

    // Sega Consoles
    case "sega genesis":
      return [
        "genesis",
        "sega genesis",
      ];
    case "sega saturn":
      return ["saturn", "sega saturn"];
    case "sega dreamcast":
      return ["dreamcast", "sega dreamcast"];
    case "sega master system":
      return ["master system", "sega master system"];
    case "sega game gear":
      return ["game gear", "sega game gear"];
    case "sega cd":
      return ["sega cd", "mega cd"];
    case "sega 32x":
      return ["32x", "sega 32x"];

    default:
      return [];
  }
}
