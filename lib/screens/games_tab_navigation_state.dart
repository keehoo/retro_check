part of 'games_tab_navigation_cubit.dart';

class GamesTabNavigationState extends Equatable {
  final int? index;

  const GamesTabNavigationState({required this.index});

  @override
  List<Object?> get props => [ index];

  GamesTabNavigationState copyWith({
    int? index,
  }) {
    return GamesTabNavigationState(
      index: index ?? this.index,
    );
  }
}
