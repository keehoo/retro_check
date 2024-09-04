part of 'game_input_cubit.dart';

class GameInputState extends Equatable {
  final String? gameTitle;
  final GamingPlatform? platform;
  final GamingPlatformEnum? platformEnum;
  final GaminPlatformsBreakdown? allPlatforms;
  final String? ean;
  final io.File? image;

  const GameInputState({this.platformEnum,
      this.ean, this.image, this.allPlatforms, this.gameTitle, this.platform});

  @override
  List<Object?> get props => [gameTitle, platform, platformEnum,
    allPlatforms, image, ean];

  GameInputState copyWith({
    String? gameTitle,
    GamingPlatform? platform,
    GamingPlatformEnum? platformEnum,
    GaminPlatformsBreakdown? allPlatforms,
    String? ean,
    io.File? image,
  }) {
    return GameInputState(
      gameTitle: gameTitle ?? this.gameTitle,
      platform: platform ?? this.platform,
      platformEnum: platformEnum ?? this.platformEnum,
      allPlatforms: allPlatforms ?? this.allPlatforms,
      ean: ean ?? this.ean,
      image: image ?? this.image,
    );
  }
}
