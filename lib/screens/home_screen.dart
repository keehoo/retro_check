import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/ext/string_ext.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/local_database_service.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:untitled/screens/game_input/game_input_screen.dart';
import 'package:untitled/twitch/twitch_api.dart';
import 'package:untitled/utils/colors/app_palette.dart';
import 'package:untitled/utils/image_helpers/image_helpers.dart';
import 'package:untitled/utils/typedefs/typedefs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<VideoGameModel> games = [];
  final psn =
      """{"npsso":"8vs5a98DFKXVutXQkWMPLxGaDjKZdH7c6jwZRjYMrZVgJUFcTEvmj5jgA9Q8nmHc"}""";

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getGamingPlatforms();
  }

  // POST: https://id.twitch.tv/oauth2/token?client_id=abcdefg12345&client_secret=hijklmn67890&grant_type=client_credentials

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(gradient: AppPalette.lightGradientBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "App title",
          ),
          actions: [
            IconButton(
                onPressed: () => openGameEanScanner(context,
                        onScannedGameAlreadyInCollection: (game, rawVideoGame) {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              content: Text(
                                "It seems that you already have ${game.title} in your collection. Do you own more copies?",
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async {
                                      await LocalDatabaseService()
                                          .updateLocalDbGame(
                                              game.withAdditionalCopy());

                                      final dd = await LocalDatabaseService()
                                          .getVideoGames();
                                      if (!context.mounted) return;
                                      context.pop();
                                      setState(() {
                                        games = dd;
                                      });
                                    },
                                    child: const Text("yes")),
                                OutlinedButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: const Text("no")),
                              ],
                            );
                          });
                    }, onCurrentGamesUpdated: (games) {
                      setState(() {
                        this.games = games;
                      });
                    }),
                icon: const Icon(Icons.add_a_photo_outlined)),
            IconButton(
                onPressed: () => context.go("/${GameInputScreen.routeName}"),
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
                child: FutureBuilder(
                  future: LocalDatabaseService().getVideoGames(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<VideoGameModel>> snapshot) {
                    return Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = snapshot.data?[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                surfaceTintColor: Colors.blueGrey,
                                child: ListTile(
                                  onTap: () {
                                    context.go("/${GameInputScreen.routeName}");
                                  },
                                  subtitle: Text(
                                    item?.description ?? "",
                                    maxLines: 2,
                                  ),
                                  leading: item == null
                                      ? null
                                      : Stack(
                                          children: [
                                            Badge(
                                             backgroundColor: Colors.green,
                                              label: Text(
                                                  "${item.numberOfCopiesOwned}"),
                                            ),
                                            _getImage(item,
                                                onWantsToUpdatePhoto:
                                                    (game) async {
                                              final XFile? image =
                                                  await ImagePicker().pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              final imageBytes =
                                                  await image?.readAsBytes();
                                              if (imageBytes == null) return;
                                              final gameBase64String =
                                                  base64String(imageBytes);
                                              await LocalDatabaseService()
                                                  .updateBase64ImageForGame(
                                                      game, gameBase64String);
                                              AppWriteHandler().updatePictureOf(
                                                  File(image!.path),
                                                  gameBase64String,
                                                  game);
                                            })
                                          ],
                                        ),
                                  title: Text(item?.title ?? "no title"),
                                ),
                              ),
                            );
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

  Widget _getImage(VideoGameModel game,
      {Function(VideoGameModel game)? onWantsToUpdatePhoto}) {
    if (game.imageUrl.isNullOrEmpty() && game.imageBase64.isNullOrEmpty()) {
      print("no images at all");
      return const Icon(Icons.no_photography_outlined);
    }

    if (game.imageUrl.isNotNullNorEmpty()) {
      return CachedNetworkImage(
        imageUrl: game.imageUrl!,
        height: 100,
        width: 100,
        errorWidget: (_, __, ___) {
          return GestureDetector(
            onTap: () => onWantsToUpdatePhoto?.call(game),
            child: const Icon(
              Icons.no_photography_outlined,
              color: Colors.red,
            ),
          );
        },
      );
    } else if (game.imageBase64.isNotNullNorEmpty()) {
      return imageFromBase64String(game.imageBase64!);
    } else {
      return const Icon(
        Icons.no_photography_outlined,
        color: Colors.red,
      );
    }
  }
}

Future<String?> openGameEanScanner(BuildContext context,
    {VideoGamesCallback? onCurrentGamesUpdated,
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
      return null;
    }
    print(videoGame.items?.map((e) => e.title).join(", "));

    if (!context.mounted) return null;

    final gameModel = VideoGameModel.fromItems(videoGame.items!.first);

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
    await gameBox.put(gameModel.uuid, gameModel);
    final games = gameBox.values.toList();
    await gameBox.close();
    onCurrentGamesUpdated?.call(games);
    AppWriteHandler().saveGameInDatabase(gameModel).then((a) {
      print("Game uploaded to API ${a}");
    });
    return res;
  } else {
    return null;
  }
}
