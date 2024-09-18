import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';

part 'game_swap_state.dart';

class GameSwapCubit extends Cubit<GameSwapState> {
  final Location location = Location();

  GameSwapCubit() : super(const GameSwapState());

  Future<void> getUserLocation() async {
    final LocationData userLocation = await location.getLocation();
    emit(state.copyWith(userLocation: userLocation));
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
              userLocation.latitude!, userLocation.longitude!);

      emit(state.copyWith(placemark: placemarks.firstOrNull));
    } catch (e, s) {
      // handle error
    }
  }
}
