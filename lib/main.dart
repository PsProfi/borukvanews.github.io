import 'package:bor_nov_site/empty_screen.dart';
import 'package:bor_nov_site/first.dart';
import 'package:bor_nov_site/second.dart';
import 'package:bor_nov_site/third.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

void main() {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/RULE34', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/atRmklps',
        builder: (context, state) => const FirstScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const EmptyScreen()),
      GoRoute(
        path: '/qizmvUxp',
        builder: (context, state) => const SecondScreen(),
      ),
      GoRoute(
        path: '/pLxqnrvt',
        builder: (context, state) => const ThirdScreen(),
      ),
    ],
  );

  runApp(PhotoCarouselApp(router: router));
}

class PhotoCarouselApp extends StatelessWidget {
  final GoRouter router;

  const PhotoCarouselApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Borukva News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.tapestryTextTheme(Theme.of(context).textTheme),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─── Outlined icon button helper ─────────────────────────────────────────────

class OutlinedIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const OutlinedIconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.8),
          borderRadius: BorderRadius.circular(24),
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// ─── Main landing page ────────────────────────────────────────────────────────

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('assets/pictures/bg/backg.png', fit: BoxFit.cover),

          // Dark overlay for readability
          Container(color: Colors.black.withOpacity(0.35)),

          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo / title
                Text(
                  'Borukva',
                  style: GoogleFonts.tapestry(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'News',
                  style: GoogleFonts.tapestry(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    letterSpacing: 6,
                  ),
                ),

                const SizedBox(height: 30), // Enter button
                OutlinedButton(
                  onPressed: () => context.go('/atRmklps'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 24,
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '09.02-14.02',
                        style: TextStyle(fontFamily: "Minecraft"),
                      ),
                      SizedBox(width: 10),
                      Text(">", style: TextStyle(fontFamily: "Minecraft")),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Enter button
                OutlinedButton(
                  onPressed: () => context.go('/qizmvUxp'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 24,
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '15.02-21.02',
                        style: TextStyle(fontFamily: "Minecraft"),
                      ),
                      SizedBox(width: 10),
                      Text(">", style: TextStyle(fontFamily: "Minecraft")),
                    ],
                  ),
                ),
                const Spacer(flex: 2), // 👈 тепер кнопка ближче до тексту
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full-screen viewer ───────────────────────────────────────────────────────

class FullScreenViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const FullScreenViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _go(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool get _hasPrev => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.photos.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable pages
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.asset(widget.photos[index], fit: BoxFit.contain),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: OutlinedIconBtn(
              icon: Icons.close,
              onTap: () => Navigator.of(context).pop(_currentIndex),
            ),
          ),

          // Counter
          Positioned(
            top: MediaQuery.of(context).padding.top + 18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.8),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.photos.length}',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Previous arrow
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _hasPrev ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_hasPrev,
                  child: OutlinedIconBtn(
                    icon: Icons.arrow_back_ios,
                    onTap: () => _go(_currentIndex - 1),
                  ),
                ),
              ),
            ),
          ),

          // Next arrow
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _hasNext ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_hasNext,
                  child: OutlinedIconBtn(
                    icon: Icons.arrow_forward_ios,
                    onTap: () => _go(_currentIndex + 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carousel screen ──────────────────────────────────────────────────────────
