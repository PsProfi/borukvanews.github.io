import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});
  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends CarouselScreenState<SecondScreen> {
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
        'https://gh-proxy.pavlyk-smal.workers.dev?file=15_02-21_02_hotspots.json',
    cacheKey: '15_02-21_02_hotspots_cache',
  );

  @override
  List<PageItem> get pages => [
    PageItem.image('assets/pictures/15_02-21_02/15.02-21.02.png'),
    PageItem.image('assets/pictures/15_02-21_02/Газета 15-21 лют стор. 1.png'),
    PageItem.image('assets/pictures/15_02-21_02/Газета 15-21 лют стор. 2.png'),
    PageItem.image('assets/pictures/15_02-21_02/Газета 15-21 лют стор. 3.png'),
    PageItem.image('assets/pictures/15_02-21_02/Газета 15-21 лют стор. 4.png'),
    PageItem.image('assets/pictures/15_02-21_02/Газета 15-21 лют стор. 5.png'),
    PageItem.image('assets/pictures/остання стор.png'),
  ];
}
