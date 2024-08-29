part of 'game_input_cubit.dart';

class GameInputState extends Equatable {
  final String? gameTitle;
  final GamingPlatform? platform;
  final GaminPlatformsBreakdown? allPlatforms;
  final String? ean;
  final io.File? image;

  const GameInputState(
      {this.ean, this.image, this.allPlatforms, this.gameTitle, this.platform});

  @override
  List<Object?> get props => [gameTitle, platform, allPlatforms, image, ean];

  GameInputState copyWith({
    String? gameTitle,
    GamingPlatform? platform,
    GaminPlatformsBreakdown? allPlatforms,
    String? ean,
    io.File? image,
  }) {
    return GameInputState(
      gameTitle: gameTitle ?? this.gameTitle,
      platform: platform ?? this.platform,
      allPlatforms: allPlatforms ?? this.allPlatforms,
      ean: ean ?? this.ean,
      image: image ?? this.image,
    );
  }
}
