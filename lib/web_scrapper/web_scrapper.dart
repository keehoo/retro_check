import 'package:chaleno/chaleno.dart';

class WebScrapper {
  Future<List<WebScrappedGame>> searchByQuery({required String s}) async {

    final queryString =
        'https://www.pricecharting.com/search-products?q=${s.replaceAll(" ", "+")}&type=prices';
    final chaleno = await Chaleno().load(queryString);

    final List<Result>? dd =
        chaleno?.getElementsByClassName("hoverable-rows sortable");

    Result? result = dd?.first;

    final List<Result>? qwe = result?.querySelectorAll("[id*='product']");
    final List<WebScrappedGame> otherItems = qwe
            ?.map((Result e) {
              final List<String>? eText =
                  e.text?.split("\n").map((String e) => e.trim()).where((e) {
                final isValid = e.isNotEmpty;
                return isValid;
              }).toList();
              if (eText?[1].toLowerCase().contains("comic") ?? true) {
                return WebScrappedGame.dummy();
              }
              final scrappedGame = WebScrappedGame(
                title: eText?[0] ?? "",
                platform: eText?[1] ?? "",
                minPrice:
                    eText?[2].startsWith("\$") ?? false ? (eText?[2]) : null,
                midPrice:
                    eText?[3].startsWith("\$") ?? false ? (eText?[3]) : null,
                maxPrice:
                    eText?[4].startsWith("\$") ?? false ? (eText?[4]) : null,
              );
              return scrappedGame;
            })
            .where((game) => game != WebScrappedGame.dummy())
            .toList() ??
        [];
    return otherItems;
  }
}

class WebScrappedGame {
  final String title;
  final String? platform;
  final String? minPrice;
  final String? midPrice;
  final String? maxPrice;

  WebScrappedGame.dummy(
      {this.title = "",
      this.platform = "",
      this.minPrice = "",
      this.midPrice = "",
      this.maxPrice = ""});

  const WebScrappedGame({
    required this.title,
    this.platform,
    this.minPrice,
    this.midPrice,
    this.maxPrice,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebScrappedGame &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          platform == other.platform &&
          minPrice == other.minPrice &&
          midPrice == other.midPrice &&
          maxPrice == other.maxPrice;

  @override
  int get hashCode =>
      title.hashCode ^
      platform.hashCode ^
      minPrice.hashCode ^
      midPrice.hashCode ^
      maxPrice.hashCode;
}
