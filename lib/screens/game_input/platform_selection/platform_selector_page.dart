import 'package:flutter/material.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/screens/game_input/game_input_screen.dart';
import 'package:untitled/screens/game_input/platform_selection/platform_selection_screen.dart';

class PlatformSelectorPage extends StatefulWidget {
  final GaminPlatformsBreakdown platformsBreakdown;
  final Function(FullPlatform) onPlatformSelected;

  const PlatformSelectorPage({
    super.key,
    required this.platformsBreakdown,
    required this.onPlatformSelected,
  });

  @override
  State<PlatformSelectorPage> createState() => _PlatformSelectorPageState();
}

class _PlatformSelectorPageState extends State<PlatformSelectorPage> {
  GamingPlatformEnum? platformEnum;
  GamingPlatform? platform;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlatformSelectorWidget(onPlatformSelected: (GamingPlatformEnum pl) {
          setState(() {
            platformEnum = pl;
          });
        }),
        platformEnum != null
            ? Expanded(
                child: buildListView(
                    widget.platformsBreakdown.getByPlatform(platformEnum!),
                    context,
                    platformEnum!, onPlatformSelected: (FullPlatform platform) {
                  widget.onPlatformSelected(platform);
                }),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
