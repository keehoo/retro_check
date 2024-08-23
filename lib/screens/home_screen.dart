import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/video_game.dart';
import 'package:untitled/screens/game_details/game_details_screen.dart';
import 'package:untitled/twitch/twitch_api.dart';
import 'package:untitled/utils/colors/app_palette.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{

  List<VideoGame> games = [];
  final psn =
      """{"npsso":"8vs5a98DFKXVutXQkWMPLxGaDjKZdH7c6jwZRjYMrZVgJUFcTEvmj5jgA9Q8nmHc"}""";

  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
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
          backgroundColor: Colors.transparent,
          title: const Text(
            "App title",
          ),
          actions: [
            IconButton(
                onPressed: () => _openGameScanner(context),
                icon: const Icon(Icons.add_a_photo_outlined))
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: _getVideoGames(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<VideoGame>> snapshot) {
                    return Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final Items? item =
                                snapshot.data?[index].items?.firstOrNull;
                            return ListTile(
                              onTap: () {
                                context.go("/${GameDetailsScreen.routeName}", extra: item);
                              },
                              subtitle: Text(
                                item?.description ?? "",
                              ),
                              // leading: GestureDetector(
                              //   onTap: () async {
                              //     final devSize = MediaQuery.of(context).size;
                              //     // final ImagePicker picker = ImagePicker();
                              //     // final XFile? image = await picker.pickImage(
                              //     //     source: ImageSource.camera,
                              //     //     maxHeight: devSize.height / 2,
                              //     //     maxWidth: devSize.width / 2);
                              //     //
                              //     // _onUpdateGameImage(
                              //     //     item, image, snapshot.data);
                              //   },
                              //   child: SizedBox(
                              //       width: 100,
                              //       height: 100,
                              //       child: _getImage(item?.images,
                              //           gameName: item?.title)),
                              // ),
                              title: Text(item?.title ?? "no title"),
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

  Future<void> _openGameScanner(BuildContext context) async {
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
        return;
      }
      // if (!context.mounted) return;
      final Iterable<GamingPlatform> platformsBox =
          (await Hive.openBox<GamingPlatform>("gaming_platforms"))
              .values
              .toSet();
      // final possiblePlatformNames =
      //     (videoGame.items?.first.title?.split(" ") ?? []);

      if (!context.mounted) return;

      final gameBox = await Hive.openBox<VideoGame>("games");
      await gameBox.put(videoGame.items?.first.ean, videoGame);
      setState(() {
        games = gameBox.values.toList();
      });
      await gameBox.close();
    }
  }

  Future<List<VideoGame>> _getVideoGames() async {
    final List<VideoGame> games = [];
    final gamebox = await Hive.openBox<VideoGame>("games");
    games.addAll(gamebox.values);
    await gamebox.close();
    return games;
  }

  Widget _getImage(List<String>? images, {String? gameName}) {
    print("Images for $gameName ${images?.join(", ")}");

    const _ = "814a5e5f9ec961b208b89668f557e4c82f1aecc7"; //gianBompApiKey

    if (images == null || images.isEmpty) {
      return const Icon(Icons.camera_alt_outlined);
    } else {
      return Image.network(
        images.first,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.no_photography_outlined);
        },
      );
    }
  }

  void _onUpdateGameImage(Items? item, XFile? image, List<VideoGame>? data) {
    print("${item?.title}");
  }
}
