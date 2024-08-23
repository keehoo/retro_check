// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoGameAdapter extends TypeAdapter<VideoGame> {
  @override
  final int typeId = 1;

  @override
  VideoGame read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoGame(
      code: fields[1] as String?,
      total: fields[2] as num?,
      offset: fields[3] as num?,
      items: (fields[4] as List?)?.cast<Items>(),
    );
  }

  @override
  void write(BinaryWriter writer, VideoGame obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.total)
      ..writeByte(3)
      ..write(obj.offset)
      ..writeByte(4)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoGameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemsAdapter extends TypeAdapter<Items> {
  @override
  final int typeId = 2;

  @override
  Items read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Items(
      ean: fields[1] as String?,
      title: fields[2] as String?,
      description: fields[3] as String?,
      upc: fields[4] as String?,
      brand: fields[5] as String?,
      model: fields[6] as String?,
      color: fields[7] as String?,
      size: fields[8] as String?,
      dimension: fields[9] as String?,
      weight: fields[17] as String?,
      category: fields[10] as String?,
      currency: fields[11] as String?,
      lowestRecordedPrice: fields[12] as num?,
      highestRecordedPrice: fields[13] as num?,
      images: (fields[14] as List?)?.cast<String>(),
      offers: (fields[15] as List?)?.cast<Offers>(),
      elid: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Items obj) {
    writer
      ..writeByte(17)
      ..writeByte(1)
      ..write(obj.ean)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.upc)
      ..writeByte(5)
      ..write(obj.brand)
      ..writeByte(6)
      ..write(obj.model)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.size)
      ..writeByte(9)
      ..write(obj.dimension)
      ..writeByte(17)
      ..write(obj.weight)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.currency)
      ..writeByte(12)
      ..write(obj.lowestRecordedPrice)
      ..writeByte(13)
      ..write(obj.highestRecordedPrice)
      ..writeByte(14)
      ..write(obj.images)
      ..writeByte(15)
      ..write(obj.offers)
      ..writeByte(16)
      ..write(obj.elid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OffersAdapter extends TypeAdapter<Offers> {
  @override
  final int typeId = 3;

  @override
  Offers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Offers(
      merchant: fields[1] as String?,
      domain: fields[2] as String?,
      title: fields[3] as String?,
      currency: fields[4] as String?,
      listPrice: fields[5] as String?,
      price: fields[6] as num?,
      shipping: fields[7] as String?,
      condition: fields[8] as String?,
      availability: fields[9] as String?,
      link: fields[10] as String?,
      updatedT: fields[11] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, Offers obj) {
    writer
      ..writeByte(11)
      ..writeByte(1)
      ..write(obj.merchant)
      ..writeByte(2)
      ..write(obj.domain)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.listPrice)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.shipping)
      ..writeByte(8)
      ..write(obj.condition)
      ..writeByte(9)
      ..write(obj.availability)
      ..writeByte(10)
      ..write(obj.link)
      ..writeByte(11)
      ..write(obj.updatedT);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
