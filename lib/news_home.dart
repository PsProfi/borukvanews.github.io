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
      url: '/#/qbE34klm',
      caption: 'Нова рубрика!',
    ),
    CarouselItem(
      imagePath: 'assets/pictures/skoro/скоро.png',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      caption: 'Скоро...',
    ),
    CarouselItem(
      imagePath: 'assets/pictures/skoro/скоро.png',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      caption: 'Скоро...',
    ),
    CarouselItem(
      imagePath: 'assets/pictures/skoro/скоро.png',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      caption: 'Скоро...',
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
      tooltip: title,
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
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
              style: const TextStyle(
                fontFamily: "Minecraft",
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<String>(
            value: item.route,
            child: SizedBox(
              width: double.infinity,
              child: Text(item.label, style: GoogleFonts.roboto(fontSize: 14)),
            ),
          );
        }).toList();
      },
      onSelected: (route) => _navigateToRoute(route),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pictures/bg/bg_borukva-monochrome.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 2,
            backgroundColor: Colors.transparent,
            title: isMobile
                ? Row(
                    children: [
                      // Mobile: Just logo and hamburger menu
                      Text(
                        'Borukva',
                        style: GoogleFonts.tapestry(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.menu, color: Colors.black87),
                        offset: const Offset(0, 40),
                        itemBuilder: (context) {
                          List<PopupMenuEntry<String>> allItems = [];

                          // Add all dropdown items
                          _dropdownMenus.forEach((category, items) {
                            allItems.add(
                              PopupMenuItem<String>(
                                enabled: false,
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontFamily: "Minecraft",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );

                            for (var item in items) {
                              allItems.add(
                                PopupMenuItem<String>(
                                  value: item.route,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      item.label,
                                      style: GoogleFonts.roboto(fontSize: 13),
                                    ),
                                  ),
                                ),
                              );
                            }

                            allItems.add(const PopupMenuDivider());
                          });

                          // Add play button
                          allItems.add(
                            PopupMenuItem<String>(
                              value: 'play',
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Грати на сервері',
                                    style: GoogleFonts.roboto(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );

                          return allItems;
                        },
                        onSelected: (value) {
                          if (value == 'play') {
                            _openUrl(
                              'https://tsebuleve.wiki.gg/uk/wiki/%D0%93%D0%B0%D0%B9%D0%B4_%C2%AB%D0%A0%D0%B5%D1%94%D1%81%D1%82%D1%80%D0%B0%D1%86%D1%96%D1%8F_%D0%BD%D0%B0_%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D1%96%C2%BB',
                            );
                          } else {
                            _navigateToRoute(value);
                          }
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Desktop: Full layout
                      Text(
                        'Borukva News',
                        style: GoogleFonts.tapestry(
                          fontSize: isTablet ? 24 : 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 32),
                      const Spacer(),

                      // Dropdown menus
                      ..._dropdownMenus.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildDropdown(entry.key, entry.value),
                        );
                      }).toList(),

                      const Spacer(),

                      // Play button
                      OutlinedButton(
                        onPressed: () => _openUrl(
                          'https://tsebuleve.wiki.gg/uk/wiki/%D0%93%D0%B0%D0%B9%D0%B4_%C2%AB%D0%A0%D0%B5%D1%94%D1%81%D1%82%D1%80%D0%B0%D1%86%D1%96%D1%8F_%D0%BD%D0%B0_%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D1%96%C2%BB',
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          side: const BorderSide(
                            color: Colors.black87,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20 : 40,
                            vertical: isTablet ? 12 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isTablet ? 'Грати' : 'Грати на сервері',
                          style: TextStyle(
                            fontFamily: "Minecraft",
                            color: Colors.black87,
                            fontSize: isTablet ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Carousel section with responsive sizing
                SizedBox(
                  height: isMobile ? 500 : (isTablet ? 600 : 800),
                  child: isMobile
                      ? _buildMobileCarousel()
                      : _buildDesktopCarousel(isTablet),
                ),

                // Bottom text section
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white.withOpacity(0.5),
                  child: Column(
                    children: [
                      Text(
                        'Останні новини та оновлення на Борукві',
                        style: TextStyle(
                          fontFamily: "Minecraft",
                          fontSize: isMobile ? 12 : 16,
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
                          fontSize: isMobile ? 10 : 12,
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
      ),
    );
  }

  // Mobile carousel - stacked vertically with overlay arrows
  Widget _buildMobileCarousel() {
    return Stack(
      children: [
        // Carousel
        PageView.builder(
          controller: _pageController,
          itemCount: _carouselItems.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            return _buildCarouselItem(_carouselItems[index], true);
          },
        ),

        // Left arrow overlay
        Positioned(
          left: 8,
          top: 0,
          bottom: 60,
          child: Center(child: _buildArrowButton(true, true)),
        ),

        // Right arrow overlay
        Positioned(
          right: 8,
          top: 0,
          bottom: 60,
          child: Center(child: _buildArrowButton(false, true)),
        ),

        // Dot indicators
        Positioned(bottom: 20, left: 0, right: 0, child: _buildDotIndicators()),
      ],
    );
  }

  // Desktop carousel - horizontal with external arrows
  Widget _buildDesktopCarousel(bool isTablet) {
    final carouselWidth = isTablet ? 400.0 : 500.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left arrow
        _buildArrowButton(true, false),
        const SizedBox(width: 20),

        // Carousel
        SizedBox(
          width: carouselWidth,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isCarouselHovered = true),
            onExit: (_) => setState(() => _isCarouselHovered = false),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _carouselItems.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildCarouselItem(_carouselItems[index], false);
                  },
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildDotIndicators(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 20),
        // Right arrow
        _buildArrowButton(false, false),
      ],
    );
  }

  Widget _buildCarouselItem(CarouselItem item, bool isMobile) {
    return GestureDetector(
      onTap: () => _openUrl(item.url),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: EdgeInsets.all(isMobile ? 12 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
                Image.asset(item.imagePath, fit: BoxFit.cover),

                // Hover overlay
                if (_isCarouselHovered && !isMobile)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                  ),

                // Caption
                if (item.caption != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        item.caption!,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Click indicator
                if (_isCarouselHovered && !isMobile)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
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
  }

  Widget _buildArrowButton(bool isLeft, bool isMobile) {
    final isAtEnd = isLeft
        ? _currentIndex == 0
        : _currentIndex == _carouselItems.length - 1;

    return TextButton(
      style: TextButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: isMobile
            ? Colors.black.withOpacity(0.5)
            : Colors.grey[200],
        overlayColor: Colors.black,
        padding: EdgeInsets.all(isMobile ? 12 : 20),
      ),
      onPressed: () {
        if (isLeft) {
          _goToPage(
            _currentIndex == 0 ? _carouselItems.length - 1 : _currentIndex - 1,
          );
        } else {
          _goToPage(
            _currentIndex == _carouselItems.length - 1 ? 0 : _currentIndex + 1,
          );
        }
      },
      child: Text(
        isLeft ? '<' : ' >',
        style: TextStyle(
          fontFamily: "Minecraft",
          fontSize: isMobile ? 20 : 24,
          color: isMobile ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_carouselItems.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
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
    );
  }
}
