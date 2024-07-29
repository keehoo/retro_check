import 'dart:convert';

import 'package:hive/hive.dart';

part 'video_game.g.dart';

VideoGame videoGameFromJson(String str) => VideoGame.fromJson(json.decode(str));

String videoGameToJson(VideoGame data) => json.encode(data.toJson());

@HiveType(typeId: 1)
class VideoGame {
  VideoGame({
    this.code,
    this.total,
    this.offset,
    this.items,
  });

  VideoGame.fromJson(dynamic json) {
    code = json['code'];
    total = json['total'];
    offset = json['offset'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
  }

  @HiveField(1)
  String? code;
  @HiveField(2)
  num? total;
  @HiveField(3)
  num? offset;
  @HiveField(4)
  List<Items>? items;

  VideoGame copyWith({
    String? code,
    num? total,
    num? offset,
    List<Items>? items,
  }) =>
      VideoGame(
        code: code ?? this.code,
        total: total ?? this.total,
        offset: offset ?? this.offset,
        items: items ?? this.items,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['total'] = total;
    map['offset'] = offset;
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

Items itemsFromJson(String str) => Items.fromJson(json.decode(str));

String itemsToJson(Items data) => json.encode(data.toJson());

@HiveType(typeId: 2)
class Items {
  Items({
    this.ean,
    this.title,
    this.description,
    this.upc,
    this.brand,
    this.model,
    this.color,
    this.size,
    this.dimension,
    this.weight,
    this.category,
    this.currency,
    this.lowestRecordedPrice,
    this.highestRecordedPrice,
    this.images,
    this.offers,
    this.elid,
  });

  Items.fromJson(dynamic json) {
    ean = json['ean'];
    title = json['title'];
    description = json['description'];
    upc = json['upc'];
    brand = json['brand'];
    model = json['model'];
    color = json['color'];
    size = json['size'];
    dimension = json['dimension'];
    weight = json['weight'];
    category = json['category'];
    currency = json['currency'];
    lowestRecordedPrice = json['lowest_recorded_price'];
    highestRecordedPrice = json['highest_recorded_price'];
    images = json['images'] != null ? json['images'].cast<String>() : [];
    if (json['offers'] != null) {
      offers = [];
      json['offers'].forEach((v) {
        offers?.add(Offers.fromJson(v));
      });
    }
    elid = json['elid'];
  }

  @HiveField(1)
  String? ean;
  @HiveField(2)
  String? title;
  @HiveField(3)
  String? description;
  @HiveField(4)
  String? upc;
  @HiveField(5)
  String? brand;
  @HiveField(6)
  String? model;
  @HiveField(7)
  String? color;
  @HiveField(8)
  String? size;
  @HiveField(9)
  String? dimension;
  @HiveField(17)
  String? weight;
  @HiveField(10)
  String? category;
  @HiveField(11)
  String? currency;
  @HiveField(12)
  num? lowestRecordedPrice;
  @HiveField(13)
  num? highestRecordedPrice;
  @HiveField(14)
  List<String>? images;
  @HiveField(15)
  List<Offers>? offers;
  @HiveField(16)
  String? elid;

  Items copyWith({
    String? ean,
    String? title,
    String? description,
    String? upc,
    String? brand,
    String? model,
    String? color,
    String? size,
    String? dimension,
    String? weight,
    String? category,
    String? currency,
    num? lowestRecordedPrice,
    num? highestRecordedPrice,
    List<String>? images,
    List<Offers>? offers,
    String? elid,
  }) =>
      Items(
        ean: ean ?? this.ean,
        title: title ?? this.title,
        description: description ?? this.description,
        upc: upc ?? this.upc,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        color: color ?? this.color,
        size: size ?? this.size,
        dimension: dimension ?? this.dimension,
        weight: weight ?? this.weight,
        category: category ?? this.category,
        currency: currency ?? this.currency,
        lowestRecordedPrice: lowestRecordedPrice ?? this.lowestRecordedPrice,
        highestRecordedPrice: highestRecordedPrice ?? this.highestRecordedPrice,
        images: images ?? this.images,
        offers: offers ?? this.offers,
        elid: elid ?? this.elid,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ean'] = ean;
    map['title'] = title;
    map['description'] = description;
    map['upc'] = upc;
    map['brand'] = brand;
    map['model'] = model;
    map['color'] = color;
    map['size'] = size;
    map['dimension'] = dimension;
    map['weight'] = weight;
    map['category'] = category;
    map['currency'] = currency;
    map['lowest_recorded_price'] = lowestRecordedPrice;
    map['highest_recorded_price'] = highestRecordedPrice;
    map['images'] = images;
    if (offers != null) {
      map['offers'] = offers?.map((v) => v.toJson()).toList();
    }
    map['elid'] = elid;
    return map;
  }
}

Offers offersFromJson(String str) => Offers.fromJson(json.decode(str));

String offersToJson(Offers data) => json.encode(data.toJson());

@HiveType(typeId: 3)
class Offers {
  Offers({
    this.merchant,
    this.domain,
    this.title,
    this.currency,
    this.listPrice,
    this.price,
    this.shipping,
    this.condition,
    this.availability,
    this.link,
    this.updatedT,
  });

  Offers.fromJson(dynamic json) {
    merchant = json['merchant'];
    domain = json['domain'];
    title = json['title'];
    currency = json['currency'];
    listPrice = json['list_price'].toString();
    price = json['price'];
    shipping = json['shipping'];
    condition = json['condition'];
    availability = json['availability'];
    link = json['link'];
    updatedT = json['updated_t'];
  }

  @HiveField(1)
  String? merchant;
  @HiveField(2)
  String? domain;
  @HiveField(3)
  String? title;
  @HiveField(4)
  String? currency;
  @HiveField(5)
  String? listPrice;
  @HiveField(6)
  num? price;
  @HiveField(7)
  String? shipping;
  @HiveField(8)
  String? condition;
  @HiveField(9)
  String? availability;
  @HiveField(10)
  String? link;
  @HiveField(11)
  num? updatedT;

  Offers copyWith({
    String? merchant,
    String? domain,
    String? title,
    String? currency,
    String? listPrice,
    num? price,
    String? shipping,
    String? condition,
    String? availability,
    String? link,
    num? updatedT,
  }) =>
      Offers(
        merchant: merchant ?? this.merchant,
        domain: domain ?? this.domain,
        title: title ?? this.title,
        currency: currency ?? this.currency,
        listPrice: listPrice ?? this.listPrice,
        price: price ?? this.price,
        shipping: shipping ?? this.shipping,
        condition: condition ?? this.condition,
        availability: availability ?? this.availability,
        link: link ?? this.link,
        updatedT: updatedT ?? this.updatedT,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['merchant'] = merchant;
    map['domain'] = domain;
    map['title'] = title;
    map['currency'] = currency;
    map['list_price'] = listPrice;
    map['price'] = price;
    map['shipping'] = shipping;
    map['condition'] = condition;
    map['availability'] = availability;
    map['link'] = link;
    map['updated_t'] = updatedT;
    return map;
  }
}
