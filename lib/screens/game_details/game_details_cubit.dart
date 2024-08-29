import 'package:equatable/equatable.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'game_details_state.dart';

class GameDetailsCubit extends Cubit<GameDetailsState> {
  GameDetailsCubit({Items? item}) : super(GameDetailsState(item: item));

  void onItemChanged(Items? item) {
    emit(state.copyWith(item: item));
  }

  void onIndexChanged(int destination) {
    emit(state.copyWith(index: destination));
  }


}
