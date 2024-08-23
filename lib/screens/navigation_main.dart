import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationMain extends StatelessWidget {
  const NavigationMain({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex:
            _getIndexBasedOnLocation(GoRouterState.of(context).matchedLocation),
        onDestinationSelected: (destination) {
          print("        onDestinationSelected: ($destination)");
          switch (destination) {
            case 0:
              context.push(GoRouterState.of(context).matchedLocation, );
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
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Games'),
          NavigationDestination(
              icon: Icon(Icons.delete_forever), label: 'Consoles'),
          NavigationDestination(
              icon: Icon(Icons.group_add_sharp), label: 'Events'),
        ],
      ),
      body: child,
    );
  }

  int _getIndexBasedOnLocation(String location) {
    if (location.startsWith("/")) {
      return 0;
    }
    if (location.startsWith("/b")) {
      return 1;
    }

    if (location.startsWith("/c")) {
      return 2;
    }

    return 0;
  }
}
