// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/video_game.dart';
import 'package:untitled/web_scrapper/web_scrapper.dart';

class WidgetData {
  String? title;
  TextStyle? titleTextStyle;
}

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(VideoGameAdapter());
  Hive.registerAdapter(ItemsAdapter());
  Hive.registerAdapter(OffersAdapter());

  WebScrapper().init();

  runApp(const MyApp());
  AppWriteHandler().init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<VideoGame> games = [];
  final psn =
      """{"npsso":"8vs5a98DFKXVutXQkWMPLxGaDjKZdH7c6jwZRjYMrZVgJUFcTEvmj5jgA9Q8nmHc"}""";

  final twitchClientId = "7ye79qmkzxt2w2w1p42pzk2righnqv";
  final twitchClientSecret = "j6766v8gdnbbcq6yrf0b2hu90y9j0m";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _twitchAuth();
  }

  // POST: https://id.twitch.tv/oauth2/token?client_id=abcdefg12345&client_secret=hijklmn67890&grant_type=client_credentials

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _getVideoGames(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<VideoGame>> snapshot) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final Items? item =
                            snapshot.data?[index].items?.firstOrNull;
                        return ListTile(
                          subtitle: Text(
                            item?.description ?? "",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          leading: SizedBox(
                              width: 100,
                              height: 100,
                              child: _getImage(item?.images,
                                  gameName: item?.title)),
                          title: Text(item?.title ?? "no title"),
                        );
                      });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ));
                if (res is String) {
                  print(res);
                  final dio = Dio();
                  final game = await dio.request(
                      "https://api.upcitemdb.com/prod/trial/lookup?upc=$res");
                  final videoGame = VideoGame.fromJson(game.data);

                  if (videoGame.items?.isEmpty ?? true) {
                    print("items is empty for that game");
                    return;
                  }

                  final gameBox = await Hive.openBox<VideoGame>("games");
                  await gameBox.put(videoGame.items?.first.ean, videoGame);
                  setState(() {
                    games = gameBox.values.toList();
                  });
                  await gameBox.close();
                }
              },
              child: const Text('Open Scanner'),
            ),
          ],
        ),
      ),
    );
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
      return const Icon(Icons.no_photography_outlined);
    } else {
      return Image.network(
        images.first,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.no_photography_outlined);
        },
      );
    }
  }

  Future<void> _twitchAuth() async {
    // POST: https://id.twitch.tv/oauth2/token?client_id=abcdefg12345&client_secret=hijklmn67890&grant_type=client_credentials
    final dio = Dio();
    final response = await dio.post(
        "https://id.twitch.tv/oauth2/token?client_id=$twitchClientId&client_secret=$twitchClientSecret&grant_type=client_credentials");

    print(response);

    final String accessToken = response.data["access_token"];

    // dio.post('https://api.igdb.com/v4/games', );
    final platforms = await dio.post('https://api.igdb.com/v4/platforms',
        data: "fields *; limit 300;",
        options: Options(headers: <String, dynamic>{
          "Client-ID": twitchClientId,
          "Authorization": "Bearer $accessToken"
        }));

    final Iterable<MapEntry> platformsString = (platforms.data as List<dynamic>)
        .map((p) => MapEntry<String, dynamic>(p['id'].toString(), p['name']));
    final Map<dynamic, dynamic> d = Map.fromEntries(platformsString);

    final playstationsIds = Map.fromEntries(d.entries.where((element) =>
        (element.value as String).toLowerCase().contains("playstation 3")));

    print("Playstation 3 ids:");
    playstationsIds.forEach((key, value) {
      print("$value - $key");
    });

    final data =
        "fields name,platforms; where platforms = (${playstationsIds.keys.join(",")}); limit 100;";
    // final data2 =
    //     "fields name,platforms; where platforms = ${playstationsIds.keys.first}; limit 999;";

    final games = await dio.post('https://api.igdb.com/v4/games',
        data: data,
        options: Options(headers: <String, dynamic>{
          "Client-ID": twitchClientId,
          "Authorization": "Bearer $accessToken"
        }));

    print(games.data);
    print(platforms.data);
  }
}
