import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/ext/string_ext.dart';
import 'package:untitled/firebase/firestor_handler.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/local_database_service.dart';
import 'package:untitled/screens/game_input/platform_selection/platform_selection_screen.dart';
import 'package:untitled/twitch/twitch_api.dart';
import 'package:untitled/utils/image_helpers/image_helpers.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';
import 'package:uuid/v4.dart';

part 'game_input_state.dart';

const animationCurve = Curves.fastLinearToSlowEaseIn;
const Duration animDuration = Duration(milliseconds: 700);

class GameInputCubit extends Cubit<GameInputState> {
  GameInputCubit() : super(const GameInputState());

  PageController pageController = PageController(initialPage: 0);

  Future<void> getPlatforms() async {
    final GaminPlatformsBreakdown platforms = await getGamingPlatforms();
    emit(state.copyWith(allPlatforms: platforms));
  }

  void onPlatformSelected(FullPlatform platform) {
    emit(state.copyWith(
        platform: platform.specificPlatformModel,
        platformEnum: platform.platformEnum));
  }

  void onImageFileSelected(io.File file) {
    emit(state.copyWith(image: file));
  }

  void onGameTitleChanges(String text) {
    emit(state.copyWith(gameTitle: text));
  }

  bool isAllValid() =>
      !state.gameTitle.isNullOrEmpty() &&
      state.image != null &&
      state.platformEnum != null &&
      state.platform != null;

  void onEanUpdated(String? ean) {
    emit(state.copyWith(ean: ean));
  }

  void onGaminPlatormEnumUpdated(GamingPlatformEnum platform) {
    emit(state.copyWith(platformEnum: platform));
  }

  void onGoToNextPage() {
    final controllerPage = pageController.page?.toInt();

    if (controllerPage == (state.totalPages ?? 0) - 1) {
      emit(state.copyWith(pageIndex: (state.totalPages ?? 0) + 100));
    } else {
      pageController.nextPage(duration: animDuration, curve: animationCurve);
    }
  }

  void onPageChanged(int page, int totalLength) {
    emit(state.copyWith(pageIndex: page, totalPages: totalLength));
  }

  void addPageListener() {
    pageController.addListener(() {
      /// Add whatever you need here.
      // Lgr.log("PageView listener: page=$pageController");
    });
  }
}
