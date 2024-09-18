import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/firebase_options.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:untitled/screens/game_details/game_details_cubit.dart';
import 'package:untitled/screens/game_details/game_details_screen.dart';
import 'package:untitled/screens/game_input/game_input_cubit.dart';
import 'package:untitled/screens/game_input/game_input_screen.dart';
import 'package:untitled/screens/game_input/platform_selection/platform_selection_screen.dart';
import 'package:untitled/screens/games_tab_navigation_cubit.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/screens/home_screen_cubit.dart';
import 'package:untitled/screens/login/login_screen.dart';
import 'package:untitled/screens/navigation_main.dart';
import 'package:untitled/screens/user_profile/user_profile_screen.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(VideoGameAdapter());
  Hive.registerAdapter(ItemsAdapter());
  Hive.registerAdapter(OffersAdapter());
  Hive.registerAdapter(VideoGameModelAdapter());
  Hive.registerAdapter(GamingPlatformAdapter());
  Hive.registerAdapter(GamingPlatformEnumAdapter());
  // final d = await WebScrapper().searchByQuery(
  //     s: "Double Pack Assassins Creed Brotherhood (uk Import) Dvd");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          primary: Colors.black,
          seedColor: Colors.black,
          // onSurface: Colors.white
        ),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            centerTitle: false,
            toolbarTextStyle: context.textStyle.titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
            titleTextStyle: Theme.of(context).textTheme.bodyMedium),
        textTheme: TextTheme(
          labelLarge: GoogleFonts.raleway(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w700),
          labelSmall: GoogleFonts.raleway(
              fontSize: 8, color: Colors.black, fontWeight: FontWeight.w400),
          titleLarge: GoogleFonts.raleway(
              fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black),
          bodySmall: GoogleFonts.raleway(fontSize: 10, color: Colors.black),
          bodyMedium: GoogleFonts.raleway(fontSize: 14, color: Colors.black),
          displaySmall: GoogleFonts.raleway(fontSize: 12, color: Colors.black),
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
          redirect: (BuildContext context, GoRouterState state) {
            final isAuthenticated = FirebaseAuth.instance.currentUser != null;

            Lgr.log("User authenticated? $isAuthenticated");
            if (!isAuthenticated) {
              return '/login';
            } else {
              return null; // return "null" to display the intended route without redirecting
            }
          },
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
                      path: PlatformSelectionScreen.routeName,
                      pageBuilder:
                          (BuildContext context, GoRouterState routerState) {
                        return const TransitionPage(
                            child: PlatformSelectionScreen());
                      }),
                  GoRoute(
                      path: GameInputScreen.routeName,
                      pageBuilder:
                          (BuildContext context, GoRouterState routerState) {
                        return TransitionPage(
                            child: BlocProvider(
                          create: (context) => GameInputCubit()
                            ..getPlatforms()
                            ..addPageListener(),
                          child: const GameInputScreen(),
                        ));
                      }),
                ],
                pageBuilder: (context, GoRouterState b) {
                  return NoTransitionPage(
                      child: BlocProvider(
                    create: (context) => HomeScreenCubit()
                      ..getGaminPlatforms()
                      ..getVideoGames(),
                    child: const HomeScreen(),
                  ));
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
            GoRoute(
              path: "/user_profile",
              pageBuilder: (context, GoRouterState b) =>
                  const NoTransitionPage(child: UserProfileScreen()),
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
      GoRoute(
          path: "/login",
          pageBuilder: (context, routerState) {
            return  NoTransitionPage(
                child: LoginScreen());
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
