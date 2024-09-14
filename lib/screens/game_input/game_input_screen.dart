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
                SizedBox(
                  height: scSize.height * 0.15,
                  child: BlocBuilder<GameInputCubit, GameInputState>(
                    builder: (context, state) {
                      return PhysicalModel(
                        elevation: 8,
                        color: Colors.black12,
                        child: SizedBox(
                          width: scSize.width,
                          child: Column(
                            children: [
                              state.gameTitle != null
                                  ? Expanded(
                                      child: Text(
                                      state.gameTitle!,
                                      style: context.textStyle.bodySmall,
                                    ))
                                  : const SizedBox.shrink(),
                              state.ean != null
                                  ? Expanded(
                                      child: Text(state.ean!,
                                          style: context.textStyle.bodySmall))
                                  : const SizedBox.shrink(),
                              state.image != null
                                  ? Expanded(child: Image.file(state.image!))
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      );
                    },
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
