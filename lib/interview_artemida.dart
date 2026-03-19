import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

class InterviewScreenArtemida extends StatefulWidget {
  const InterviewScreenArtemida({super.key});
  @override
  State<InterviewScreenArtemida> createState() =>
      _InterviewScreenStateArtemida();
}

class _InterviewScreenStateArtemida
    extends CarouselScreenState<InterviewScreenArtemida> {
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
        'https://gh-proxy.pavlyk-smal.workers.dev?file=09_02-14_02_hotspots.json',
    cacheKey: '09_02-14_02_hotspots_cache',
  );

  @override
  List<PageItem> get pages => [PageItem.youtube('YjGYxL-vAZo')];
}
