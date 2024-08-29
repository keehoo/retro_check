// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_video_game_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoGameModelAdapter extends TypeAdapter<VideoGameModel> {
  @override
  final int typeId = 4;

  @override
  VideoGameModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoGameModel(
      title: fields[1] as String,
      description: fields[2] as String?,
      platform: fields[3] as GamingPlatform,
      ean: fields[4] as String?,
      imageUrl: fields[5] as String?,
      imageBase64: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoGameModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.platform)
      ..writeByte(4)
      ..write(obj.ean)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.imageBase64);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoGameModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GamingPlatformAdapter extends TypeAdapter<GamingPlatform> {
  @override
  final int typeId = 5;

  @override
  GamingPlatform read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GamingPlatform(
      twitchiId: fields[1] as String,
      name: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GamingPlatform obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.twitchiId)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamingPlatformAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
