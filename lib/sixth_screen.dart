import 'package:borukva_news/hotspot_shared.dart';
import 'package:borukva_news/uv_caurosel_screen.dart';
import 'package:flutter/material.dart';

class UvFirstScreen extends StatefulWidget {
  const UvFirstScreen({super.key});

  @override
  State<UvFirstScreen> createState() => _UvFirstScreenState();
}

class _UvFirstScreenState extends UvCarouselScreenState<UvFirstScreen> {
  @override
  Widget get appBarTitleWidget => const Text(
    'Borukva News',
    style: TextStyle(
      fontFamily: 'Tapestry',
      fontWeight: FontWeight.w600,
      fontSize: 40,
    ),
  );

  @override
  HotspotStorage get storage => HotspotStorage(
    workerUrl:
        'https://gh-proxy.pavlyk-smal.workers.dev?file=29_03-10_05_hotspots.json',
    cacheKey: '29_03-10_05_hotspots_cache',
  );

  @override
  List<UvPageItem> get uvPages => [
    const UvPageItem.withUv(
      PageItem.image(
        'assets/pictures/29_03-10_05/Газета 29.03-10.05 Титул.png',
      ),
      'assets/pictures/29_03-10_05/Газета 29.03-10.05 Титул невидимка.png',
    ),
    // Example: page with a UV overlay
    UvPageItem.full(
      const PageItem.image(
        'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 1.png',
      ),
      'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 1 невидимка.png',
      'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 1 додаток – фінальна.png',
    ),
    const UvPageItem.withUv(
      PageItem.image(
        'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 2.png',
      ),
      'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 2 невидимка.png',
    ),
    const UvPageItem.withUv(
      PageItem.image(
        'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 3.png',
      ),
      'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 3 невидимка.png',
    ),
    const UvPageItem.withUv(
      PageItem.image(
        'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 4.png',
      ),
      'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 4 невидимка.png',
    ),
    const UvPageItem.withUv(
      PageItem.image(
        'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 5.png',
      ),
      'assets/pictures/29_03-10_05/Газета 29.03-10.05 стор. 5 невидимка.png',
    ),
    const UvPageItem(PageItem.image('assets/pictures/остання стор.png')),
  ];
}
