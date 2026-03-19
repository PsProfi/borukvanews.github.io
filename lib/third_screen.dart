import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});
  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends CarouselScreenState<ThirdScreen> {
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
        'https://gh-proxy.pavlyk-smal.workers.dev?file=22_02-28_02_hotspots.json',
    cacheKey: '22_02-28_02_hotspots_cache',
  );

  @override
  List<PageItem> get pages => [
    PageItem.image('assets/pictures/22_02-28_02/22.02-28.02.png'),
    PageItem.image('assets/pictures/22_02-28_02/Газета 22-28 лют стор. 1.png'),
    PageItem.image('assets/pictures/22_02-28_02/Газета 22-28 лют стор. 2.png'),
    PageItem.image('assets/pictures/22_02-28_02/Газета 22-28 лют стор. 3.png'),
    PageItem.image('assets/pictures/22_02-28_02/Газета 22-28 лют стор. 4.png'),
    PageItem.image('assets/pictures/22_02-28_02/Газета 22-28 лют стор. 5.png'),
    PageItem.image('assets/pictures/остання стор.png'),
    PageItem.image('assets/pictures/22_02-28_02/Газета 22-28 лют стор. 6.png'),
    PageItem.image('assets/pictures/22_02-28_02/Газета 22-28 лют стор. 7.png'),
    PageItem.image('assets/pictures/22_02-28_02/Газета 22-28 лют стор. 8.png'),
  ];
}
