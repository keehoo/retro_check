import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/firebase/firestor_handler.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  FirestoreHandler firestore = FirestoreHandler();

  UserProfileCubit() : super(const UserProfileState());

  Future<void> getUserPoints() async {
    final userPoints = await firestore.getUserPoints();
    emit(state.copyWith(userPoints: userPoints));
  }
}
