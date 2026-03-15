import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

class KchbnkScreen extends StatefulWidget {
  const KchbnkScreen({super.key});
  @override
  State<KchbnkScreen> createState() => _KchbnkScreenState();
}

class _KchbnkScreenState extends CarouselScreenState<KchbnkScreen> {
  @override
  String get appBarTitle => 'Borukva News';

  @override
  HotspotStorage get storage => HotspotStorage(
    workerUrl:
        'https://gh-proxy.pavlyk-smal.workers.dev?file=kchbnk_hotspots.json',
    cacheKey: 'kchbnk_hotspots_cache',
  );

  @override
  List<String> get photos => [
    'assets/pictures/kchbnk/Нов руб.png',
    'assets/pictures/kchbnk/Кчбнк стор.1 .png',
    'assets/pictures/kchbnk/Кчбнк стор.2 .png',
    'assets/pictures/kchbnk/Кчбнк стор.3 .png',
    'assets/pictures/kchbnk/Кчбнк стор.4 .png',
    'assets/pictures/kchbnk/Кчбнк стор.5 .png',
    'assets/pictures/kchbnk/Кчбнк стор.6 .png',
    'assets/pictures/kchbnk/Кчбнк стор.7 .png',
    'assets/pictures/kchbnk/Кчбнк титул. .png',
  ];
}
