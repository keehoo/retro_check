import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/ImageWidget.dart';
import 'package:untitled/screens/game_details/game_details_cubit.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key});

  static const routeName = "game_details";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameDetailsCubit, GameDetailsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.videoGameModel.title),
          ),
          body: Column(
            children: [
              ImageWidget(game: state.videoGameModel, onTapped: (a, b) {})
            ],
          ),
        );
      },
    );
  }
}
