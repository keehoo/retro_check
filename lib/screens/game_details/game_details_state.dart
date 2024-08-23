part of 'game_details_cubit.dart';

class GameDetailsState extends Equatable {
  final Items? item;

  const GameDetailsState({this.item});

  @override
  List<Object?> get props => [item];

  GameDetailsState copyWith({
    Items? item,
  }) {
    return GameDetailsState(
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item?.toJson() ,
    };
  }

  factory GameDetailsState.fromMap(Map<String, dynamic> map) {
    return GameDetailsState(
      item: map['item'] as Items,
    );
  }
}
