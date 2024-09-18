import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/screens/games_tab_navigation_cubit.dart';

class NavigationMain extends StatelessWidget {
  const NavigationMain({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BlocBuilder<GamesTabNavigationCubit, GamesTabNavigationState>(
        buildWhen: _hasIndexChanged,
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                ),
              ],
            ),
            child: NavigationBar(
              shadowColor: Colors.black,
              backgroundColor: Colors.white,
              selectedIndex: state.index ?? 0,
              onDestinationSelected: (destination) {
                /// TODO: https://medium.com/@wartelski/how-to-flutter-save-the-page-state-using-gorouter-in-sidemenu-c69b9313b7f2
                /// ShellRoute isn't enough to presereve the state of each branch.
                context.read<GamesTabNavigationCubit>().onIndexChanged(destination);
                switch (destination) {
                  case 0:
                    context.go(
                      "/"
                    );
                    break;
                  case 1:
                    context.push("/b");
                    break;
                  case 2:
                    context.push("/c");
                    break;
                  case 3:
                    context.push("/b");
                    break;
                  case 4:
                    context.go("/user_profile");
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.games), label: 'Games'),
                NavigationDestination(
                    icon: Icon(Icons.devices_other_outlined), label: 'Consoles'),
                NavigationDestination(
                    icon: Icon(Icons.event_available), label: 'Events'),
                NavigationDestination(
                    icon: Icon(Icons.change_circle_outlined), label: 'Swap'),
                NavigationDestination(
                    icon: Icon(Icons.person_2_outlined), label: 'Profile'),
              ],
            ),
          );
        },
      ),
      body: child,
    );
  }

  bool _hasIndexChanged(p, c) => p.index != c.index;
}
