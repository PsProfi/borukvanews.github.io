import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

class KchbnkScreen extends StatefulWidget {
  const KchbnkScreen({super.key});
  @override
  State<KchbnkScreen> createState() => _KchbnkScreenState();
}

class _KchbnkScreenState extends CarouselScreenState<KchbnkScreen> {
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
        'https://gh-proxy.pavlyk-smal.workers.dev?file=kchbnk_hotspots.json',
    cacheKey: 'kchbnk_hotspots_cache',
  );

  @override
  List<PageItem> get pages => [
    PageItem.image('assets/pictures/kchbnk/Нов руб.png'),
    PageItem.image('assets/pictures/kchbnk/Кчбнк стор.1 .png'),
    PageItem.image('assets/pictures/kchbnk/Кчбнк стор.2 .png'),
    PageItem.image('assets/pictures/kchbnk/Кчбнк стор.3 .png'),
    PageItem.image('assets/pictures/kchbnk/Кчбнк стор.4 .png'),
    PageItem.image('assets/pictures/kchbnk/Кчбнк стор.5 .png'),
    PageItem.image('assets/pictures/kchbnk/Кчбнк стор.6 .png'),
    PageItem.image('assets/pictures/kchbnk/Кчбнк стор.7 .png'),
    PageItem.image('assets/pictures/kchbnk/Кчбнк титул. .png'),
  ];
}
