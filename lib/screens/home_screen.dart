import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:untitled/ImageWidget.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/ext/string_ext.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/local_database_service.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:untitled/screens/game_input/game_input_screen.dart';
import 'package:untitled/screens/game_input/platform_selection/platform_selection_screen.dart';
import 'package:untitled/screens/home_screen_cubit.dart';
import 'package:untitled/twitch/twitch_api.dart';
import 'package:untitled/utils/image_helpers/image_helpers.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';
import 'package:untitled/utils/typedefs/typedefs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final psn =
      """{"npsso":"8vs5a98DFKXVutXQkWMPLxGaDjKZdH7c6jwZRjYMrZVgJUFcTEvmj5jgA9Q8nmHc"}""";

  @override
  void initState() {
    super.initState();
    getGamingPlatforms();
  }

  // POST: https://id.twitch.tv/oauth2/token?client_id=abcdefg12345&client_secret=hijklmn67890&grant_type=client_credentials

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: context.read<HomeScreenCubit>().overlayPortalController,
      overlayChildBuilder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: Colors.black54,
              height: size.height,
              width: size.width,
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            ));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "App title",
          ),
          actions: [
            IconButton(
                onPressed: () =>
                    openGameEanScanner(context, onGameNotFound: (String ean) {
                      _onGameNotFoundByEanScan(context, ean);
                    }, onScannedGameAlreadyInCollection: (game, rawVideoGame) {
                      _onGameAlreadyInCollection(context, game);
                    }, onCurrentGamesUpdated: (games) {
                      context.read<HomeScreenCubit>().getVideoGames();
                    }),
                icon: const Icon(Icons.add_a_photo_outlined)),
            IconButton(
                onPressed: () async {
                  final game =
                      await context.push("/${GameInputScreen.routeName}");
                  Lgr.log("Finished creating a game manually");
                  if (game is VideoGameModel) {
                    Lgr.log("Got video game ${game.title}");
                    context.read<HomeScreenCubit>().getVideoGames();
                  } else {
                    Lgr.errorLog("Didn't get a video game ${game.runtimeType}");
                  }

                },
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                ))
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<HomeScreenCubit, HomeScreenState>(
                  builder: (context, state) {
                    return RefreshIndicator.adaptive(
                      onRefresh: () =>
                          context.read<HomeScreenCubit>().getVideoGames(),
                      child: ListView.builder(
                          itemCount: state.games?.length ?? 0,
                          itemBuilder: (context, index) {
                            final VideoGameModel item =
                                (state.games ?? [])[index];
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 160,
                                  child: Card(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: _handleImage(item, context),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Expanded(
                                            flex: 3,
                                            child: Column(
                                              children: [
                                                Text(
                                                  item.title,
                                                  style: context
                                                      .textStyle.titleLarge,
                                                  maxLines: 2,
                                                ),
                                                item.description == null
                                                    ? const SizedBox.shrink()
                                                    : Text(
                                                        maxLines: 4,
                                                        item.description!,
                                                        style: context.textStyle
                                                            .bodySmall,
                                                      ),
                                                const Spacer(),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 2,
                                                      vertical: 2),
                                                  child: Row(
                                                    children: [
                                                      TextButton.icon(
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  HomeScreenCubit>()
                                                              .deleteFromLocalDb(
                                                                  item);
                                                        },
                                                        style: ButtonStyle(
                                                          minimumSize:
                                                              WidgetStateProperty
                                                                  .all(
                                                                      const Size(
                                                                          40,
                                                                          30)),
                                                          elevation:
                                                              WidgetStateProperty
                                                                  .all(4),
                                                          shape: WidgetStateProperty
                                                              .all<
                                                                  RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0),
                                                            ),
                                                          ),
                                                        ),
                                                        icon: Icon(
                                                          Icons
                                                              .delete_forever_outlined,
                                                          color: Colors
                                                              .primaries.first,
                                                        ),
                                                        label: Text(
                                                          "delete",
                                                          style: context
                                                              .textStyle
                                                              .bodySmall,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      FilledButton(
                                                        onPressed: () {},
                                                        style: ButtonStyle(
                                                          minimumSize:
                                                              WidgetStateProperty
                                                                  .all(
                                                                      const Size(
                                                                          70,
                                                                          30)),
                                                          elevation:
                                                              WidgetStateProperty
                                                                  .all(4),
                                                          shape: WidgetStateProperty
                                                              .all<
                                                                  RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0),
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                            "copies: ${item.numberOfCopiesOwned}"),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ));
                          }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handleImage(VideoGameModel item, BuildContext context) {
    return _getImage(item, onWantsToUpdatePhoto: (game, _) async {
      Lgr.log("Wants to update cover photo ${game.title}");
      updateGameCover(context, game).then((_) {
        if (!context.mounted) return;
        context.read<HomeScreenCubit>().getVideoGames();
      });
    });
  }

  void _onGameAlreadyInCollection(BuildContext context, VideoGameModel game) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(
              "It seems that you already have ${game.title} in your collection. Do you own more copies?",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    final db = LocalDatabaseService();
                    await db.updateLocalDbGame(game.withAdditionalCopy());
                    if (!context.mounted) return;
                    context.pop();
                    context.read<HomeScreenCubit>().getVideoGames();
                  },
                  child: Text("yes", style: context.textStyle.bodySmall)),
              OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text("no", style: context.textStyle.bodySmall)),
            ],
          );
        });
  }

  Widget _getImage(VideoGameModel game,
      {VideoGameCallback? onWantsToUpdatePhoto}) {
    if (game.imageUrl.isNullOrEmpty() && game.imageBase64.isNullOrEmpty()) {
      print("no images at all");
      return getNoPictureImage(game,
          onTapped: (game, _) => onWantsToUpdatePhoto?.call(game, null));
    }

    if (game.imageUrl.isNotNullNorEmpty()) {
      return InkWell(
        child: ImageWidget(key: ValueKey(game.ean), game: game),
        onTap: () {
          Lgr.log("Tapped on photo in list ${game.title}");
          onWantsToUpdatePhoto?.call(game, null);
        },
      );
    } else if (game.imageBase64.isNotNullNorEmpty()) {
      return imageFromBase64String(game.imageBase64!);
    } else {
      return getNoPictureImage(game,
          onTapped: (game, _) => onWantsToUpdatePhoto?.call(game, null));
    }
  }

  Future<void> updateGameCover(
      BuildContext context, VideoGameModel game) async {
    final size = MediaQuery.of(context).size;
    final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: size.width,
        maxHeight: size.height);
    if (!context.mounted) return;
    context.read<HomeScreenCubit>().overlayPortalController.show();
    final imageBytes = await image?.readAsBytes();
    if (imageBytes == null) return;
    final gameBase64String = base64String(imageBytes);
    await LocalDatabaseService()
        .updateBase64ImageForGame(game, gameBase64String);
    await AppWriteHandler()
        .updatePictureOf(File(image!.path), gameBase64String, game);
    if (!context.mounted) return;
    context.read<HomeScreenCubit>().overlayPortalController.hide();
  }

  void _onGameNotFoundByEanScan(BuildContext context, String ean) {
    showDialog(
        context: context,
        builder: (a) {
          return AlertDialog(
            content: Text(
              "Whoops! Couldn't find anything with that scan. Could you please insert the data manually",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    context.pop();
                    context.go("/${GameInputScreen.routeName}");
                  },
                  child: Text(
                    "Sure, let's do it",
                    style: context.textStyle.bodySmall,
                  )),
              OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child:
                      Text("no way Jose!", style: context.textStyle.bodySmall)),
            ],
          );
        });
  }
}

Future<String?> openGameEanScanner(BuildContext context,
    {VideoGamesCallback? onCurrentGamesUpdated,
    Function(String ean)? onGameNotFound,
    VideoGameCallback? onScannedGameAlreadyInCollection}) async {
  var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ));
  if (res is String) {
    print(res);
    final dio = Dio();
    final game = await dio
        .request("https://api.upcitemdb.com/prod/trial/lookup?upc=$res");
    final videoGame = VideoGame.fromJson(game.data);

    if (videoGame.items?.isEmpty ?? true) {
      print("items is empty for that game");
      onGameNotFound?.call(res);
    }

    if (!context.mounted) return null;

    final GaminPlatformsBreakdown gamingPlatforms = await getGamingPlatforms();

    GamingPlatformEnum platformEnum = gamingPlatforms.getPlatformEnumFromTitle(
        videoGame.items?.first.title
            ?.toLowerCase()
            .removeNonAlphanumericButKeepSpaces(),
        videoGame.items?.first);

    print("Platform enum: ${platformEnum.name}");

    GamingPlatform? platform = gamingPlatforms.getPlatformFromTitle(
        videoGame.items?.first.title
            ?.removeNonAlphanumericButKeepSpaces()
            .toLowerCase(),
        videoGame.items?.first.description
            ?.removeNonAlphanumericButKeepSpaces()
            .toLowerCase());

    print("Platform specific: ${platform?.name}");

    if (platformEnum == GamingPlatformEnum.unknown) {
      if (!context.mounted) return null;
      final platformSelectionResult =
          await context.push("/${PlatformSelectionScreen.routeName}");
      Lgr.log((platformSelectionResult as FullPlatform?)
              ?.specificPlatformModel
              .name ??
          "");
    }

    var gameModel = VideoGameModel.fromItems(videoGame.items!.first,
        gamingPlatform: platform, platformEnum: platformEnum);

    final imageUrls = videoGame.items?.first.images ?? [];
    for (var url in imageUrls) {
      try {
        final result = await dio.get(url,
            options: Options(responseType: ResponseType.bytes));

        if ((result.statusCode ?? 500) < 300 &&
            (result.statusCode ?? 0) >= 200) {
          final Uint8List ints = Uint8List.fromList(result.data as List<int>);
          gameModel = gameModel.copyWithBase64Image(
              imageUrl: url, imageBase64: base64String(ints));
          break;
        } else {
          gameModel = gameModel.resetImageUrl();
        }
      } catch (_) {
        print("Error getting proper image data, no worries, this is normal!");
      }
    }

    final gameBox = await Hive.openBox<VideoGameModel>("games");

    bool alreadyHaveThatGameInCollection =
        gameBox.values.any((VideoGameModel e) {
      return e.ean == gameModel.ean;
    });

    if (alreadyHaveThatGameInCollection) {
      onScannedGameAlreadyInCollection?.call(
          gameBox.values.firstWhere((g) => g.ean == gameModel.ean), videoGame);
      return null;
    }

    final rawGameBox = await Hive.openBox<VideoGame>("raw_data");
    await rawGameBox.put(videoGame.items!.first.ean, videoGame);
    await rawGameBox.close();
    await gameBox.put(gameModel.ean, gameModel);
    final games = gameBox.values.toList();
    await gameBox.close();
    onCurrentGamesUpdated?.call(games);
    await AppWriteHandler()
        .saveGameInDatabase(gameModel)
        .then((Map<String, dynamic>? a) {
      print("Game uploaded to API ${a.toString()}");
    });
    return res;
  } else {
    return null;
  }
}
