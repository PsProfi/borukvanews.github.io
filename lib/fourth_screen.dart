import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    style: GoogleFonts.tapestry(fontWeight: FontWeight.w600, fontSize: 40),
  );

  @override
  HotspotStorage get storage => HotspotStorage(
    workerUrl:
        'https://gh-proxy.pavlyk-smal.workers.dev?file=01_03-14_03_hotspots.json',
    cacheKey: '01_03-14_03_hotspots_cache',
  );

  @override
  List<String> get photos => [
    'assets/pictures/01_03-14_03/Титул. 1-14 бер.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 1.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 2.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 3.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 4.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 5.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 6.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 7.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 8.png',
    'assets/pictures/01_03-14_03/Газета 1-14 бер стор. 9.png',
    'assets/pictures/остання стор.png',
  ];
}
