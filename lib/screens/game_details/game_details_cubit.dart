import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:untitled/generic_video_game_model.dart';

part 'game_details_state.dart';

class GameDetailsCubit extends Cubit<GameDetailsState> {
  GameDetailsCubit(VideoGameModel? game)
      : super(GameDetailsState(videoGameModel: game));
}
