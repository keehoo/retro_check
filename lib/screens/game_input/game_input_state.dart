part of 'game_input_cubit.dart';

class GameInputState extends Equatable {
  final int? _pageIndex;
  final int? totalPages;
  final String? gameTitle;
  final GamingPlatform? platform;
  final GamingPlatformEnum? platformEnum;
  final GaminPlatformsBreakdown? allPlatforms;
  final String? ean;
  final io.File? image;

  int get pageIndex => _pageIndex ?? 0;

  const GameInputState(
      {int? pageIndex,
      this.platformEnum,
      this.ean,
      this.image,
      this.allPlatforms,
      this.totalPages,
      this.gameTitle,
      this.platform})
      : _pageIndex = pageIndex;

  @override
  List<Object?> get props => [
        _pageIndex,
        gameTitle,
        platform,
        platformEnum,
        allPlatforms,
        image,
        ean,
        totalPages
      ];

  Future<VideoGameModel?> validate() async {
    final nullValidation = gameTitle.isNotNullNorEmpty() &&
        platformEnum != null &&
        platform != null &&
        image != null;

    final imnageBytes = await image!.readAsBytes();

    if (nullValidation) {
      final gameEanOrUuidIfEanIsNull = const UuidV4().generate();
      AppWriteHandler().storeGameImage(image!, ean ?? gameEanOrUuidIfEanIsNull);

      final videoGame = VideoGameModel(
          gamingPlatformEnum: platformEnum!,
          uuid: gameEanOrUuidIfEanIsNull,
          numberOfCopiesOwned: 1,
          title: gameTitle!,
          description: "",
          platform: platform,
          ean: ean ?? gameEanOrUuidIfEanIsNull,
          imageUrl: imnageBytes.length.toString(),
          imageBase64: base64String(imnageBytes));
      try {
        await Future.wait([
          AppWriteHandler().saveGameInDatabase(videoGame),
          LocalDatabaseService().saveInLocalDb(videoGame)
        ], cleanUp: (Map<String, dynamic>? a) {
          Lgr.log(
            "Received the result from storing the game $a",
          );
        });
      } catch (e, s) {
        Lgr.errorLog("Error while saving the game");
      }

      return videoGame;
    } else {
      Lgr.log("Exceptio while creating video game model, ${toString()}");
      return null;
    }
  }

  GameInputState copyWith({
    int? pageIndex,
    int? totalPages,
    String? gameTitle,
    GamingPlatform? platform,
    GamingPlatformEnum? platformEnum,
    GaminPlatformsBreakdown? allPlatforms,
    String? ean,
    io.File? image,
  }) {
    return GameInputState(
      pageIndex: pageIndex ?? _pageIndex,
      totalPages: totalPages ?? this.totalPages,
      gameTitle: gameTitle ?? this.gameTitle,
      platform: platform ?? this.platform,
      platformEnum: platformEnum ?? this.platformEnum,
      allPlatforms: allPlatforms ?? this.allPlatforms,
      ean: ean ?? this.ean,
      image: image ?? this.image,
    );
  }
}
