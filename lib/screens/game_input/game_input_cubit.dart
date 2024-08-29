import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/ext/string_ext.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/twitch/twitch_api.dart';

part 'game_input_state.dart';

class GameInputCubit extends Cubit<GameInputState> {
  GameInputCubit() : super(const GameInputState());

  Future<void> getPlatforms() async {
    final GaminPlatformsBreakdown platforms = await getGamingPlatforms();
    emit(state.copyWith(allPlatforms: platforms));
  }

  void onPlatformSelected(GamingPlatform? platform) {
    emit(state.copyWith(platform: platform));
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
      state.platform != null;

  void onEanUpdated(String? ean) {
    emit(state.copyWith(ean: ean));
  }
}
