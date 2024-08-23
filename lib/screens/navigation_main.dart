import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/screens/game_details/game_details_cubit.dart';

class NavigationMain extends StatelessWidget {
  const NavigationMain({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BlocBuilder<GameDetailsCubit, GameDetailsState>(
        buildWhen: (p, c) => p.index != c.index,
        builder: (context, state) {
          return NavigationBar(
            selectedIndex: state.index ?? 0,
            onDestinationSelected: (destination) {
              context.read<GameDetailsCubit>().onIndexChanged(destination);
              switch (destination) {
                case 0:
                  context.push(
                    GoRouterState.of(context).matchedLocation,
                  );
                  break;
                case 1:
                  context.push("/b");
                  break;
                case 2:
                  context.push("/c");
                  break;
              }
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.grid_view), label: 'Games'),
              NavigationDestination(
                  icon: Icon(Icons.delete_forever), label: 'Consoles'),
              NavigationDestination(
                  icon: Icon(Icons.group_add_sharp), label: 'Events'),
            ],
          );
        },
      ),
      body: child,
    );
  }

  int _getIndexBasedOnLocation(String location) {
    if (location.startsWith("/b")) {
      return 1;
    }

    if (location.startsWith("/c")) {
      return 2;
    }

    return 0;
  }
}
