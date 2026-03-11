import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Carousel Item Model ──────────────────────────────────────────────────────

class CarouselItem {
  final String imagePath;
  final String url;
  final String? caption;

  CarouselItem({required this.imagePath, required this.url, this.caption});
}

// ─── Dropdown Menu Item ───────────────────────────────────────────────────────

class DropdownMenuItem {
  final String label;
  final String route;

  DropdownMenuItem({required this.label, required this.route});
}

// ─── News Home Page ───────────────────────────────────────────────────────────

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  bool _isCarouselHovered = false;

  // Multiple dropdown menus with their options
  final Map<String, List<DropdownMenuItem>> _dropdownMenus = {
    'Основні випуски': [
      DropdownMenuItem(label: '09.02-14.02', route: '/atRmklps'),
    ],
    'Спецвипуски': [
      DropdownMenuItem(label: 'Спецвипуск 1', route: '/qbE34klm'),
    ],
    'Інтерв\'ю': [DropdownMenuItem(label: 'Скоро', route: '/empty')],
  };

  final List<CarouselItem> _carouselItems = [
    CarouselItem(
      imagePath: 'assets/pictures/kchbnk/Нов руб.png',
      url: '/#/atRmklps',
      caption: 'Нова рубрика!',
    ),
    CarouselItem(
      imagePath: 'assets/carousel/news2.png',
      url: 'https://example.com/news2',
      caption: 'Sports Update: Team Wins Championship',
    ),
    CarouselItem(
      imagePath: 'assets/carousel/news3.png',
      url: 'https://example.com/news3',
      caption: 'Cultural Festival Begins This Weekend',
    ),
    CarouselItem(
      imagePath: 'assets/carousel/news4.png',
      url: 'https://example.com/news4',
      caption: 'Economic Report Shows Growth',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentIndex < _carouselItems.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  void _goToPage(int index) {
    _stopAutoPlay();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _startAutoPlay();
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _navigateToRoute(String route) {
    context.go(route);
  }

  Widget _buildDropdown(String title, List<DropdownMenuItem> items) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: "Minecraft",
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<String>(
            value: item.route,
            child: Text(item.label, style: GoogleFonts.roboto(fontSize: 14)),
          );
        }).toList();
      },
      onSelected: (route) => _navigateToRoute(route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pictures/bg/backg2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                // Logo (left)
                Text(
                  'Borukva News',
                  style: GoogleFonts.tapestry(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 32),
                const Spacer(),

                // Dropdown menus
                ..._dropdownMenus.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: _buildDropdown(entry.key, entry.value),
                  );
                }).toList(),

                const Spacer(),

                // Play button (right) - redirects to external site
                OutlinedButton(
                  onPressed: () => _openUrl(
                    'https://tsebuleve.wiki.gg/uk/wiki/%D0%93%D0%B0%D0%B9%D0%B4_%C2%AB%D0%A0%D0%B5%D1%94%D1%81%D1%82%D1%80%D0%B0%D1%86%D1%96%D1%8F_%D0%BD%D0%B0_%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D1%96%C2%BB',
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black87, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      Text(
                        'Грати на сервері',
                        style: TextStyle(
                          fontFamily: "Minecraft",
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          body: Column(
            children: [
              // Carousel section with arrows outside
              SizedBox(
                height: 800,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left arrow (outside container, always visible)
                    AnimatedOpacity(
                      opacity: _currentIndex == 0 ? 0.3 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: CircleBorder(
                            eccentricity: 0.5,
                            side: BorderSide(
                              color: Colors.black87.withOpacity(0.8),
                              width: 1.5,
                            ),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.8),
                          overlayColor: Colors.black.withOpacity(
                            0.3,
                          ), // 👈 колір при натисканні
                          padding: const EdgeInsets.all(12),
                          elevation: 5,
                        ),
                        child: const Text(
                          '<',
                          style: TextStyle(
                            fontFamily: "Minecraft",
                            fontSize: 24,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        onPressed: () {
                          if (_currentIndex == 0) {
                            _goToPage(_carouselItems.length - 1);
                          } else {
                            _goToPage(_currentIndex - 1);
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Carousel container
                    SizedBox(
                      width: 500,
                      child: MouseRegion(
                        onEnter: (_) =>
                            setState(() => _isCarouselHovered = true),
                        onExit: (_) =>
                            setState(() => _isCarouselHovered = false),
                        child: Stack(
                          children: [
                            // Carousel
                            PageView.builder(
                              controller: _pageController,
                              itemCount: _carouselItems.length,
                              onPageChanged: (index) {
                                setState(() => _currentIndex = index);
                              },
                              itemBuilder: (context, index) {
                                final item = _carouselItems[index];
                                return GestureDetector(
                                  onTap: () => _openUrl(item.url),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      margin: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              item.imagePath,
                                              fit: BoxFit.cover,
                                            ),

                                            // Hover overlay indicator
                                            if (_isCarouselHovered)
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    width: 3,
                                                  ),
                                                ),
                                              ),

                                            // Dark gradient overlay for text readability
                                            if (item.caption != null)
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                      colors: [
                                                        Colors.black
                                                            .withOpacity(0.8),
                                                        Colors.transparent,
                                                      ],
                                                    ),
                                                  ),
                                                  child: Text(
                                                    item.caption!,
                                                    style: GoogleFonts.roboto(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            // Click indicator icon when hovering
                                            if (_isCarouselHovered)
                                              Center(
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.open_in_new,
                                                    size: 32,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Dot indicators
                            Positioned(
                              bottom: 40,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_carouselItems.length, (
                                  index,
                                ) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: _currentIndex == index ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentIndex == index
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Right arrow (outside container, always visible)
                    AnimatedOpacity(
                      opacity: _currentIndex == _carouselItems.length - 1
                          ? 0.3
                          : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 32),
                        color: Colors.black87,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          padding: const EdgeInsets.all(12),
                        ),
                        onPressed: () {
                          if (_currentIndex == _carouselItems.length - 1) {
                            // Go to first slide
                            _goToPage(0);
                          } else {
                            _goToPage(_currentIndex + 1);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom text section
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      'Останні новини та оновлення на Борукві',
                      style: TextStyle(
                        fontFamily: "Minecraft",
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '© ${DateTime.now().year} Borukva News. All rights reserved.',
                      style: TextStyle(
                        fontFamily: "Minecraft",
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
