import 'dart:io';

import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/video_game.dart';

typedef VideoGamesCallback = void Function(List<VideoGameModel>);
typedef StringCallback = void Function(String);
typedef FileCallback = void Function(File);
typedef VideoGameCallback = void Function(VideoGameModel, VideoGame? rawVideoGame);
