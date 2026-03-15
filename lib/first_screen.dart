import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hotspot_shared.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends CarouselScreenState<FirstScreen> {
  @override
  Widget get appBarTitleWidget => Text(
    'Borukva News',
    style: GoogleFonts.tapestry(fontWeight: FontWeight.w600, fontSize: 40),
  );

  @override
  HotspotStorage get storage => HotspotStorage(
    workerUrl:
        'https://gh-proxy.pavlyk-smal.workers.dev?file=09_02-14_02_hotspots.json',
    cacheKey: '09_02-14_02_hotspots_cache',
  );

  @override
  List<String> get photos => [
    'assets/pictures/09_02-14_02/title_1.png',
    'assets/pictures/09_02-14_02/page_1.png',
    'assets/pictures/09_02-14_02/page_2.png',
    'assets/pictures/09_02-14_02/page_3.png',
    'assets/pictures/09_02-14_02/page_4.png',
    'assets/pictures/09_02-14_02/last_1.png',
  ];
}
