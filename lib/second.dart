import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      style: OutlinedButton.styleFrom(
        overlayColor: Colors.white,
        side: BorderSide(color: color, width: 2),
        shape: CircleBorder(),
        minimumSize: const Size(50, 50),
      ),

      child: Icon(icon, color: color, size: 24),
    );
  }
}

class TextBtn extends StatelessWidget {
  final Text text;
  final VoidCallback onTap;
  final Color color;

  const TextBtn({
    super.key,
    required this.text,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        overlayColor: Colors.white,
        side: BorderSide(color: color, width: 2),
        shape: CircleBorder(),
        minimumSize: const Size(50, 50),
      ),
      child: text,
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
          // ── Swipeable pages ──
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

          // ── Close button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: OutlinedIconBtn(
              icon: Icons.close,
              onTap: () => Navigator.of(context).pop(_currentIndex),
            ),
          ),

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

          // ── Next arrow — hidden when on last photo ──
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

// ─── Main carousel screen ─────────────────────────────────────────────────────

class PhotoCarouselScreen extends StatefulWidget {
  const PhotoCarouselScreen({super.key});

  @override
  State<PhotoCarouselScreen> createState() => _PhotoCarouselScreenState();
}

class _PhotoCarouselScreenState extends State<PhotoCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _photos = [
    'assets/pictures/09_02-14_02/title_1.png',
    'assets/pictures/09_02-14_02/page_1.png',
    'assets/pictures/09_02-14_02/page_2.png',
    'assets/pictures/09_02-14_02/page_3.png',
    'assets/pictures/09_02-14_02/page_4.png',
    'assets/pictures/09_02-14_02/last_1.png',
  ];

  bool get _hasPrev => _currentIndex > 0;
  bool get _hasNext => _currentIndex < _photos.length - 1;

  void _nextPhoto() {
    if (_hasNext) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPhoto() {
    if (_hasPrev) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _openFullScreen() async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            FullScreenViewer(photos: _photos, initialIndex: _currentIndex),
      ),
    );
    if (result != null && result != _currentIndex) {
      setState(() => _currentIndex = result);
      _pageController.jumpToPage(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Borukva News',
          style: GoogleFonts.tapestry(
            fontWeight: FontWeight.w600,
            fontSize: 40,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('assets/pictures/bg/backg.png', fit: BoxFit.cover),

          // Content pushed below AppBar
          Column(
            children: [
              SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
              ),
              Expanded(
                child: Stack(
                  children: [
                    // Carousel
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemCount: _photos.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _photos[index],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                    ),

                    // Expand button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: OutlinedIconBtn(
                        icon: Icons.fullscreen,
                        color: Colors.black87,
                        onTap: _openFullScreen,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation row
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous — fades out on first photo
                  AnimatedOpacity(
                    opacity: _hasPrev ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !_hasPrev,
                      child: TextBtn(
                        text: Text(
                          "<",
                          style: TextStyle(
                            fontFamily: "Minecraft",
                            color: Colors.black,
                          ),
                        ),
                        color: Colors.black87,
                        onTap: _previousPhoto,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentIndex + 1} / ${_photos.length}',
                    style: TextStyle(fontFamily: "Minecraft"),
                  ),
                  const SizedBox(width: 16),
                  // Next — fades out on last photo
                  AnimatedOpacity(
                    opacity: _hasNext ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !_hasNext,
                      child: TextBtn(
                        text: Text(
                          ">",
                          style: TextStyle(
                            fontFamily: "Minecraft",
                            color: Colors.black,
                          ),
                        ),
                        color: Colors.black87,
                        onTap: _nextPhoto,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
