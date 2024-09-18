import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

part 'games_tab_navigation_state.dart';

class GamesTabNavigationCubit extends Cubit<GamesTabNavigationState> {
  GamesTabNavigationCubit() : super(const GamesTabNavigationState(index: 0));

  void authListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      switch (user == null) {
        case true:
          Lgr.log("User logged out!");
        case false:
          Lgr.log("User logged in!");
      }
    });
  }

  void onIndexChanged(int destination) {
    emit(state.copyWith(index: destination));
  }
}
