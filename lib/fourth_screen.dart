import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

class FourthScreen extends StatefulWidget {
  const FourthScreen({super.key});
  @override
  State<FourthScreen> createState() => _FourthScreenState();
}

class _FourthScreenState extends CarouselScreenState<FourthScreen> {
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
        'https://gh-proxy.pavlyk-smal.workers.dev?file=01_03-14_03_hotspots.json',
    cacheKey: '01_03-14_03_hotspots_cache',
  );

  @override
  List<PageItem> get pages => [
    PageItem.image('assets/pictures/01_03-14_03/Титул. 1-14 бер.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 1.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 2.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 3.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 4.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 5.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 6.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 7.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 8.png'),
    PageItem.image('assets/pictures/01_03-14_03/Газета 1-14 бер стор. 9.png'),
    PageItem.image('assets/pictures/остання стор.png'),
  ];
}
