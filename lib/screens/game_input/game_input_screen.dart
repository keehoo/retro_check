import 'dart:io' as io;
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/appwrite/appwrite.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/screens/game_input/game_input_cubit.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/twitch/twitch_api.dart';
import 'package:untitled/utils/image_helpers/image_helpers.dart';
import 'package:uuid/v4.dart';

const edgeInsets = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

class GameInputScreen extends StatelessWidget {
  static const String routeName = "game_input_screen";

  const GameInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game input screen"),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: edgeInsets,
            child: TextFormField(
              onChanged: (text) {
                context.read<GameInputCubit>().onGameTitleChanges(text);
              },
              decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: "game title",
                  hintText: "hint",
                  border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: edgeInsets,
            child: InkWell(
                onTap: () {
                  _openCamera(onImageFileSelected: (io.File file) {
                    context.read<GameInputCubit>().onImageFileSelected(file);
                  });
                },
                child: BlocBuilder<GameInputCubit, GameInputState>(
                  buildWhen: (p, c) => p.image != c.image,
                  builder: (context, state) {
                    return state.image == null
                        ? PicturePlaceholder(title: context.strings.add_picture)
                        : Image.file(state.image!);
                  },
                )),
          ),
          Padding(
            padding: edgeInsets,
            child: SizedBox(
              width: 148,
              height: 100,
              child: DottedBorder(
                padding: const EdgeInsets.all(0),
                radius: const Radius.circular(8),
                color: Colors.grey,
                borderType: BorderType.RRect,
                strokeWidth: 1,
                dashPattern: const [5, 4],
                child: IconButton(
                    onPressed: () async {
                      String? ean = await openGameEanScanner(context);
                      context.read<GameInputCubit>().onEanUpdated(ean);
                    },
                    icon: Image.asset("assets/icons/barcode.webp")),
              ),
            ),
          ),
          Padding(
            padding: edgeInsets,
            child: Text(
              "Please scan the bar code visible on some of the game boxes. This will allow us to search for that game based on that bar code. ",
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          BlocBuilder<GameInputCubit, GameInputState>(
            buildWhen: (p, c) => c.allPlatforms != null,
            builder: (cubitContext, state) {
              return state.allPlatforms == null
                  ? const SizedBox.shrink()
                  : PlatformSelectorWidget(
                      onPlatformSelected: (GamingPlatformEnum platform) {
                        context
                            .read<GameInputCubit>()
                            .onGaminPlatormEnumUpdated(platform);
                        showModalBottomSheet(
                            context: cubitContext,
                            builder: (context) {
                              return SizedBox(
                                child: CupertinoPicker(
                                    backgroundColor: Colors.black54,
                                    useMagnifier: true,
                                    squeeze: 1.4,
                                    itemExtent: 48.0,
                                    onSelectedItemChanged: (int itemIndex) {
                                      final GamingPlatform? selectedPlatform =
                                          state.allPlatforms?.getByPlatform(
                                              platform)[itemIndex];

                                      cubitContext
                                          .read<GameInputCubit>()
                                          .onPlatformSelected(selectedPlatform);
                                    },
                                    children: (state.allPlatforms
                                                ?.getByPlatform(platform) ??
                                            [])
                                        .map((element) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                element.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ))
                                        .toList()),
                              );
                            });
                      },
                    );
            },
          ),
          const Spacer(),
          BlocBuilder<GameInputCubit, GameInputState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () async {
                  /// move below to cubit
                  String gameUuid = const UuidV4().generate();
                  final imageUrl = await AppWriteHandler()
                      .storeGameImage(state.image!, gameUuid);
                  final Uint8List? imageBytes =
                      await state.image?.readAsBytes();

                  final platforms = await getGamingPlatforms();

                  VideoGameModel game = VideoGameModel(
                      uuid: gameUuid,
                      title: state.gameTitle ?? "",
                      description: null,
                      platform: state.platform ??
                          platforms.getPlatformFromTitle(state.gameTitle ?? ""),
                      ean: state.ean,
                      imageUrl: imageUrl.hashCode.toString(),
                      imageBase64: base64String(imageBytes!),
                      gamingPlatformEnum: state.platformEnum!,
                      numberOfCopiesOwned: 1);

                  await putGameInLocalDataBase(game);

                  AppWriteHandler().saveGameInDatabase(game);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: context.read<GameInputCubit>().isAllValid()
                    ? Padding(
                        padding: edgeInsets,
                        child: Card(
                          borderOnForeground: false,
                          surfaceTintColor:
                              context.read<GameInputCubit>().isAllValid()
                                  ? Colors.lightGreen
                                  : Colors.transparent,
                          elevation: context.read<GameInputCubit>().isAllValid()
                              ? 16
                              : 0,
                          child: ListTile(
                            title: Text(
                              state.gameTitle ?? "",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(state.platform?.name ?? ""),
                            trailing:
                                context.read<GameInputCubit>().isAllValid()
                                    ? const Icon(Icons.chevron_right_outlined)
                                    : null,
                            leading: state.image == null
                                ? const SizedBox.shrink()
                                : AnimatedContainer(
                                    duration: const Duration(seconds: 1),
                                    child: Image.file(state.image!)),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> putGameInLocalDataBase(VideoGameModel game) async {
    final gameBox = await Hive.openBox<VideoGameModel>("games");
    await gameBox.add(game);
    await gameBox.close();
  }

  Future<void> _openCamera(
      {required Function(io.File) onImageFileSelected,
      VoidCallback? onError}) async {
    final XFile? imageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 500, maxWidth: 500);

    if (imageFile == null) {
      onError?.call();
    }

    final Uint8List? imageBytes = await imageFile?.readAsBytes();
    final file = io.File(imageFile?.path ?? "");

    file.writeAsBytes(imageBytes?.toList() ?? []);
    onImageFileSelected(file);
  }
}

class PicturePlaceholder extends StatelessWidget {
  const PicturePlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      padding: const EdgeInsets.all(24),
      radius: const Radius.circular(8),
      color: Colors.grey,
      borderType: BorderType.RRect,
      strokeWidth: 1,
      dashPattern: const [5, 4],
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
      ),
    );
  }
}

class PlatformSelectorWidget extends StatelessWidget {
  const PlatformSelectorWidget({super.key, required this.onPlatformSelected});

  final Function(GamingPlatformEnum platform) onPlatformSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: GamingPlatformEnum.values.map((gp) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                  onTap: () {
                    onPlatformSelected(gp);
                  },
                  child: SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width / 4.5,
                      child: Image.asset(gp.getLogoAsset()))),
            );
          }).toList()),
    );
  }
}
