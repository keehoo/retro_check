import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/screens/game_details/game_details_cubit.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key});

  static const routeName = "game_details";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameDetailsCubit, GameDetailsState>(
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Text(state.videoGameModel?.title ?? "", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),),
          ),
        );
      },
    );
  }
}
