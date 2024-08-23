import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:untitled/screens/game_details/game_details_cubit.dart';
import 'package:untitled/screens/game_details/game_details_screen.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/screens/navigation_main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(VideoGameAdapter());
  Hive.registerAdapter(ItemsAdapter());
  Hive.registerAdapter(OffersAdapter());
  Hive.registerAdapter(VideoGameModelAdapter());
  Hive.registerAdapter(GamingPlatformAdapter());
  // WebScrapper().init(s: "Mortal Kombat 1");

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  runApp(MyApp());
  AppWriteHandler().init();
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _testNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),

          /// AppBar default style
          titleLarge: GoogleFonts.adamina(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
    );
  }

  final GoRouter _router = GoRouter(
    observers: [CustomNavigatorObserver()],
    initialLocation: "/",
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
          navigatorKey: _shellNavigatorKey,
          pageBuilder: (BuildContext context, GoRouterState state, Widget c) {
            return NoTransitionPage(
                child: BlocProvider(
              create: (context) => GameDetailsCubit(),
              child: NavigationMain(
                child: c,
              ),
            ));
          },
          routes: [
            GoRoute(
                parentNavigatorKey: _shellNavigatorKey,
                path: "/",
                routes: [
                  GoRoute(
                      parentNavigatorKey: _shellNavigatorKey,
                      path: GameDetailsScreen.routeName,
                      pageBuilder: (context, routerState) {
                        final Items? item = routerState.extra as Items?;
                        context.read<GameDetailsCubit>().onItemChanged(item);
                        return const NoTransitionPage(
                            child: GameDetailsScreen());
                      })
                ],
                pageBuilder: (context, GoRouterState b) {
                  return const NoTransitionPage(child: HomeScreen());
                }),
            GoRoute(
              parentNavigatorKey: _shellNavigatorKey,
              path: "/b",
              pageBuilder: (context, GoRouterState b) => const NoTransitionPage(
                child: Placeholder(
                  color: Colors.blue,
                ),
              ),
            ),
            GoRoute(
              path: "/c",
              pageBuilder: (context, GoRouterState b) => const NoTransitionPage(
                  child: Placeholder(
                color: Colors.yellow,
              )),
            ),
          ]),
    ],
  );
}

class CustomNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {}

  @override
  void didPush(Route route, Route? previousRoute) {
    print(
        "Did push ${route.currentResult} from ${previousRoute?.currentResult}");
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // TODO: implement didRemove
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    // TODO: implement didReplace
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    // TODO: implement didStartUserGesture
  }

  @override
  void didStopUserGesture() {
    // TODO: implement didStopUserGesture
  }
}
