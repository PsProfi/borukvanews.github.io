import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});
  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends CarouselScreenState<SecondScreen> {
  @override
  String get appBarTitle => 'Borukva News';

  @override
  HotspotStorage get storage => HotspotStorage(
    workerUrl:
        'https://gh-proxy.pavlyk-smal.workers.dev?file=15_02-21_02_hotspots.json',
    cacheKey: '15_02-21_02_hotspots_cache',
  );

  @override
  List<String> get photos => [
    'assets/pictures/15_02-21_02/15.02-21.02.png',
    'assets/pictures/15_02-21_02/Газета 15-21 лют стор. 1.png',
    'assets/pictures/15_02-21_02/Газета 15-21 лют стор. 2.png',
    'assets/pictures/15_02-21_02/Газета 15-21 лют стор. 3.png',
    'assets/pictures/15_02-21_02/Газета 15-21 лют стор. 4.png',
    'assets/pictures/15_02-21_02/Газета 15-21 лют стор. 5.png',
    'assets/pictures/остання стор.png',
  ];
}
