part of 'game_details_cubit.dart';

class GameDetailsState extends Equatable {
  const GameDetailsState({this.videoGameModel});

  final VideoGameModel? videoGameModel;

  @override
  List<Object?> get props => [videoGameModel];

  GameDetailsState copyWith({
    VideoGameModel? videoGameModel,
  }) {
    return GameDetailsState(
      videoGameModel: videoGameModel ?? this.videoGameModel,
    );
  }
}
