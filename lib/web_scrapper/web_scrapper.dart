import 'package:chaleno/chaleno.dart';

class WebScrapper {
  static var gameSearchQuery = "dune 2".replaceAll(" ", "+");
  final queryString =
      'https://www.pricecharting.com/search-products?q=$gameSearchQuery&type=prices';

  Future<void> init({required String s}) async {
    gameSearchQuery = s.replaceAll(" ", "+");

    final chaleno = await Chaleno().load(queryString);

    final List<Result>? dd =
        chaleno?.getElementsByClassName("hoverable-rows sortable");

    final items = dd?.map((Result e) {
      return e;
    }).toList();

    print(items);

    Result? result = dd?.first;

    final List<Result>? qwe = result?.querySelectorAll("[id*='product']");
    final List? otherItems = qwe
        ?.map((Result e) {
          final List<String>? eText =
              e.text?.split("\n").map((String e) => e.trim()).where((e) {
            final isValid = e.isNotEmpty;
            return isValid;
          }).toList();
          if (eText?[1].toLowerCase().contains("comic") ?? true) {
            return null;
          }
          final scrappedGame = WebScrappedGame(
            title: eText?[0] ?? "",
            platform: eText?[1] ?? "",
            minPrice: eText?[2].startsWith("\$") ?? false ? (eText?[2]) : null,
            midPrice: eText?[3].startsWith("\$") ?? false ? (eText?[3]) : null,
            maxPrice: eText?[4].startsWith("\$") ?? false ? (eText?[4]) : null,
          );
          return scrappedGame;
        })
        .where((game) => game != null)
        .toList();

    print(otherItems);
  }
}

class WebScrappedGame {
  final String title;
  final String? platform;
  final String? minPrice;
  final String? midPrice;
  final String? maxPrice;

  WebScrappedGame(
      {required this.title,
      required this.platform,
      required this.minPrice,
      required this.midPrice,
      required this.maxPrice});
}
