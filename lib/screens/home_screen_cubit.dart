import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/local_database_service.dart';
import 'package:untitled/twitch/twitch_api.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit() : super(const HomeScreenState());

  final OverlayPortalController overlayPortalController =
      OverlayPortalController();

  Future<void> getVideoGames({bool? noLoader = false}) async {
    if (noLoader == false) overlayPortalController.show();
    final List<VideoGameModel> games =
        await LocalDatabaseService().getVideoGames();
    overlayPortalController.hide();

    // if (listEquals(games, state.games)) {
      emit(state.copyWith(games: games));
    // } else {
    //   Lgr.log("No need to refresh view, the lists are the same.");
    // }
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
