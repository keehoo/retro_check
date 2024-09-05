import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:untitled/screens/game_details/game_details_cubit.dart';
import 'package:untitled/screens/game_details/game_details_screen.dart';
import 'package:untitled/screens/games_tab_navigation_cubit.dart';
import 'package:untitled/screens/game_input/game_input_cubit.dart';
import 'package:untitled/screens/game_input/game_input_screen.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/screens/navigation_main.dart';
import 'package:untitled/web_scrapper/web_scrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(VideoGameAdapter());
  Hive.registerAdapter(ItemsAdapter());
  Hive.registerAdapter(OffersAdapter());
  Hive.registerAdapter(VideoGameModelAdapter());
  Hive.registerAdapter(GamingPlatformAdapter());
  Hive.registerAdapter(GamingPlatformEnumAdapter());
  final d = await WebScrapper().searchByQuery(
      s: "Double Pack Assassins Creed Brotherhood (uk Import) Dvd");

  runApp(MyApp());
  AppWriteHandler().init();
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pl'), // Polish
        Locale('en'), // English
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
        ),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            titleTextStyle: Theme.of(context).textTheme.bodyMedium),
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
          bodyMedium: GoogleFonts.merriweather().copyWith(color: Colors.white),
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
              create: (context) => GamesTabNavigationCubit(),
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
                      path: GameInputScreen.routeName,
                      pageBuilder:
                          (BuildContext context, GoRouterState routerState) {
                        return TransitionPage(
                            child: BlocProvider(
                          create: (context) => GameInputCubit()..getPlatforms(),
                          child: const GameInputScreen(),
                        ));
                      }),
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
      GoRoute(
          path: "/${GameDetailsScreen.routeName}",
          pageBuilder: (context, routerState) {
            final videoGame = routerState.extra as VideoGameModel?;
            return NoTransitionPage(
                child: BlocProvider(
              create: (context) => GameDetailsCubit(videoGame),
              child: const GameDetailsScreen(),
            ));
          }),
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

/// Custom transition page with no transition.
class TransitionPage<T> extends CustomTransitionPage<T> {
  /// Constructor for a page with no transition functionality.
  const TransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _transitionsBuilder,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
        );

  static Widget _transitionsBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.decelerate;
    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    final offsetAnimation = animation.drive(tween);
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}
