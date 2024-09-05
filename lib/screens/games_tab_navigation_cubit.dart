import 'package:equatable/equatable.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'games_tab_navigation_state.dart';

class GamesTabNavigationCubit extends Cubit<GamesTabNavigationState> {
  GamesTabNavigationCubit() : super(const GamesTabNavigationState(index: 0));


  void onIndexChanged(int destination) {
    emit(state.copyWith(index: destination));
  }


}
