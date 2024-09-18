import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/screens/game_input/game_input_cubit.dart';
import 'package:untitled/screens/game_input/game_title_input/game_title_input_widget.dart';
import 'package:untitled/screens/game_input/picture_placeholder/ean_scanner_widget.dart';
import 'package:untitled/screens/game_input/picture_placeholder/picture_add_game.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

import 'platform_selection/platform_selection_screen.dart';
import 'platform_selection/platform_selector_page.dart';

const edgeInsets = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

class GameInputScreen extends StatelessWidget {
  static const String routeName = "game_input_screen";

  const GameInputScreen({super.key});

  List<Widget> gameInputScreens(BuildContext context) => [
        _getGameTitleWidget(context),
        _getPictureAddForGame(context),
        _getEanScannerForGame(context),
        _getPlatformSelectorPage(context)
      ];



  @override
  Widget build(BuildContext context) {
    Size scSize = MediaQuery.of(context).size;
    return BlocListener<GameInputCubit, GameInputState>(
      listenWhen: (p, c) {
        return c.pageIndex > gameInputScreens(context).length;
      },
      listener: (context, state) async {
        Lgr.log("finished getting the game data");
        final game = await state.validate();
        if (game == null || !context.mounted) {
          return;
        } else {
          context.pop(game);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Game input screen",
            style: context.textStyle.titleLarge,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: false,
          automaticallyImplyLeading: true,
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
                child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<GameInputCubit, GameInputState>(
                    builder: (context, state) {
                      return state.allPlatforms != null
                          ? PageView.builder(
                              onPageChanged: (int page) {
                                context.read<GameInputCubit>().onPageChanged(
                                    page, gameInputScreens(context).length);
                              },
                              controller:
                                  context.read<GameInputCubit>().pageController,
                              itemCount: gameInputScreens(context).length,
                              itemBuilder: (BuildContext context, int index) {
                                return gameInputScreens(context)[index];
                              })
                          : const Center(
                              child: CupertinoActivityIndicator(),
                            );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(4, 2)),
                        ]),
                    height: scSize.height * 0.1,
                    child: BlocBuilder<GameInputCubit, GameInputState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: scSize.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              state.image != null
                                  ? CircleAvatar(
                                      foregroundImage:
                                          FileImage(state.image!, scale: 1),
                                    )
                                  : const SizedBox.shrink(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    state.gameTitle != null
                                        ? Expanded(
                                            child: Text(
                                            state.gameTitle!,
                                            style: context.textStyle.bodyLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ))
                                        : const SizedBox.shrink(),
                                    state.ean != null
                                        ? Expanded(
                                            child: Text(state.ean!,
                                                style: context
                                                    .textStyle.bodySmall))
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              state.platformEnum != null
                                  ? Image.asset(
                                      state.platformEnum!.getLogoAsset())
                                  : const SizedBox.shrink(),
                              state.platform != null
                                  ? Text(state.platform!.name,
                                      style: context.textStyle.bodyMedium)
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Future<void> putGameInLocalDataBase(VideoGameModel game) async {
    final gameBox = await Hive.openBox<VideoGameModel>("games");
    await gameBox.add(game);
    await gameBox.close();
  }

  PlatformSelectorPage _getPlatformSelectorPage(BuildContext context) =>
      PlatformSelectorPage(
        platformsBreakdown: context
            .read<GameInputCubit>()
            .state
            .allPlatforms!, // TODO: fix that dangerous !
        onPlatformSelected: (FullPlatform platform) {
          context.read<GameInputCubit>()
            ..onPlatformSelected(platform)
            ..onGoToNextPage();
        },
      );

  EanScannerWidget _getEanScannerForGame(BuildContext context) =>
      EanScannerWidget(onEanScanned: (ean) {
        Lgr.log("We got the ean numebr $ean");
        context.read<GameInputCubit>()
          ..onEanUpdated(ean)
          ..onGoToNextPage();
      });

  PictureAddGame _getPictureAddForGame(BuildContext context) {
    return PictureAddGame(
      onPhotoUpdated: (File file) {
        context.read<GameInputCubit>()
          ..onImageFileSelected(file)
          ..onGoToNextPage();
      },
    );
  }

  GameTitleInputWidget _getGameTitleWidget(BuildContext context,
      {String? initialText}) {
    return GameTitleInputWidget(
      onTitleFinishedEditing: (String gameTitle) {
        context.read<GameInputCubit>()
          ..onGameTitleChanges(gameTitle)
          ..onGoToNextPage();
      },
      textEditingController: TextEditingController(text: initialText),
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
          children: GamingPlatformEnum.values
              .where((e) => e != GamingPlatformEnum.unknown)
              .map((gp) {
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
