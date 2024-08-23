part of 'game_details_cubit.dart';

class GameDetailsState extends Equatable {
  final Items? item;
  final int? index;

  const GameDetailsState({this.index, this.item});

  @override
  List<Object?> get props => [item, index];

  GameDetailsState copyWith({
    Items? item,
    int? index,
  }) {
    return GameDetailsState(
      item: item ?? this.item,
      index: index ?? this.index,
    );
  }
}
