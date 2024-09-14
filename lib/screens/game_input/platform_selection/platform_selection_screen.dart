import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/screens/game_input/game_input_screen.dart';
import 'package:untitled/twitch/twitch_api.dart';

class PlatformSelectionScreen extends StatelessWidget {
  const PlatformSelectionScreen({super.key});

  static const routeName = "platform_selection_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Platform selection screen"),
      ),
      body: SafeArea(
          child: FutureBuilder(
              future: getGamingPlatforms(),
              builder: (c, AsyncSnapshot<GaminPlatformsBreakdown> data) {
                if (data.hasData) {
                  return Column(children: [
                    const Text("Please select the platform:"),
                    PlatformSelectorWidget(
                        onPlatformSelected: (platform) async {
                      final result = await showModalBottomSheet(
                          context: c,
                          builder: (context) {
                            final plats =
                                data.data?.getByPlatform(platform) ?? [];
                            return Card(
                              child: buildListView(plats, context, platform),
                            );
                          });
                      if (!context.mounted) return;
                      context.pop(result);
                    })
                  ]);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })),
    );
  }
}

class FullPlatform extends Equatable {
  final GamingPlatformEnum platformEnum;
  final GamingPlatform specificPlatformModel;
  final String? model;
  final String? color;

  const FullPlatform(
      {required this.platformEnum,
      required this.specificPlatformModel,
      this.model,
      this.color});

  @override
  List<Object?> get props =>
      [platformEnum, specificPlatformModel, model, color];
}

ListView buildListView(List<GamingPlatform> plats, BuildContext context,
    GamingPlatformEnum platform, {Function(FullPlatform)? onPlatformSelected}) {
  return ListView(
    children: plats
        .map((item) => GestureDetector(
              onTap: () {
                final fullPlatform = FullPlatform(
                    platformEnum: platform, specificPlatformModel: item);
                if (onPlatformSelected == null) {
                  context.pop(fullPlatform);
                } else {
                  onPlatformSelected.call(fullPlatform);
                }
              },
              child: ListTile(
                title: Text(
                  item.name,
                  style: context.textStyle.titleLarge,
                ),
              ),
            ))
        .toList(),
  );
}
