import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    style: GoogleFonts.tapestry(fontWeight: FontWeight.w600, fontSize: 40),
  );
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
