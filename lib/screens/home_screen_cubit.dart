import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/local_database_service.dart';
import 'package:untitled/twitch/twitch_api.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit() : super(const HomeScreenState());

  final OverlayPortalController overlayPortalController = OverlayPortalController();

  Future<void> getVideoGames() async {
    overlayPortalController.show();
    final List<VideoGameModel> games =
        await LocalDatabaseService().getVideoGames();
    overlayPortalController.hide();

    emit(state.copyWith(games: games));
  }

  void getGaminPlatforms() {
    getGamingPlatforms();
  }

  Future<void> deleteFromLocalDb(VideoGameModel item) async {
    overlayPortalController.show();
    await LocalDatabaseService().deleteFromDb(item);
    overlayPortalController.hide();

    getVideoGames();
  }
}
