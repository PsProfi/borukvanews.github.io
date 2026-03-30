import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

class FifthScreen extends StatefulWidget {
  const FifthScreen({super.key});
  @override
  State<FifthScreen> createState() => _FifthScreenState();
}

class _FifthScreenState extends CarouselScreenState<FifthScreen> {
  @override
  Widget get appBarTitleWidget => Text(
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
        'https://gh-proxy.pavlyk-smal.workers.dev?file=15_03-29_03_hotspots.json',
    cacheKey: '15_03-29_03_hotspots_cache',
  );

  @override
  List<PageItem> get pages => [
    PageItem.image('assets/pictures/15_03-29_03/Титул. 15-29 бер.png'),
    PageItem.image('assets/pictures/15_03-29_03/Газета 15-29 бер стор. 1.png'),
    PageItem.image('assets/pictures/15_03-29_03/Газета 15-29 бер стор. 2.png'),
    PageItem.image('assets/pictures/15_03-29_03/Газета 15-29 бер стор. 3.png'),
    PageItem.image('assets/pictures/15_03-29_03/Газета 15-29 бер стор. 4.png'),
    PageItem.image('assets/pictures/15_03-29_03/Газета 15-29 бер стор. 5.png'),
    PageItem.image('assets/pictures/15_03-29_03/Газета 15-29 бер стор. 6.png'),
    PageItem.image('assets/pictures/остання стор.png'),
  ];
}
