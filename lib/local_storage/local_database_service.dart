import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/generic_video_game_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _singleton =
      LocalDatabaseService._internal();

  factory LocalDatabaseService() {
    return _singleton;
  }

  LocalDatabaseService._internal();

  Future<void> updateBase64ImageForGame(
      VideoGameModel game, String gameBase64String) async {
    VideoGameModel updatedGame =
        game.copyWithBase64Image(imageBase64: gameBase64String, imageUrl: null);
    final Box<VideoGameModel> gameBox =
        await Hive.openBox<VideoGameModel>("games");
    await gameBox.put(updatedGame.ean, updatedGame);
    await gameBox.close();
  }

  Future<void> updateLocalDbGame(VideoGameModel game) async {
    final Box<VideoGameModel> gameBox =
        await Hive.openBox<VideoGameModel>("games");
    await gameBox.put(game.ean, game);
    await gameBox.close();
  }

  Future<List<VideoGameModel>> getVideoGames() async {
    final List<VideoGameModel> games = [];
    final gamebox = await Hive.openBox<VideoGameModel>("games");
    games.addAll(gamebox.values);
    await gamebox.close();
    return games;
  }

  Future<void> deleteFromDb(VideoGameModel item) async {
    final Box<VideoGameModel> gameBox =
        await Hive.openBox<VideoGameModel>("games");
    await gameBox.delete(item.ean,);
    await gameBox.close();
  }


  Future<Map<String, dynamic>> saveInLocalDb(VideoGameModel videoGame) async{
    final Box<VideoGameModel> gameBox =
    await Hive.openBox<VideoGameModel>("games");
    await gameBox.put(videoGame.ean, videoGame);
    await gameBox.close();
    return videoGame.toJson();
  }
}
