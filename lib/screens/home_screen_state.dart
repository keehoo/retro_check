part of 'home_screen_cubit.dart';

class HomeScreenState extends Equatable {

  final List<VideoGameModel>? games;

  const HomeScreenState({this.games});

  @override
  List<Object?> get props => [games];

  HomeScreenState copyWith({
    List<VideoGameModel>? games,
  }) {
    return HomeScreenState(
      games: games ?? this.games,
    );
  }
}
