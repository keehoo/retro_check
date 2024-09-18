part of 'game_swap_cubit.dart';

class GameSwapState extends Equatable {
  const GameSwapState({this.placemark, this.userLocation});

  final LocationData? userLocation;
  final geocoding.Placemark? placemark;

  @override
  List<Object?> get props => [userLocation, placemark];

  GameSwapState copyWith({
    LocationData? userLocation,
    geocoding.Placemark? placemark,
  }) {
    return GameSwapState(
      userLocation: userLocation ?? this.userLocation,
      placemark: placemark ?? this.placemark,
    );
  }
}
